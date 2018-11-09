rm(list=ls())
library(plyr)
library(dplyr)
library(lme4)
library(rstan)
  rstan_options(auto_write = TRUE)
library(ggplot2)

################################################
#Analysis #1:  assign geomphon score by phoneme#
################################################


results<-read.csv("geomphon_pilot_results_for_analysis.csv")
results<-select(results, subject_id, tripletid, delta_dist_sub, subject_language, user_corr, phone_OTH,phone_TGT,phone_OTH)



# import sample geom scores from E's email
example_geom_scores<-read.delim("median_scores_english_variants.csv", header=T, sep=";")

#find unique scores
econ<-unique(example_geom_scores$econ_med)
loc<-unique(example_geom_scores$loc_med)
glob<-unique(example_geom_scores$glob_med)

#repeat them to create a vector of length 140 to match our number of stimuli
var1<-rep_len(econ,140)
var2<-rep_len(loc,140)
var3<-glob[1:140]
tripletid<-levels(results$tripletid)


geom_scores<-cbind(tripletid,var1,var2,var3)
geom_scores<-as.data.frame(geom_scores)

#join geomphon scores to results column
m1_dat <- dplyr::left_join(geom_scores,results,by="tripletid")

m1_dat$var1 <- as.numeric(as.character(m1_dat$var1))
m1_dat$var2 <- as.numeric(as.character(m1_dat$var2))
m1_dat$var3 <- as.numeric(as.character(m1_dat$var3))

write.csv(m1_dat, file="m1_dat.csv")

##### Frequentist model #####
m_1 <- glmer(user_corr ~ delta_dist_sub+(var1+var2+var3)*subject_language+
               (1+delta_dist_sub+var1+var2+var3|subject_id)+(1+subject_language|tripletid), 
             data = m1_dat,
             family = binomial,
             control = glmerControl(optimizer = "bobyqa"))

m_2 <- glmer(user_corr ~ delta_dist_sub+(var1+var2+var3)*subject_language+
               (1|subject_id)+(1|tripletid), 
             data = m1_dat,
             family = binomial,
             control = glmerControl(optimizer = "bobyqa"))

print(summary(m_2),cor=F)



##########################
##### Bayesian model #####
##########################


################
#Set up model #1


# creating model matrices, model 1
x <- unname(model.matrix(~1+delta_dist_sub+(var1+var2+var3)*subject_language, m1_dat)) # matrix for fixed effects
attr(x, "assign") <- NULL
x_u <- unname(model.matrix(~1, m1_dat)) # matrix for random effects for subjects
attr(x_u, "assign") <- NULL
x_w <- unname(model.matrix(~1, m1_dat)) # matrix for random effects for items 
attr(x_w, "assign") <- NULL





# data list, model 1
stanDat <- list(accuracy = as.integer(m1_dat$user_corr),         # dependent variable
                
                subj=as.numeric(factor(m1_dat$subject_id)),  # subject id
                item=as.numeric(factor(m1_dat$tripletid)),   # item id
                
                N_obs = nrow(m1_dat),                     # number of observations
                
                N_coef = ncol(x),                      # number of fixed effects
                N_coef_u = ncol(x_u),                    # number of random effects for subjects
                N_coef_w = ncol(x_w),                    # number of random effects for items
                
                x = x,                                 # fixed effects matrix
                x_u = x_u,                               # random effects matrix - subjects
                x_w = x_w,                               # random effects matrix - items
                
                N_subj=length(unique(m1_dat$subject_id)),         # number of subjects
                N_item=length(unique(m1_dat$tripletid)) )  # number of items




################
# MODEL CODE
######################
model_code_glmm <- "
data {
int<lower=0> N_obs;                    //number of observations
int<lower=0> N_coef;                   //fixed effects
int<lower=0> N_coef_u;                 //random effects for subjects
int<lower=0> N_coef_w;                 // random effects for items

// subjects
int<lower=1> subj[N_obs];          //subject id  
int<lower=1> N_subj;               //number of subjects

// items
int<lower=1> item[N_obs];          //item id
int<lower=1> N_item;               //number of items

matrix[N_obs, N_coef] x;           //fixed effects design matrix
matrix[N_obs, N_coef_u] x_u;         //subject random effects design matrix
matrix[N_obs, N_coef_w] x_w;         //item random effects design matrix

int accuracy[N_obs];              // accuracy
}

