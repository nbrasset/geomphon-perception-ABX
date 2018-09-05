###################################################
###CLEAN PARTICIPANT OUTPUT GEOMPHON AUGUST PILOT#
##################################################
#last edit 17 3 Sept 2018 by Amelia


##################################################
##NB: to ADAPT THIS TO ANOTHER LMEDS EXPERIMENT
##-change filepath of files 
##-find max number of columns in the output file and update my_cols so it has that many arbitrary names 
##change cleaning methods at end to ensure that they are useful for your data

import os
import pandas as pd 
import numpy as np

#create a dataframe for all of the results the trials with empty columns
results = pd.DataFrame(columns=["A","B", "C", "D", "E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","BB","CC","DD","EE","FF","GG","HH"])

#create a dataframe for the survey information with empty columns
presurvey = pd.DataFrame(columns=["A","B", "C", "D", "E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","BB","CC","DD","EE","FF","GG","HH"])
postsurvey = pd.DataFrame(columns=["A","B", "C", "D", "E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","BB","CC","DD","EE","FF","GG","HH"])
postsurvey2 = pd.DataFrame(columns=["A","B", "C", "D", "E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","BB","CC","DD","EE","FF","GG","HH"])


#specify where all the output files are 
folderpath = '/Users/post-doc/Desktop/geomphon_pilot_analysis/raw_output'

#make a list of the filenames in the folder 
filenames = os.listdir(folderpath)
#if there's a file called .DS_Store remove it from the list- this is metadata and not an actual results file so we don't want it in the list
if ".DS_Store" in filenames: filenames.remove(".DS_Store")


###START LOOP iterating through these files
for i in filenames:
    #make up names for all the columns on the longest line-- here we use letters
    #these names don't matter they just allow it to read in without bugging since the amount of columns varies
    #python will fill in all the empty space with NaN or None
    my_cols= ["A", "B", "C", "D", "E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","BB","CC","DD","EE","FF","GG","HH"]
    
    #read in  one of the files in the folder of subject output into a dataframe
    thissubj = pd.read_csv(folderpath+"/"+i, names=my_cols, engine='python',encoding = "utf-8")
    
    #find all the lines in the output dataframe that start with the string "media_choice", and make them an obj called :"resultslines"
    resultslines = pd.DataFrame(thissubj.loc[thissubj["A"] == 'media_choice'])
    	
    #add a column to thissubj that gives the name of file this data came from(which is also the turkerid)
    resultslines['Name'] = i
    	
    #concatenate those new lines and the results DataFrame, replace the old results df with this new combined one.
    results = pd.concat([results,resultslines])
    
    #force column B to be a string
    thissubj.B = thissubj.B.astype(str)
    
    #now find the row that starts with the words valsurvey, presurvey 
    presurlines = pd.DataFrame(thissubj.loc[thissubj["B"] == '[presurvey'])

    #fill in the final coulmn with the name of the file/ the subject 
    presurlines['Name'] = i
    	
    #concatenate thoese line to the presurvey dataframe
    presurvey = pd.concat([presurvey,presurlines])
    
    #now find the row that starts with post survey
    postsurlines = pd.DataFrame(thissubj.loc[thissubj["B"] == '[postsurvey'])
    
    #fill in the final coulmn with the name of the file/ the subject 
    postsurlines['Name'] = i
    	
    #concatenate thoese line to the dataframe
    postsurvey = pd.concat([postsurvey,postsurlines])
    
    #now find the row that starts with post survey
    postsur2lines = pd.DataFrame(thissubj.loc[thissubj["B"] == '[postsurvey2'])
    
    #fill in the final coulmn with the name of the file/ the subject 
    postsur2lines['Name'] = i
    	
    #concatenate thoese line to the dataframe
    postsurvey2 = pd.concat([postsurvey2,postsur2lines])
    
    ### END OF LOOP


##############################
## CLEAN UP RESULTS DATAFRAME#
##############################


