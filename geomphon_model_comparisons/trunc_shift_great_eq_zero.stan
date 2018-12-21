//fit_1

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

//NOTE: for our hypotheses, we want to constrain the value of beta.  so in order to have a truncated prior
//we specify in the parameters block what values are impossible.

parameters {

vector<lower=0>[N_coef] beta;            // vector of fixed effects parameters RIGHT NOW ALL CONSTRAINED TO BE POISITIVE 
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

beta ~ normal(1,10); 

L_u ~ lkj_corr_cholesky(2.0); // 2.0 prior indicates no prior knowledge about the correlations in the random effects
L_w ~ lkj_corr_cholesky(2.0);

to_vector(z_u) ~ normal(0,1);
to_vector(z_w) ~ normal(0,1);

accuracy ~ bernoulli_logit(mu); // likelihood (the data)
}



// the following block generates some variables that might be interesting to look at
//in some cases, but not necessarily
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
}
