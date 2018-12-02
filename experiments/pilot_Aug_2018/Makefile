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
stimulus_list.csv triplets.csv stimuli/item_meta_information.csv && \
Rscript --vanilla \
distances/prepare_stimuli_for_distance_calculation_aug.Rscript \
stimuli/item_meta_information.csv stimuli/raw distances/tmp/PAIRS_TMP.csv

distances/tmp/distances__normed_filterbank__dtw_pathlength__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py --normalize-by-speaker distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__unnormed_filterbank__dtw_pathlength__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__normed_mfcc__dtw_pathlength__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py --nceps=13 --normalize-by-speaker distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__unnormed_mfcc__dtw_pathlength__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py --nceps=13 distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__normed_filterbank__dtw_sum__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py --normalize-by-speaker --distance-function=dtw_euclidean  distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__unnormed_filterbank__dtw_sum__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py --distance-function=dtw_euclidean distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__normed_mfcc__dtw_sum__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py --normalize-by-speaker --nceps=13 --distance-function=dtw_euclidean distances/tmp/PAIRS_TMP.csv 16000 $@

distances/tmp/distances__unnormed_mfcc__dtw_sum__by_pair.csv: \
	distances/tmp distances/tmp/PAIRS_TMP.csv
	python ../../src/wav_to_distance.py --nceps=13 --distance-function=dtw_euclidean  distances/tmp/PAIRS_TMP.csv 16000 $@

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

stimulus_list.csv: design.csv
	Rscript --vanilla create_stimlist.Rscript \
567 design.csv stimuli/meta_info_filelist.csv stimulus_list.csv

stimuli/item_meta_information_with_distances.csv: distances
	Rscript --vanilla \
distances/merge_distances.Rscript \
stimuli/item_meta_information.csv \
stimuli/item_meta_information_with_distances.csv \
distances/distances__*.csv

stimuli/stimuli_intervals:
	python stimuli/save_intervals_to_wavs.py word stimuli/stimuli_intervals \
stimuli/meta_info_filelist.csv \
stimuli/raw/amelia_consonants_ONLY_TARGET_CHECKED.TextGrid,stimuli/raw/amelia_consonants.wav \
stimuli/raw/amelia_vowels_ONLY_TARGET_CHECKED.TextGrid,stimuli/raw/amelia_vowels.wav \
stimuli/raw/ewan_ONLY_TARGET_CHECKED.TextGrid,stimuli/raw/ewan.wav

#NB- this step ONLY takes absolute paths to raw data files. raw data files contain
#personally identifiable information and  should never be shared or synced to git 
anonymize_data: 
	python anonymize_lmeds_data_filenames.py \
/Users/post-doc/Desktop/output \
/Users/post-doc/Documents/GitHub/geomphon-perception-ABX/experiments/pilot_Aug_2018/anon_output \
/Users/post-doc/Desktop/anon_key.csv

split_output_to_results_files: anon_output
	python split_output_to_results_files.py \
anon_output/ \
anon_output/results.csv \
anon_output/presurvey.csv \
anon_output/postsurvey.csv \
anon_output/postsurvey2.csv

filter_data: stimuli/item_meta_information_with_distances.csv
	Rscript --vanilla analysis_step1_preprocess_Aug_2018_pilot.Rscript \
anon_output/presurvey.csv \
anon_output/results.csv \
anon_output/postsurvey.csv \
anon_output/postsurvey2.csv \
stimuli/item_meta_information_with_distances.csv \
analysis/geomphon_pilot_results_for_analysis.csv

clean-design:
	rm design.csv

clean-stimulus-list:
	rm stimulus_list.csv

clean-distances-tmp:
	rm -rf distances/tmp

clean-distances: clean-distances-tmp
	rm -f distances/distances_*.csv

clean-stimuli-intervals:
	rm -rf stimuli/stimuli_intervals

clean-stimuli-construction: clean-stimuli-intervals



