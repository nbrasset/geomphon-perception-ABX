rm(list=ls())
library(dplyr)
library(tidyr)
library(lme4)

results<-read.csv("geomphon_pilot_results_for_analysis.csv")
results<-select(results, subject_id, tripletid, delta_dist_sub, subject_language, user_corr)


#make up geomphon scores 

tripletid<-levels(results$tripletid)
var1 <- rnorm(140, .6, .2)
var2 <- rnorm(140, .9, .2)
var3 <- rnorm(140, .1, .2)  

geom_scores<-cbind(tripletid,var1,var2,var3)
geom_scores<-as.data.frame(geom_scores)

m1_dat <- dplyr::left_join(geom_scores,results,by="tripletid")

m1_dat$var1 <- as.numeric(as.character(m1_dat$var1))
m1_dat$var2 <- as.numeric(as.character(m1_dat$var2))
m1_dat$var3 <- as.numeric(as.character(m1_dat$var3))

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







# model code
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
# fitting model 1


library(rstan)
#options(mc.cores= parallel::detectCores())
fit <- stan(model_code=model_code_glmm, 
            data=stanDat,
            iter=3000, # number of iterations in each chain
            chains=4) # number of chains
            #control=list(adapt_delta=0.99, max_treedepth = 15) # this is not obligatory, only in order to facilitate model convergence and avoid divergent transitions


#######################
#MODEL 1 VERIFICATION


# checking the chains
traceplot(fit, inc_warmup=F)

# checking that the Rhat is always 1 for all model parameters
model_sum <- summary(fit, probs=c(0.025,0.975))$summary
rhats <- model_sum[,"Rhat"]
round(summary(rhats),2) # everything should be 1 -- if not, model did not converge; in that case, try running the model again doubling the number of iterations per chain
( na <- model_sum[is.na(rhats),"Rhat"] ) # if parameters without Rhat are only those used in the random effects correlations, then it's not a problem


