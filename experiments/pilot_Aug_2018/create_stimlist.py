import random
import numpy as np
import simanneal
import sklearn.metrics
import pandas as pd
import collections


#fixed: 

#condition = context 

#NUM_SEG_PAIRS = 15 #for vowels, number of segment pairs (6 segments, 5+4+3+2+1)
#NUM_SENTENCES = 4 #what order segments in pair are in (PQP,QPP,PQQ,QPQ)
#NUM_SPEAKERS = 2 #speakers E_first A_first
#NUM_CONTEXTS = 2 # /i/ vs /a/ 

NUM_EMOTIONS = 15 # (number of segment comparisons)
NUM_SENTENCES = 4 #what order segments in pair are in (PQP,QPP,PQQ,QPQ)
NUM_SPEAKERS = 2  #speakers E_first A_first


NUM_MISMATCH = NUM_EMOTIONS*(NUM_EMOTIONS-1)*2 # 24
NUM_MATCH = NUM_MISMATCH
NUM_STIM = NUM_MISMATCH + NUM_MATCH
NUM_STIM_PER_EMOTION_WITHIN_COND = (NUM_EMOTIONS-1)*2
## 2 (audio + visual) * number of possible repetitions
##  * number of emotions * number of conditions
MAX_REPETITIONS_WITHIN_COND = 2*(NUM_STIM_PER_EMOTION_WITHIN_COND-1) \
                            *NUM_EMOTIONS*2

MAX_REPETITIONS_GLOBAL = 2*(NUM_STIM_PER_EMOTION_WITHIN_COND*2-1) \
                            *NUM_EMOTIONS
                                    
                                    
COL_COND = 0
COL_EM1 = 1
COL_EM2 = 2
COL_ORDER = 3
COL_SPEAKER = 4

def num_duplicates(x):
    vals = collections.OrderedDict()
    for s in x:
        s_tup = tuple(s)
        if s_tup in vals:
            vals[s_tup] += 1
        else:
            vals[s_tup] = 0.
    return sum(vals.values())

def repetitions_within_condition(stim_list):
    result = 0
    for em in range(NUM_EMOTIONS*2):
        e1_c0_match = stim_list[(stim_list[:,COL_COND]==0) & (stim_list[:,COL_EM1]==em),:]
        e2_c0_match = stim_list[(stim_list[:,COL_COND]==0) & (stim_list[:,COL_EM2]==em),:]
        e1_c1_match = stim_list[(stim_list[:,COL_COND]==1) & (stim_list[:,COL_EM1]==em),:]
        e2_c1_match = stim_list[(stim_list[:,COL_COND]==1) & (stim_list[:,COL_EM2]==em),:]
        result += num_duplicates(e1_c0_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e2_c0_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e1_c1_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e2_c1_match[:,(COL_SENTENCE,COL_SPEAKER)])
    return result


def repetitions_global(stim_list):
    result = 0
    for em in range(NUM_EMOTIONS*2):
        e1_match = stim_list[(stim_list[:,COL_EM1]==em),:]
        e2_match = stim_list[(stim_list[:,COL_EM2]==em),:]
        result += num_duplicates(e1_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e2_match[:,(COL_SENTENCE,COL_SPEAKER)])
    return result


def other(e):
    return [x for x in range(NUM_EMOTIONS) if x != e]




class BinaryAnnealer(simanneal.Annealer):
    def move(self):
        stim = random.randrange(NUM_STIM)
        self.state[stim,COL_SENTENCE] = random.randrange(NUM_SENTENCES)
        self.state[stim,COL_SPEAKER] = random.randrange(NUM_SPEAKERS)

    def energy(self):
        pred_sent_from_spk = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_SENTENCE],
                self.state[:,COL_SPEAKER])
        pred_em1_from_sent = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_EM1],
                self.state[:,COL_SENTENCE])
        pred_em2_from_sent = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_EM2],
                self.state[:,COL_SENTENCE])
        pred_em1_from_spk = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_EM1],
                self.state[:,COL_SPEAKER])
        pred_em2_from_spk = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_EM2],
                self.state[:,COL_SPEAKER])
        pred_cond_from_sent = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_COND],
                self.state[:,COL_SENTENCE])
        pred_cond_from_spk = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_COND],
                self.state[:,COL_SPEAKER])
        repetitions_within_cond_ = repetitions_within_condition(self.state)
        norm_repetitions_within_cond = repetitions_within_cond_\
                                            /MAX_REPETITIONS_WITHIN_COND
        repetitions_global_ = repetitions_global(self.state)
        if (MAX_REPETITIONS_GLOBAL > repetitions_within_cond_):
            norm_repetitions_across_cond = (repetitions_global_ \
                                            - repetitions_within_cond_) \
                                            /(MAX_REPETITIONS_GLOBAL \
                                            - repetitions_within_cond_)
        else:
            norm_repetitions_across_cond = 0.0
#        print (pred_sent_from_spk, repetitions_within_cond_, repetitions_global_)
        return pred_sent_from_spk \
                + norm_repetitions_within_cond*10 \
                + norm_repetitions_across_cond*10 \
                + pred_em1_from_sent \
                + pred_em2_from_sent \
                + pred_em1_from_spk \
                + pred_em2_from_spk \
                + pred_cond_from_sent \
                + pred_cond_from_spk
#        return sklearn.metrics.mutual_info_score(self.state[:,2],
#                self.state[:,3])

# PARAMS
output_file = "/Users/post-doc/Desktop/output.csv"
read_from_last = False
n_steps = 20000
t_min = 0.00001

if not read_from_last:
    t_max = 10
    stim_list = np.zeros((NUM_STIM, 5)) # Condition, Emotion1, Emotion2, Sentence, Speaker 
    i = 0
    for em1 in range(NUM_EMOTIONS):
        for em2 in other(em1):
            stim_list[i,COL_COND] = 0
            stim_list[i,COL_EM1] = em1
            stim_list[i,COL_EM2] = em2
            i += 1
            stim_list[i,COL_COND] = 0
            stim_list[i,COL_EM1] = em1
            stim_list[i,COL_EM2] = em2
            i += 1
    for em in range(NUM_EMOTIONS):
        for _ in range(NUM_EMOTIONS-1):
            stim_list[i,COL_COND] = 1
            stim_list[i,COL_EM1] = em
            stim_list[i,COL_EM2] = em
            i += 1
            stim_list[i,COL_COND] = 1
            stim_list[i,COL_EM1] = em
            stim_list[i,COL_EM2] = em
            i += 1
else:
    t_max = 0.04
    
    stim_list = pd.read_csv(output_file).as_matrix()
opt = BinaryAnnealer(stim_list)
opt.steps = n_steps
opt.Tmax = t_max
opt.Tmin = t_min
solution = opt.anneal()
print (solution)
s_df = pd.DataFrame(solution[0])
s_df.columns = ['Context', 'Seg_comp_pair', 'IGNORE', 'Order',\
                'Speaker']
s_df.to_csv(output_file, index=False)




