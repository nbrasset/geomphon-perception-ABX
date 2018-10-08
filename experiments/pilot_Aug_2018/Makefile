triplet-list:
	python ../../src/textgrid_to_abx_item_file_word.py word \
stimuli/amelia_vowels_ONLY_TARGET_CHECKED.TextGrid,amelia_vowels.wav \
stimuli/amelia_consonants_ONLY_TARGET_CHECKED.TextGrid,amelia_consonants.wav \
stimuli/ewan_ONLY_TARGET_CHECKED.TextGrid,ewan.wav \
--excluded-words=SAY,AGAIN,sp0 > ABX_ITEM_FILE.item \
&& Rscript --vanilla add_meta_information_to_item_file.Rscript \
ABX_ITEM_FILE.item ABX_ITEM_FILE_COMPLETE.item \
&& abx-task ABX_ITEM_FILE_COMPLETE.item ABX_TASK_FILE.task \
-o word -a speaker -b CV context \
&& python ../../src/task2txt.py ABX_TASK_FILE.task ABX_TASK_FILE.csv \
&& Rscript --vanilla add_meta_information_to_triplet_file.Rscript \
ABX_TASK_FILE.csv ABX_ITEM_FILE_COMPLETE.item triplets.csv