# drop columns that are not needed 
results = results.drop(columns=["A","AA","BB","CC","C","DD","D","E","EE","F","FF","GG","HH","H","I","J","K","L","Q","R","W","X","Y","Z","M","N"])

#give columns clearer titles
results= results.rename(index=str, columns={"Name":"subject","B":"trial_type","G": "tripletid","O":"S-order","P":"A_Order","S":"RT","T":"order","U":"first_sound","V":"second_sound"})

#remove extra characters. This is done in a stupid and verbose way because the "remove all the brackets" code broke.
results.tripletid=results.tripletid.str.replace('[','')
results.tripletid=results.tripletid.str.replace(']','')
results.trial_type=results.trial_type.str.replace('[','')
results.A_Order=results.A_Order.str.replace(']','')
results.subject=results.subject.str.replace(".csv","")

# write out to .csv  
results.to_csv("/Users/post-doc/Desktop/geomphon_pilot_analysis/Aggregated_Results.csv", index=False,encoding = "utf-8")

#################################
#CLEAN UP PRESURVEY DATAFRAME#
#################################
presurvey.to_csv("/Users/post-doc/Desktop/presurvey.csv")

#drop unneeded columns
presurvey = presurvey.drop(columns=["A","B","C","D","E","F","FF","GG","HH","H"])

#give columns clearer titles
presurvey = presurvey.rename(index=str, columns={ "G":"survey_time","Name":"subject","I":"years18-29","J": "years30-39yrs", "K":"years40-49yrs","L":"years50-59yrs","M":"years60-69yrs","N":"years69plus", "O":"handedness_L", "P":"handedness_R","Q":"lang_0_3","R":"lang_speak","S":"lang_understand","T":"live_with_lang_yes","U":"live_with_lang_no","V":"hear_vis_Y","W":"hear_vis_N","X":"speech_prob_Y","Y":"speech_prob_N","Z":"ling_course_Y","AA":"ling_course_N","BB":"phonet_class_Y","CC":"phonet_class_N","DD":"phonog_class_Y","EE":"phonog_class_N"})

#remove .csv from teh subject column
presurvey.subject=presurvey.subject.str.replace(".csv","")

# write out to .csv  
presurvey.to_csv("/Users/post-doc/Desktop/geomphon_pilot_analysis/presurvey_cleaned.csv", index=False,encoding = "utf-8")

################################
#CLEAN UP POSTSURVEY1 DATAFRAME#
################################

postsurvey=postsurvey.drop(columns=["A","B","C","D","E","F","H","HH"])
postsurvey= postsurvey.rename(index=str, columns={"G":"survey_time","I":"chrome","J":"firefox","K":"IE","L":"safari","M":"opera","N":"other","O":"don't know","P":"headphones ","Q":"speakers","R":"earbuds","S":"very bad","T":"bad","U":"normal","V":"good","W":"very good","X":"distractions_yes","Y":"distractions_no","Z":"wireless","AA":"wired","BB":"very_slowly","CC":"slowly","DD":"tolerably_so","EE":"pretty_fast","FF":"no_loading_time","GG":"satisfaction","Name":"subject"})
postsurvey.subject=postsurvey.subject.str.replace(".csv","")
postsurvey.to_csv("/Users/post-doc/Desktop/geomphon_pilot_analysis/postsurvey_cleaned.csv", index=False,encoding = "utf-8")

###############################
#CLEAN UP POSTSURVEY2 DATAFRAME#
###############################

postsurvey2=postsurvey2.drop(columns=["A","AA","B","BB","C","CC","D","DD","E","EE","F","FF","GG","HH","H","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"])
postsurvey2= postsurvey2.rename(index=str, columns={"G":"survey_time","I":"comments","J":"experiment_topic","Name":"subject"})
postsurvey2.subject=postsurvey2.subject.str.replace(".csv","")
postsurvey2.to_csv("/Users/post-doc/Desktop/geomphon_pilot_analysis/postsurvey2_cleaned.csv", index=False,encoding = "utf-8")