parameters {

vector[N_coef] beta;                    // vector of fixed effects parameters 

vector<lower=0> [N_coef_u] sigma_u;     // subject sd
cholesky_factor_corr[N_coef_u] L_u;   // correlation matrix for random intercepts and slopes subj
matrix[N_coef_u,N_subj] z_u;

vector<lower=0> [N_coef_w] sigma_w;     // item sd
cholesky_factor_corr[N_coef_w] L_w;    // correlation matrix for random intercepts and slopes item
matrix[N_coef_w,N_item] z_w;

real sigma_e;                // residual sd
}

transformed parameters{

matrix[N_coef_u,N_subj] u;   // subjects random effects parameters 
matrix[N_coef_w,N_item] w;   // items random effects parameters
vector[N_obs] mu;

// variance-covariance matrix for the random effects of subjects (intercept, slopes & correlations)
{matrix[N_coef_u,N_coef_u] Lambda_u;
Lambda_u = diag_pre_multiply(sigma_u, L_u);
u = Lambda_u * z_u;
}

// variance-covariance matrix for the random effects of items (intercept, slopes & correlations)
{matrix[N_coef_w,N_coef_w] Lambda_w;
Lambda_w = diag_pre_multiply(sigma_w, L_w);
w = Lambda_w * z_w;
}

mu = sigma_e + x * beta; // first define mu in terms of error (sigma_e) and fixed effects only (beta)

for (i in 1:N_obs){
for (uu in 1:N_coef_u)
mu[i] = mu[i] + x_u[i,uu] * u[uu, subj[i]]; // adding to mu the subjects random effects part 
for (ww in 1:N_coef_w)
mu[i] = mu[i] + x_w[i,ww] * w[ww, item[i]]; // adding to mu the items random effects part
}
}

model {

// all priors here are weakly informative priors with a normal distribution (because the logit link function transforms the proportions into a normally distributed variable)
// check what is the appropriate prior distribution for each of the variables in the data set and modify accordingly

sigma_u ~ normal(0,1);
sigma_w ~ normal(0,1);

sigma_e ~ normal(0,10); // the mean (0) lies between -10 and 10 on logit scale, i.e., between very close to 0 and very close to 1 on probability scale (hence, it's a weakly informative prior)
beta ~ normal(0,10);                    

L_u ~ lkj_corr_cholesky(2.0); // 2.0 prior indicates no prior knowledge about the correlations in the random effects
L_w ~ lkj_corr_cholesky(2.0);

to_vector(z_u) ~ normal(0,1);
to_vector(z_w) ~ normal(0,1);

accuracy ~ bernoulli_logit(mu); // likelihood (the data)
}

// the following block generates some variables that might be interesting to look at in some cases, but not necessarily
generated quantities{

matrix[N_coef_u,N_coef_u] Cor_u;
matrix[N_coef_w,N_coef_w] Cor_w;

int pred_correct[N_obs];
real log_lik[N_obs];
real diffP[N_coef];

Cor_u = tcrossprod(L_u); // if you want to look at the subjects random effects correlations
Cor_w = tcrossprod(L_w); // if you want to look at the items random effects correlations

// the following loop translates the beta coefficients from logit scale (beta) to probability scale (diffP)
for (j in 1:(N_coef)){
diffP[j] = inv_logit(sigma_e + beta[j]) - inv_logit(sigma_e - beta[j]);
}

// generating the model's log likelihood to be used, for example, in model comparison
for (i in 1:N_obs){
pred_correct[i] = bernoulli_rng(inv_logit(mu[i]));
log_lik[i] = bernoulli_logit_lpmf(accuracy[i]|mu[i]);
}
}"

####################
# FITTING MODEL 1

library(rstan)
#options(mc.cores= parallel::detectCores())
fit <- stan(model_code=model_code_glmm, 
            data=stanDat,
            iter=3000, # number of iterations in each chain
            chains=4, # number of chains
            control=list(max_treedepth=15))#added in response to warning about divergent transitions
            #control=list(adapt_delta=0.99, max_treedepth = 15) # this is not obligatory, only in order to facilitate model convergence and avoid divergent transitions



##IF FIT ALREADY EXISTS, load fit
#fit <- readRDS("fit.rds")

#save the fit as an RDS 
saveRDS(fit, "fit.rds")



#######################
#MODEL 1 VERIFICATION


# checking the chains
traceplot(fit, inc_warmup=F)

