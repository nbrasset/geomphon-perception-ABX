# the hunt for NAs

mod1_df <- as.data.frame(mod1)



# saving the data frame in R format
#save(fit, file="fit2_mar_18_2019.RData")


# taking only the fixed effects
beta <- mod1_df[,grepl("beta", colnames(mod1_df))]
###beta <- beta[,-1] # excludes the intercept

mean(beta$`beta_cns_pos[1]`)
mean(beta$`beta_cns_pos[2]`)
mean(beta$`beta_cns_neg[1]`)
mean(beta$`beta_oth[1]`)

nas<-is.na(mod1_df)



# creating a list of the fixed effects variables, in the order in which they were used in the model that was run
#( cn <- colnames(model.matrix(~1+STEP_PAIR_COLL*EXPERIMENT+TIME_LAG, diff_data)) )
##cn <- cn[-1] # excludes the intercept


# creating an empty data frame that will be used in the plot
df <- data.frame(matrix(nrow=ncol(beta), ncol=0, data=NA, dimnames=list(c(),c())))

# creating a column "effect" with the parameter names
#df$effect <- factor(cn)

# completing information in the data frame for plotting
for (i in 1:nrow(df)){
  
  # the mean of the posterior
  df[i,"mean"] <- mean(beta[,i])
  
  # probability that the posterior is smaller/greater than zero
  df[i,"probability_smaller"] <- mean(beta[,i]<0)
  df[i,"probability_bigger"] <- mean(beta[,i]>0)
  
  # range of the posterior (min / max)
  df[i,"min"] <- min(beta[,i])
  df[i,"max"] <- max(beta[,i])
  
  # 95% credible intervals
  df[i,"l95"] <- unname(quantile(beta[,i],probs=0.025))
  df[i,"h95"] <- unname(quantile(beta[,i],probs=0.975))
  
}

df$names<- 
  c( "intercept",
     "steps 0_3 vs steps 1_4",
     "steps 1_4 vs steps 2_5",
     "steps 2_5 vs steps 3_6",
     "steps 3_6 vs steps 4_7",
     "steps 4_7 vs steps 5_8",
     "steps 5_8 vs steps 6_9",
     "steps 6_9 vs steps 7_10",
     "Phoneme vs. Duration+Pitch",
     "Phonmeme vs. Duration",
     "Phoneme vs. Pitch",
     "250ms ISI vs 500ms ISI",
     "500ms ISI vs 1000ms ISI",
     "1000ms ISI vs 1500ms ISI",
     "Duration +Pitch:steps 0_3 vs steps 1_4",
     "Duration +Pitch:steps 1_4 vs steps 2_5",
     "Duration +Pitch:steps 2_5 vs steps 3_6",
     "Duration +Pitch:steps 3_6 vs steps 4_7",
     "Duration +Pitch:steps 4_7 vs steps 5_8",
     "Duration +Pitch:steps 5_8 vs steps 6_9",
     "Duration +Pitch:steps 6_9 vs steps 7_10",
     "Duration:steps 0_3 vs steps 1_4",
     "Duration:steps 1_4 vs steps 2_5",
     "Duration:steps 2_5 vs steps 3_6",
     "Duration:steps 3_6 vs steps 4_7",
     "Duration:steps 4_7 vs steps 5_8",
     "Duration:steps 5_8 vs steps 6_9",
     "Duration:steps 6_9 vs steps 7_10",
     "Pitch:steps 0_3 vs steps 1_4",
     "Pitch:steps 1_4 vs steps 2_5",
     "Pitch:steps 2_5 vs steps 3_6",
     "Pitch:steps 3_6 vs steps 4_7",
     "Pitch:steps 4_7 vs steps 5_8",
     "Pitch:steps 5_8 vs steps 6_9",
     "Pitch:steps 6_9 vs steps 7_10")


df$names<-as.factor(df$names)

write.csv(df, file="beta_summary.csv")

# plotting the posteriors
ggplot(data=df, aes(x=mean, y=names)) + theme_bw() +
  geom_vline(aes(xintercept=0), size=1, linetype=2, col=gray(0.2)) + 
  geom_errorbarh(aes(xmax=max, xmin=min),height=0, size=1.3, col="#009E73") + # green is min and max 
  geom_errorbarh(aes(xmax=l95, xmin=h95),linetype=1,height=0.2,size=1.5,col="#D55E00") + # red is 95% credible interval 
  geom_point(size=2)+
  scale_y_discrete(limits=rev(df$names))+
  
  theme(axis.title.y=element_text(size=30, angle=90),
        axis.title.x=element_text(size=22, angle=0),
        axis.text.x=element_text(size=18, color="black"),
        axis.text.y=element_text(size=14, color="black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line.x = element_line(colour = "black")) + 
  ylab(" ") + xlab( expression(paste("Estimated difference (", hat(beta),")")))
