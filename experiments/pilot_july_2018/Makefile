data/raw_anonymized:
	python ../../src/anonymize_lmeds_data_filenames.py data/raw \
data/raw_anonymized ../SUBJECT_ANONYMIZATION_FILE.csv

data/Aggregated_Results.csv data/presurvey_cleaned.csv \
data/postsurvey_cleaned.csv data/postsurvey2_cleaned.csv: data/raw_anonymized 
	if [[ ! -e data/Aggregated_Results.csv \
	     || ! -e data/presurvey_cleaned.csv \
	     || ! -e data/postsurvey_cleaned.csv \
	     || ! -e data/postsurvey2_cleaned.csv ]]; then \
python clean_output_pilot_july_2018.py data/raw_anonymized \
data/Aggregated_Results.csv data/presurvey_cleaned.csv data/postsurvey_cleaned.csv \
data/postsurvey2_cleaned.csv; \
fi
	
preprocess: data/Aggregated_Results.csv \
data/presurvey_cleaned.csv data/postsurvey_cleaned.csv \
data/postsurvey2_cleaned.csv
	
geomphon-LMEDS_v-c925d74:
	bash download_lmeds.sh

deploy: geomphon-LMEDS_v-c925d74
	bash deploy_all.sh

distances/tmp:
	mkdir -p distances/tmp

distances/tmp/PAIRS_TMP.csv: distances/tmp
	@if [ -z ${TIMIT_FOLDER} ]; \
then echo "Original TIMIT audio files needed to calculate \
acoustic features (for no great reason); \nplease set the \
environment variable TIMIT_FOLDER to the folder containing \
TRAIN/ and \nTEST/, and make sure the audio files have been \
converted from NIST SPHERE format" > /dev/stderr; exit 1; \
elif [ -z ${TIMIT_AUDIO_EXTENSION} ]; \
then echo "WARNING: environment variable TIMIT_AUDIO_EXTENSION \
not set; assuming that the extension \nfor the converted wav \
files is '.riff' (the original .wav files are in NIST SPHERE \
format)" > /dev/stderr; TIMIT_AUDIO_EXTENSION=".riff"; \
fi; \
Rscript --vanilla \
distances/prepare_stimuli_for_distance_calculation.Rscript \
stimuli/item_meta_information.csv ${TIMIT_FOLDER} \
$$TIMIT_AUDIO_EXTENSION distances/tmp/PAIRS_TMP.csv

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
	@if [ -z ${TIMIT_FOLDER} ]; \
then echo "Original TIMIT audio files needed to calculate \
acoustic features (for no great reason); \nplease set the \
environment variable TIMIT_FOLDER to the folder containing \
TRAIN/ and \nTEST/, and make sure the audio files have been \
converted from NIST SPHERE format" > /dev/stderr; exit 1; \
elif [ -z ${TIMIT_AUDIO_EXTENSION} ]; \
then echo "WARNING: environment variable TIMIT_AUDIO_EXTENSION \
not set; assuming that the extension \nfor the converted wav \
files is '.riff' (the original .wav files are in NIST SPHERE \
format)" > /dev/stderr; TIMIT_AUDIO_EXTENSION=".riff"; \
fi; \
Rscript --vanilla \
distances/reshape_result_of_distance_calculation.Rscript \
$< ${TIMIT_FOLDER} $$TIMIT_AUDIO_EXTENSION $@

distances: distances/distances__normed_filterbank__dtw_pathlength.csv \
distances/distances__unnormed_filterbank__dtw_pathlength.csv \
distances/distances__normed_mfcc__dtw_pathlength.csv \
distances/distances__unnormed_mfcc__dtw_pathlength.csv \
distances/distances__normed_filterbank__dtw_sum.csv \
distances/distances__unnormed_filterbank__dtw_sum.csv \
distances/distances__normed_mfcc__dtw_sum.csv \
distances/distances__unnormed_mfcc__dtw_sum.csv \
clean-distances-tmp


stimuli/item_meta_information_with_distances.csv: distances
	Rscript --vanilla \
distances/merge_distances.Rscript \
stimuli/item_meta_information.csv \
stimuli/item_meta_information_with_distances.csv \
distances/distances__*.csv

clean-distances-tmp:
	rm -rf distances/tmp

clean-distances: clean-distances-tmp
	rm -f distances/distances_*.csv

clean-preprocessed-data:
	rm -f data/Aggregated_Results.csv data/postsurvey2_cleaned.csv \
data/postsurvey_cleaned.csv data/presurvey_cleaned.csv

clean-Rmd-output:
	rm -f *.html

clean-lmeds:
	rm -rf geomphon-LMEDS_v-c925d74 

clean-deploy:
	rm -rf deploy

clean: clean-Rmd-output clean-preprocessed-data clean-lmeds clean-deploy clean-distances