# checking that the Rhat is always 1 for all model parameters
model_sum <- summary(fit, probs=c(0.025,0.975))$summary

rhats <- model_sum[,"Rhat"]
round(summary(rhats),2) # everything should be 1 -- if not, model did not converge; in that case, try running the model again doubling the number of iterations per chain
( na <- model_sum[is.na(rhats),"Rhat"] ) # if parameters without Rhat are only those used in the random effects correlations, then it's not a problem


modelfit <- as.data.frame(fit)
save(modelfit,file="modelfit.RData")


beta <- modelfit[,grepl("beta",colnames(modelfit))]
beta <- beta[,-1] # excluding the intercept

cn <- colnames(model.matrix(~1+delta_dist_sub+(var1+var2+var3)*subject_language, m1_dat))
cn <- cn[-1] # excluding the intercept

# creating data frame for plotting
df <- data.frame(matrix(nrow=ncol(beta), ncol=0, data=NA, dimnames=list(c(),c())))
df$effect <- factor(cn)

# completing info in data frame for plotting
for (i in 1:nrow(df)){
  
  # mean
  df[i,"mean"] <- mean(beta[,i])
  
  # probability
  df[i,"prob_smaller"] <- mean(beta[,i]<0)
  df[i,"prob_greater"] <- mean(beta[,i]>0)
  
  # range 
  df[i,"min"] <- min(beta[,i])
  df[i,"max"] <- max(beta[,i])
  
  # 95% credible intervals
  df[i,"l95"] <- unname(quantile(beta[,i],probs=0.025))
  df[i,"h95"] <- unname(quantile(beta[,i],probs=0.975))
  
  # 90% credible intervals
  df[i,"l90"] <- unname(quantile(beta[,i],probs=0.05))
  df[i,"h90"] <- unname(quantile(beta[,i],probs=0.95))
  
  # 85% credible intervals
  df[i,"l85"] <- unname(quantile(beta[,i],probs=0.075))
  df[i,"h85"] <- unname(quantile(beta[,i],probs=0.925))
  
  # 80% credible intervals
  df[i,"l80"] <- unname(quantile(beta[,i],probs=0.10))
  df[i,"h80"] <- unname(quantile(beta[,i],probs=0.90))
}

write.csv(df, file="modelfit_summary.csv")

