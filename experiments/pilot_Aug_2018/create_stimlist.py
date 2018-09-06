#this script creates a stimlist for an experiment 
#it is for situations in which the 

import random
import numpy as np
import simanneal
import sklearn.metrics
import pandas as pd
import collections
import os


#first, define the fixed structure. This is the part of the design
#which you want done in its entirety, and it also constrains the number of stimuli


#here, we have 36 comparisons of segments and 4 orders, and we want to counterbalance them. 
#this determines the length of the experiment (36*4= 144 trials)
NUM_ORDERS = 4 #NUM_SENTENCES #what order segments in pair are in (PQP,QPP,PQQ,QPQ) #COND
NUM_COMPARISONS = 36 # (number of segment comparisons) #EMOTIONS

NUM_STIM = NUM_COMPARISONS*NUM_ORDERS

#SAMPLED
#for all of the above trials, we want half to be each of the following, and we don't want 
#these two to be predictive of the fixed structure 
NUM_SPEAKERS = 2  #speakers E_first A_first
NUM_CONTEXTS = 2 # /i/ stimuli vs. /a/ stimuli 

#define columns for a matrix which has each of these four factors as a column
COL_ORDER = 0
COL_COMPARISON = 1
COL_CONTEXT = 2
COL_SPEAKER = 3


#define several functions that will be used to create the .csv 

#this counts how many times something is duplicated
def num_duplicates(x):
    vals = collections.OrderedDict()
    for s in x:
        s_tup = tuple(s)
        if s_tup in vals:
            vals[s_tup] += 1
        else:
            vals[s_tup] = 0.
    return sum(vals.values())



#condition here means ORDER
#now we are defining the number of repetitions of the fixed part 
def repetitions_within_condition(stim_list):
    result = 0
    for comp in range(NUM_COMPARISONS):
        e1_c0_match = stim_list[(stim_list[:,COL_ORDER]==0) & (stim_list[:,COL_COMPARISON]==comp),:]
        e2_c0_match = stim_list[(stim_list[:,COL_ORDER]==0) & (stim_list[:,COL_COMPARISON]==comp),:]
        e1_c1_match = stim_list[(stim_list[:,COL_ORDER]==1) & (stim_list[:,COL_COMPARISON]==comp),:]
        e2_c1_match = stim_list[(stim_list[:,COL_ORDER]==1) & (stim_list[:,COL_COMPARISON]==comp),:]
        e1_c2_match = stim_list[(stim_list[:,COL_ORDER]==2) & (stim_list[:,COL_COMPARISON]==comp),:]
        e2_c2_match = stim_list[(stim_list[:,COL_ORDER]==2) & (stim_list[:,COL_COMPARISON]==comp),:]
        e1_c3_match = stim_list[(stim_list[:,COL_ORDER]==3) & (stim_list[:,COL_COMPARISON]==comp),:]
        e2_c3_match = stim_list[(stim_list[:,COL_ORDER]==3) & (stim_list[:,COL_COMPARISON]==comp),:]

        result += num_duplicates(e1_c0_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e2_c0_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e1_c1_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e2_c1_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e1_c2_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e2_c2_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e1_c3_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
                + num_duplicates(e2_c3_match[:,(COL_SENTENCE,COL_SPEAKER)])
    return result


#there are no more global repetitions 
#def repetitions_global(stim_list):
#    result = 0
#    for em in range(NUM_EMOTIONS*2):
#        e1_match = stim_list[(stim_list[:,COL_EM1]==em),:]
#        e2_match = stim_list[(stim_list[:,COL_EM2]==em),:]
#        result += num_duplicates(e1_match[:,(COL_SENTENCE,COL_SPEAKER)]) \
#                + num_duplicates(e2_match[:,(COL_SENTENCE,COL_SPEAKER)])
#    return result


#

def other(e):
    return [x for x in range(NUM_ORDERS) if x != e]


#sentence = context 
#speakers = speakers

class BinaryAnnealer(simanneal.Annealer):
    def move(self):
        stim = random.randrange(NUM_STIM)
        self.state[stim,COL_CONTEXT] = random.randrange(NUM_CONTEXTS)
        self.state[stim,COL_SPEAKER] = random.randrange(NUM_SPEAKERS)

    def energy(self):
        pred_sent_from_spk = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_CONTEXT],
                self.state[:,COL_SPEAKER])
        pred_comp_from_sent = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_COMPARISON],
                self.state[:,COL_CONTEXT])
        pred_comp_from_spk = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_COMPARISON],
                self.state[:,COL_SPEAKER])
        pred_ord_from_sent = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_ORDER],
                self.state[:,COL_CONTEXT])
        pred_ord_from_spk = sklearn.metrics.normalized_mutual_info_score(
                self.state[:,COL_ORDER],
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
                + pred_comp_from_sent \
                + pred_comp_from_spk \
                + pred_ord_from_sent \
                + pred_ord_from_spk
#        return sklearn.metrics.mutual_info_score(self.state[:,2],
#                self.state[:,3])



# PARAMS
output_file = "stimlist.csv"
read_from_last = False
n_steps = 20000
t_min = 0.00001

#COND=ORDER 
#EMOTION= COMPARISON


if not read_from_last:
    t_max = 10
    stim_list = np.zeros((NUM_STIM, 4)) # create an empty matrix with the right number of cols 
    i = 0
    for comp in range(NUM_COMPARISONS):
            stim_list[i,COL_ORDER] = 0
            stim_list[i,COL_COMPARISON] = comp
            i += 1
            stim_list[i,COL_ORDER] = 1
            stim_list[i,COL_COMPARISON] = comp
            i += 1
            stim_list[i,COL_ORDER] = 2
            stim_list[i,COL_COMPARISON] = comp
            i += 1
            stim_list[i,COL_ORDER] = 3
            stim_list[i,COL_COMPARISON] = comp
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
s_df.columns = ['ORDER', 'COMPARISON',  'CONTEXT','SPEAKER']
s_df.to_csv(folder/output_file, index=False)



