.DEFAULT_GOAL := preprocess

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
data/presurvey_cleaned.csv data/postsurvey_cleaned.csv data/postsurvey2_cleaned.csv
	
geomphon-LMEDS_v-c925d74:
	bash download_lmeds.sh

deploy: geomphon-LMEDS_v-c925d74
	bash deploy_all.sh
	
clean-preprocessed-data:
	rm -f data/Aggregated_Results.csv data/postsurvey2_cleaned.csv \
data/postsurvey_cleaned.csv data/presurvey_cleaned.csv

clean-Rmd-output:
	rm -f *.html

clean-lmeds:
	rm -rf geomphon-LMEDS_v-c925d74 

clean-deploy:
	rm -rf deploy

clean: clean-Rmd-output clean-preprocessed-data clean-lmeds clean-deploy