# plotting
library(ggplot2)
ggplot(data=df, aes(x=mean, y=effect)) + theme_bw() +
  geom_vline(aes(xintercept=0), size=1, linetype=2, col=gray(0.2)) + 
  geom_errorbarh(aes(xmax=max, xmin=min),height=0, size=1.3, col="#009E73") +
  geom_errorbarh(aes(xmax=l95, xmin=h95),linetype=1,height=0.3,size=1.5,col="#D55E00") + # 95% credible intervals
  geom_errorbarh(aes(xmax=l85, xmin=h85),linetype=1,height=0.2,size=1.4,col="#56B4E9") + # 85% credible intervals
  geom_point(size=4) + 
  scale_y_discrete(limits=rev(cn)) +
  theme(axis.title.y=element_text(size=24, angle=90),
        axis.title.x=element_text(size=24, angle=0),
        axis.text.x=element_text(size=22, color="black"),
        axis.text.y=element_text(size=22, color="black"),
        #panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line.x = element_line(colour = "black")) + 
  ylab(" ") + 
  xlab( expression(paste("Estimated difference (", hat(beta),")")))

####MAKE AGGREGATE PLOTS-- accuracy vs. geomphon scores and acoustic distance. 
##################################################################################################

agg <- ddply(m1_dat, .(delta_dist_sub,var1,var2,var3),summarize, dv=mean(user_corr))

s<-ggplot(agg,aes(x=delta_dist_sub,y=dv)) +
  geom_jitter() + 
  geom_smooth(method="lm",se=T) +
  ggtitle("Acoustic distance vs. accuracy by triplet")
ggExtra::ggMarginal(s, type = "density")

r<-ggplot(agg,aes(x=var1,y=dv)) + 
  geom_jitter() + 
  geom_smooth(method="lm",se=T)+
  ggtitle("Econ vs. accuracy by triplet")
ggExtra::ggMarginal(r, type = "density")

q<-ggplot(agg,aes(x=var2,y=dv)) + 
  geom_jitter() + 
  geom_smooth(method="lm",se=T)+
  ggtitle("Loc  vs. accuracy by triplet")
ggExtra::ggMarginal(q, type = "density")

p<-ggplot(agg,aes(x=var3,y=dv)) + 
  geom_jitter() + 
  geom_smooth(method="lm",se=T) +
  ggtitle("Glob  vs. accuracy by triplet")
ggExtra::ggMarginal(p, type = "density")










################################################
#Analysis #2:  assign geomphon score by phoneme#
################################################

#open results file as results_2
results_2<-read.csv("geomphon_pilot_results_for_analysis.csv")
results_2<-select(results_2, subject_id, tripletid, delta_dist_sub, subject_language, user_corr, phone_OTH,phone_TGT,phone_OTH)
results_2<-as_tibble(results_2)

#specify which sounds are "native" and which are "non-native" (currently arbitrary)
results_2$phone_TGT_nat_non<-case_when(results_2$phone_TGT =="p"~ "native",
                               results_2$phone_TGT =="t"~ "native",
                               results_2$phone_TGT =="k"~ "native",
                               results_2$phone_TGT =="f"~ "native",
                               results_2$phone_TGT =="s"~ "nonnat",
                               results_2$phone_TGT =="θ"~ "nonnat",
                               results_2$phone_TGT =="ʃ"~ "nonnat",                
                               results_2$phone_TGT =="i"~ "native", 
                               results_2$phone_TGT =="æ"~ "native",
                               results_2$phone_TGT =="ʊ"~ "native",
                               results_2$phone_TGT =="ʌ"~ "nonnat", 
                               results_2$phone_TGT =="ɑ"~ "nonnat", 
                               results_2$phone_TGT =="u"~ "nonnat")

results_2$phone_OTH_nat_non<-case_when(results_2$phone_OTH =="p"~ "native",
                                results_2$phone_OTH =="t"~ "native",
                                results_2$phone_OTH =="k"~ "native",
                                results_2$phone_OTH =="f"~ "native",
                                results_2$phone_OTH =="s"~ "nonnat",
                                results_2$phone_OTH =="θ"~ "nonnat",
                                results_2$phone_OTH =="ʃ"~ "nonnat",                
                                results_2$phone_OTH =="i"~ "native", 
                                results_2$phone_OTH =="æ"~ "native",
                                results_2$phone_OTH =="ʊ"~ "native",
                                results_2$phone_OTH =="ʌ"~ "nonnat", 
                                results_2$phone_OTH =="ɑ"~ "nonnat", 
                                results_2$phone_OTH =="u"~ "nonnat")
#add a column to indicate whether the trial includes one native + one nonnative, or not
results_2$cross_lang<-ifelse((results_2$phone_OTH_nat_non=="nonnat")&(results_2$phone_TGT_nat_non=="native")|
                           (results_2$phone_OTH_nat_non=="native")&(results_2$phone_TGT_nat_non=="nonnat"),
                           "cross_lang","same_status")
# import sample geom scores from E's email
geom_scores_2<-read.delim("median_scores_english_variants.csv", header=T, sep=";")

#find unique scores
econ<-unique(geom_scores_2$econ_med)
loc<-unique(geom_scores_2$loc_med)
glob<-unique(geom_scores_2$glob_med)



#ASSIGN geomphon scores by phoneme 
results_2$glob<-case_when(results_2$phone_TGT =="p"~ glob[1],
                         results_2$phone_TGT =="t"~ glob[2],
                         results_2$phone_TGT =="k"~ glob[3],
                         results_2$phone_TGT =="f"~ glob[4],
                         results_2$phone_TGT =="s"~ glob[5],
                         results_2$phone_TGT =="θ"~ glob[6],
                         results_2$phone_TGT =="ʃ"~ glob[7],                
                         results_2$phone_TGT =="i"~ glob[8], 
                         results_2$phone_TGT =="æ"~ glob[9],
                         results_2$phone_TGT =="ʊ"~ glob[10],
                         results_2$phone_TGT =="ʌ"~ glob[11], 
                         results_2$phone_TGT =="ɑ"~ glob[12], 
                         results_2$phone_TGT =="u"~ glob[13])

results_2$loc<-case_when(results_2$phone_TGT =="p"~ loc[1],
                        results_2$phone_TGT =="t"~ loc[2],
                        results_2$phone_TGT =="k"~ loc[3],
                        results_2$phone_TGT =="f"~ loc[4],
                        results_2$phone_TGT =="s"~ loc[5],
                        results_2$phone_TGT =="θ"~ loc[6],
                        results_2$phone_TGT =="ʃ"~ loc[7],                
                        results_2$phone_TGT =="i"~ loc[8], 
                        results_2$phone_TGT =="æ"~ loc[9],
                        results_2$phone_TGT =="ʊ"~ loc[10],
                        results_2$phone_TGT =="ʌ"~ loc[11], 
                        results_2$phone_TGT =="ɑ"~ loc[12], 
                        results_2$phone_TGT =="u"~ loc[13])
         
results_2$econ<-case_when(results_2$phone_TGT =="p"~ econ[1],
                        results_2$phone_TGT =="t"~ econ[2],
                        results_2$phone_TGT =="k"~ econ[3],
                        results_2$phone_TGT =="f"~ econ[4],
                        results_2$phone_TGT =="s"~ econ[1],
                        results_2$phone_TGT =="θ"~ econ[2],
                        results_2$phone_TGT =="ʃ"~ econ[3],                
                        results_2$phone_TGT =="i"~ econ[4], 
                        results_2$phone_TGT =="æ"~ econ[1],
                        results_2$phone_TGT =="ʊ"~ econ[2],
                        results_2$phone_TGT =="ʌ"~ econ[3], 
                        results_2$phone_TGT =="ɑ"~ econ[4], 
                        results_2$phone_TGT =="u"~ econ[1])



#look at only the subset of trials where there is a native/non comparison 
results_2_cross<-subset(results_2, results_2$cross_lang=="cross_lang")
write.csv(results_2_cross, file="results_2_cross.csv")

##################################################
#Fit model 2 
#uses same model code from model1, with new data
#################################################


#NB this overwrites the model matrices from above! 

# creating model matrices, model 2
x <- unname(model.matrix(~1+delta_dist_sub+(econ+glob+loc)*subject_language, results_2_cross)) # matrix for fixed effects
attr(x, "assign") <- NULL
x_u <- unname(model.matrix(~1, results_2_cross)) # matrix for random effects for subjects
attr(x_u, "assign") <- NULL
x_w <- unname(model.matrix(~1, results_2_cross)) # matrix for random effects for items 
attr(x_w, "assign") <- NULL



# data list, model 2
stanDat2 <- list(accuracy = as.integer(results_2_cross$user_corr),         # dependent variable
                
                subj=as.numeric(factor(results_2_cross$subject_id)),  # subject id
                item=as.numeric(factor(results_2_cross$tripletid)),   # item id
                
                N_obs = nrow(results_2_cross),                     # number of observations
                
                N_coef = ncol(x),                      # number of fixed effects
                N_coef_u = ncol(x_u),                    # number of random effects for subjects
                N_coef_w = ncol(x_w),                    # number of random effects for items
                
                x = x,                                 # fixed effects matrix
                x_u = x_u,                               # random effects matrix - subjects
                x_w = x_w,                               # random effects matrix - items
                
                N_subj=length(unique(results_2_cross$subject_id)),         # number of subjects
                N_item=length(unique(results_2_cross$tripletid)) )  # number of items



library(rstan)
#options(mc.cores= parallel::detectCores())
fit2 <- stan(model_code=model_code_glmm, 
            data=stanDat2,
            iter=3000, # number of iterations in each chain
            chains=4, # number of chains
            control=list(max_treedepth=15))#added in response to warning about divergent transitions
#control=list(adapt_delta=0.99, max_treedepth = 15) # this is not obligatory, only in order to facilitate model convergence and avoid divergent transitions

#save fit 
saveRDS(fit2, "fit2.rds")

##OR IF FIT ALREADY EXISTS, load fit
fit2 <- readRDS("fit.rds")

#######################
#MODEL 2 VERIFICATION

# checking the chains
traceplot(fit2, inc_warmup=F)

# checking that the Rhat is always 1 for all model parameters
model_sum2 <- summary(fit2, probs=c(0.025,0.975))$summary

rhats <- model_sum2[,"Rhat"]

round(summary(rhats),2) # everything should be 1 -- if not, model did not converge; in that case, try running the model again doubling the number of iterations per chain
( na <- model_sum2[is.na(rhats),"Rhat"] ) # if parameters without Rhat are only those used in the random effects correlations, then it's not a problem


modelfit2 <- as.data.frame(fit2)
save(modelfit2,file="modelfit2.RData")


beta2 <- modelfit2[,grepl("beta",colnames(modelfit2))]
beta2 <- beta2[,-1] # excluding the intercept

cn <- colnames(model.matrix(~1+delta_dist_sub+(econ+glob+loc)*subject_language, results_2_cross))
cn <- cn[-1] # excluding the intercept

# creating data frame for plotting
df <- data.frame(matrix(nrow=ncol(beta2), ncol=0, data=NA, dimnames=list(c(),c())))
df$effect <- factor(cn)

# completing info in data frame for plotting
for (i in 1:nrow(df)){
  
  # mean
  df[i,"mean"] <- mean(beta2[,i])
  
  # probability
  df[i,"prob_smaller"] <- mean(beta2[,i]<0)
  df[i,"prob_greater"] <- mean(beta2[,i]>0)
  
  # range 
  df[i,"min"] <- min(beta2[,i])
  df[i,"max"] <- max(beta2[,i])
  
  # 95% credible intervals
  df[i,"l95"] <- unname(quantile(beta2[,i],probs=0.025))
  df[i,"h95"] <- unname(quantile(beta2[,i],probs=0.975))
  
  # 90% credible intervals
  df[i,"l90"] <- unname(quantile(beta2[,i],probs=0.05))
  df[i,"h90"] <- unname(quantile(beta2[,i],probs=0.95))
  
  # 85% credible intervals
  df[i,"l85"] <- unname(quantile(beta2[,i],probs=0.075))
  df[i,"h85"] <- unname(quantile(beta2[,i],probs=0.925))
  
  # 80% credible intervals
  df[i,"l80"] <- unname(quantile(beta2[,i],probs=0.10))
  df[i,"h80"] <- unname(quantile(beta2[,i],probs=0.90))
}

write.csv(df, file="modelfit2_summary.csv")

# plotting

ggplot(data=df, aes(x=mean, y=effect)) + theme_bw() +
  geom_vline(aes(xintercept=0), size=1, linetype=2, col=gray(0.2)) + 
  geom_errorbarh(aes(xmax=max, xmin=min),height=0, size=1.3, col="#009E73") +
  geom_errorbarh(aes(xmax=l95, xmin=h95),linetype=1,height=0.3,size=1.5,col="#D55E00") + # 95% credible intervals
  geom_errorbarh(aes(xmax=l85, xmin=h85),linetype=1,height=0.2,size=1.4,col="#56B4E9") + # 85% credible intervals
  geom_point(size=4) + 
  scale_y_discrete(limits=rev(cn)) +
  theme(axis.title.y=element_text(size=24, angle=90),
        axis.title.x=element_text(size=24, angle=0),
        axis.text.x=element_text(size=22, color="black"),
        axis.text.y=element_text(size=22, color="black"),
        #panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line.x = element_line(colour = "black")) + 
  ggtitle("Model 2: geomphon scores assigned by phoneme")+
  theme(plot.title = element_text(size = 24, face = "bold",hjust = 1))+
  ylab(" ") + 
  xlab(expression(paste("Estimated difference (", hat(beta),")")))



#Make aggregate plots 
################
agg2 <- ddply(results_2_cross, .(delta_dist_sub,econ,glob,loc),summarize, dv=mean(user_corr))

ggplot(agg2,aes(x=delta_dist_sub,y=dv)) +
  geom_point() + 
  geom_smooth(method="lm",se=T) +
  ggtitle("Acoustic distance vs. accuracy by triplet\n with scores assigned by phone")
ggExtra::ggMarginal(s, type = "density")

r<-ggplot(agg2,aes(x=econ,y=dv)) + 
  geom_point() +  
  geom_smooth(method="lm",se=T)+
  ggtitle("Econ vs. accuracy by triplet\n with scores assigned by phone")
ggExtra::ggMarginal(r, type = "density")

q<-ggplot(agg2,aes(x=glob,y=dv)) + 
  geom_point() + 
  geom_smooth(method="lm",se=T)+
  ggtitle("Glob  vs. accuracy by triplet\n with scores assigned by phone")
ggExtra::ggMarginal(q, type = "density")

p<-ggplot(agg2,aes(x=loc,y=dv)) + 
  geom_point() +  
  geom_smooth(method="lm",se=T) +
  ggtitle("loc  vs. accuracy by triplet\n with scores assigned by phone")
ggExtra::ggMarginal(p, type = "density")



