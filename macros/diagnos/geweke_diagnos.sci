function results=geweke_diagnos(draws,pct_taper,n_groups)
 
// PURPOSE: computes Geweke''s convergence diagnostics NSE, RNE
//          and IF (numerical std error, relative numerical
//          efficiencies and inefficiencies)
// ------------------------------------------------------------
// INPUT:
// * draws = a matrix or a hypermatrix colecting the draws of
//   a set of parmaeters (the draw dimension must be the last
//   one
// * pct_taper = a number, the % used to taper the window in t
// * n_groups = a number, the number of draws that are
//   aggregated before performing the correlations
// ------------------------------------------------------------
// OUTPUT:
// results = a results tlist with:
// -  results('meth') = 'geweke diagnostic on tvp var'
// -  results('nse') = numerical std error assuming no serial
//    correlation for a given variable
// -  results('taper pct') = the % used to taper the window in t
// -  results('size of groups') =  the number of draws that are
//    aggregated before performing the correlations
// -  results('tapered NSE') =  a matrix, with the same size
//    as the original variable, the numerical std error using
//    autocovariance tapered estimate
// -  results('tapered efficiency factor') =  a matrix, with
//    the same size as the original variable, measuring the
//    relative numerical efficiencies of the draws
// -  results('tapered inefficiency factor') =  a matrix, with
//    the same size as the original variable, measuring the
//    relative numerical inefficiencies of the draws
// -  results('median tapered inefficiency factor') = a
//    number, the median of the relative numerical
//    inefficiencies of the draws
// -  results('mean tapered inefficiency factor') = a
//    number, the mean of the relative numerical
//    inefficiencies of the draws
// -  results('min tapered inefficiency factor') = a
//    number, the min over the variables of the relative
//    numerical inefficiencies of the draws
// -  results('max tapered inefficiency factor') = a
//    number, the max over the variables of the relative
//    numerical inefficiencies of the draws
// -  results('10-th perc tapered inefficiency factor') = a
//    number, the 10-th percentile over the variables of the relative
//    numerical inefficiencies of the draws
// -  results('90-th perc tapered inefficiency factor') = a
//    number, the 90-th percentile over the variables of the relative
//    numerical inefficiencies of the draws
// -----------------------------------------------------------------
// REFERENCES: Geweke (1992), 'Evaluating the accuracy of
// sampling-based approaches to the calculation of posterior moments',
// in J.O. Berger, J.M. Bernardo, A.P. Dawid, and A.F.M. Smith (eds.)
// Proceedings of the Fourth Valencia International Meeting on
// Bayesian Statistics, pp. 169-194, Oxford University Press
// -----------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
// inspired from Matlab programs by Johannes Pfeifer,
// James P. LeSage and Siddartha Chib
 
[nargout,nargin] = argn(0)
 
if nargin < 3 then
   n_groups=100
end
if nargin < 2 then
   pct_taper=0.04
end
n_taper=round(pct_taper*n_groups)
size_draws=size(draws)
n_dims=size(size_draws,2)
ndraws=size_draws(n_dims)
str_size0=string(size_draws(1:n_dims-1))
str_colons=strcat(emptystr(n_dims-1,1)+':',',')
 
// set the step size and accordingly the
// effective number of draws used after rounding down
ns = floor(ndraws/n_groups);
n_draws = ns*n_groups;
execstr('draws=draws('+str_colons+',1:n_draws)')
// numerical standard error assuming no serial correlation
nse1=sum(draws .^2,n_dims)
//nse2=sum(draws,n_dims) .^2/n_draws
nse=sqrt(nse1-sum(draws,n_dims) .^2/n_draws)/n_draws
 
// create the (hyper-)matrices of results; use execstr because the
// dimension of the draw is variable
execstr('zeros_dims=zeros('+strcat(str_size0,',')+',n_groups)')
window_means=zeros_dims
window_uncentered_vars= window_means
 
for ig=1:n_groups;
   execstr('window_means('+str_colons+',ig)=sum(draws('+str_colons+',(ig-1)*ns+1:ig*ns),n_dims)/ns');
   execstr('window_uncentered_vars('+str_colons+',ig)=sum(draws('+str_colons+',(ig-1)*ns+1:ig*ns).^2,n_dims)/ns');
end;
total_means=sum(window_means,n_dims)/n_groups
total_vars=sum(window_uncentered_vars,n_dims)/n_groups-(total_means .^2)
 
// get autocovariance of grouped means
execstr('ones_dims=ones('+strcat('1'+emptystr(n_dims-1,1),',')+',n_groups)')
centered_window_means=window_means-ones_dims .*. total_means;
 
clear window_uncentered_vars window_means ;
autocov_grouped_means=zeros_dims
num_taper=zeros_dims
for ind_lag=0:n_groups-1
   execstr('autocov_grouped_means('+str_colons+',ind_lag+1)='+...
            'sum(centered_window_means('+str_colons+',ind_lag+1:n_groups)'+...
            '.*centered_window_means('+str_colons+',1:n_groups-ind_lag),n_dims)/n_groups');
   execstr('num_taper('+str_colons+',ind_lag+1)=ind_lag');
end;
 
clear centered_window_means ;
// numerical standard error with tapered autocovariance functions
for taper_index=1:size(n_taper,'*')
   taper=n_taper(taper_index);
   execstr('NSE_taper1=autocov_grouped_means('+str_colons+',1)')
   execstr('NSE_taper2=sum(autocov_grouped_means('+str_colons+',2:taper),n_dims)')
   execstr('NSE_taper3=sum(autocov_grouped_means('+str_colons+',2:taper).*num_taper('+str_colons+',2:taper),n_dims)')
   NSE_taper=sqrt((NSE_taper1+2*NSE_taper2-2*NSE_taper3/taper)/n_groups);
   if_taper=NSE_taper.^2 ./total_vars*n_draws;
   rne_taper=total_vars/n_draws./(NSE_taper.^2);
end
 
if_taper_col=if_taper(total_vars~=0)
if_taper_col=gsort(if_taper_col(:),'g','i')
nif=size(if_taper_col,1)
w2=nif/10-floor(nif/10)
w1=1-w2
if nif < 10 then
   if_10pct=if_taper_col(ceil(nif/10))
else
   if_10pct=w1*if_taper_col(floor(nif/10))+w2*if_taper_col(ceil(nif/10))
end
 
results=tlist(['results';'meth';'nse';'taper pct';'size of groups';...
'tapered NSE';'tapered efficiency factor';'tapered inefficiency factor';...
'median tapered inefficiency factor';'mean tapered inefficiency factor';...
'min tapered inefficiency factor';'max tapered inefficiency factor';...
'10-th perc tapered inefficiency factor';'90-th perc tapered inefficiency factor'],...
'geweke diagnostic',nse,pct_taper,n_groups,NSE_taper,rne_taper,if_taper,...
median(if_taper),mean(if_taper(total_vars~=0)),if_taper_col(1),if_taper_col($),...
if_10pct,w1*if_taper_col(nif-floor(nif/10))+w2*if_taper_col(nif-ceil(nif/10)))
 
endfunction
