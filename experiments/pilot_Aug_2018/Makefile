triplet-list:
	python ../../src/textgrid_to_abx_item_file_word.py word \
stimulus_construction/amelia_vowels.TextGrid \
stimulus_construction/amelia_consonants.TextGrid \
stimulus_construction/ewan.TextGrid \
--excluded-words=SAY,AGAIN,sp0 > ABX_ITEM_FILE.item \
&& Rscript --vanilla add_meta_information_to_item_file.Rscript \
ABX_ITEM_FILE.item ABX_ITEM_FILE_COMPLETE.item \
&& abx-task ABX_ITEM_FILE_COMPLETE.item ABX_TASK_FILE.task \
-o word -a speaker -b CV context \
&& python ../../src/task2txt.py ABX_TASK_FILE.task ABX_TASK_FILE.csv \
&& Rscript --vanilla add_meta_information_to_triplet_file.Rscript \
ABX_TASK_FILE.csv ABX_ITEM_FILE_COMPLETE.item triplets.csv
