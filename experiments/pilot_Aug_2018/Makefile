triplet-list:
	python ../../src/textgrid_to_abx_item_file_word.py word \
stimuli/amelia_vowels_ONLY_TARGET_CHECKED.TextGrid,amelia_vowels.wav \
stimuli/amelia_consonants_ONLY_TARGET_CHECKED.TextGrid,amelia_consonants.wav \
stimuli/ewan_ONLY_TARGET_CHECKED.TextGrid,ewan.wav \
--excluded-words=SAY,AGAIN,sp0 > ABX_ITEM_FILE.item \
&& Rscript --vanilla stimulus_construction/add_meta_information_to_item_file.Rscript \
ABX_ITEM_FILE.item ABX_ITEM_FILE_COMPLETE.item \
&& abx-task ABX_ITEM_FILE_COMPLETE.item ABX_TASK_FILE.task \
-o word -a speaker -b CV context \
&& python ../../src/task2txt.py ABX_TASK_FILE.task ABX_TASK_FILE.csv \
&& Rscript --vanilla add_meta_information_to_triplet_file.Rscript \
ABX_TASK_FILE.csv ABX_ITEM_FILE_COMPLETE.item triplets.csv

distances/tmp:
	mkdir -p distances/tmp

distances/tmp/PAIRS_TMP.csv: distances/tmp
	Rscript --vanilla stimuli/combine_triplet_meta_information.Rscript \
Stimuli_list.txt triplets.csv stimuli/item_meta_information.csv && \
Rscript --vanilla \
distances/prepare_stimuli_for_distance_calculation_aug.Rscript \
stimuli/item_meta_information.csv stimuli distances/tmp/PAIRS_TMP.csv

distances/tmp/distances__normed_filterbank__dtw_pathlength__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py \
distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__unnormed_filterbank__dtw_pathlength__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py \
--unnormalized \
distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__normed_mfcc__dtw_pathlength__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py \
--nceps=13 \
distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__unnormed_mfcc__dtw_pathlength__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py \
--unnormalized --nceps=13 \
distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__normed_filterbank__dtw_sum__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py \
--distance-function=dtw_euclidean \
distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__unnormed_filterbank__dtw_sum__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py \
--unnormalized --distance-function=dtw_euclidean \
distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__normed_mfcc__dtw_sum__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py \
--nceps=13 --distance-function=dtw_euclidean \
distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__unnormed_mfcc__dtw_sum__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py \
--unnormalized --nceps=13 --distance-function=dtw_euclidean \
distances/tmp/PAIRS_TMP.csv 16000 $@

distances/distances__%.csv: distances/tmp/distances__%__by_pair.csv
	Rscript --vanilla \
distances/reshape_result_of_distance_calculation_aug.Rscript \
$< stimuli $@

distances: distances/distances__normed_filterbank__dtw_pathlength.csv \
distances/distances__unnormed_filterbank__dtw_pathlength.csv \
distances/distances__normed_mfcc__dtw_pathlength.csv \
distances/distances__unnormed_mfcc__dtw_pathlength.csv \
distances/distances__normed_filterbank__dtw_sum.csv \
distances/distances__unnormed_filterbank__dtw_sum.csv \
distances/distances__normed_mfcc__dtw_sum.csv \
distances/distances__unnormed_mfcc__dtw_sum.csv \
clean-distances-tmp

clean-distances-tmp:
	rm -rf distances/tmp

clean-distances: clean-distances-tmp
	rm -f distances/distances_*.csv

stimuli/item_meta_information_with_distances.csv: distances
	Rscript --vanilla \
distances/merge_distances.Rscript \
stimuli/item_meta_information.csv \
stimuli/item_meta_information_with_distances.csv \
distances/distances__*.csv

stimuli/stimuli_intervals:
	python stimuli/save_intervals_to_wavs.py word stimuli/stimuli_intervals \
stimuli/meta_info_filelist.csv \
stimuli/amelia_consonants_ONLY_TARGET_CHECKED.TextGrid,stimuli/amelia_consonants.wav \
stimuli/amelia_vowels_ONLY_TARGET_CHECKED.TextGrid,stimuli/amelia_vowels.wav \
stimuli/ewan_ONLY_TARGET_CHECKED.TextGrid,stimuli/ewan.wav

clean-stimuli-intervals:
	rm -rf stimuli/stimuli_intervals

clean-stimuli-construction: clean-stimuli-intervals




###
## Rscript --vanilla distances/prepare_stimuli_for_distance_calculation.Rscript stimuli/item_meta_information.csv ${TIMIT_FOLDER}  $$TIMIT_AUDIO_EXTENSION distances/tmp/PAIRS_TMP.csv 

