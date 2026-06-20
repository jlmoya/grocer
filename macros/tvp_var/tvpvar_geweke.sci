function results=tvpvar_geweke(res,obj,pct_taper,n_groups)
 
// PURPOSE: computes Geweke''s convergence diagnostics
// numerical std error, relative numerical efficiencies and
// inefficiencies
// ------------------------------------------------------------
// INPUT:
// * res = a tvp var results tlist
// * obj = a string, the name of the examined field in the tvp
//   var
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
if nargin < 4 then
   n_groups=100
end
if nargin < 3 then
   pct_taper=0.04
end
n_taper=round(pct_taper*n_groups)
 
db_obj=res('.dat '+obj)
 
load(db_obj(1))
// calculate the size of the whole results for the object
execstr('size_data=size('+obj+')')
n_db=size(db_obj,1)
ndraws_perdb=size_data($)
size_data($)=ndraws_perdb*n_db
n_dims=size(size_data,2)
ndraws=size_data(n_dims)
ns = floor(ndraws/n_groups);
n_draws = ns*n_groups;
str_size0=string(size_data(1:n_dims-1))
str_colons=strcat(emptystr(n_dims-1,1)+':',',')
 
// create the (hyper-)matrices of results; use execstr because the
// dimension of the draws is unknown and can be different
execstr('zeros_dims=zeros('+strcat(str_size0,',')+',n_groups)')
window_means=zeros_dims
window_uncentered_vars= window_means
 
// because of the size of the stack, the results may be shared
// between several databases; the calculations must then be
// made database by database, which makes the programming
// more tedious
db=0
nse1=0
nse2=0
ig=1
 
ndraws_db=0
ndraws_ig=0
ndraws_used=0
while ndraws_used < ndraws
   start_index=0
   db=db+1
   load(db_obj(db))
   execstr('size_dbi=size('+obj+')')
   ni=min(size_dbi($),n_draws-ndraws_used+1)
   execstr('nse1=nse1+sum('+obj+'('+str_colons+',1:ni).^2,n_dims)')
   execstr('nse2=nse2+sum('+obj+'('+str_colons+',1:ni),n_dims)')
   while ndraws_db < ndraws_perdb & ndraws_used < ndraws
      ndraws_ig1=min(ns-ndraws_ig,ndraws_perdb-ndraws_db)
      execstr('window_means('+str_colons+',ig)=window_means('+str_colons+',ig)+sum('+obj+'('+str_colons+',start_index+[1:ndraws_ig1]),n_dims)/ns');
      execstr('window_uncentered_vars('+str_colons+',ig)=window_uncentered_vars('+str_colons+',ig)+sum('+obj+'('+str_colons+',start_index+[1:ndraws_ig1]).^2,n_dims)/ns');
      ndraws_db=ndraws_db+ndraws_ig1
      ndraws_ig=ndraws_ig+ndraws_ig1
      ndraws_used=ndraws_used+ndraws_ig1
      start_index=start_index+ndraws_ig1
      if ndraws_ig == ns then
         ig=ig+1
         ndraws_ig=0
      end
   end
   ndraws_db=0
end
 
nse=sqrt(nse1-(nse2 .^2)/ndraws_used)/ndraws_used
total_means=sum(window_means,n_dims)/n_groups
total_vars=sum(window_uncentered_vars,n_dims)/n_groups-(total_means .^2)
 
// get autocovariance of grouped means
execstr('ones_dims=ones('+strcat('1'+emptystr(n_dims-1,1),',')+',n_groups)')
centered_window_means=window_means-ones_dims .*. total_means;
 
clear window_uncentered_vars window_means ;
autocov_grouped_means=zeros_dims
num_taper=zeros_dims
for ind_lag=0:n_groups-1
   execstr('autocov_grouped_means('+str_colons+',ind_lag+1)= sum(centered_window_means('+...
           str_colons+',ind_lag+1:n_groups).*centered_window_means('+...
            str_colons+',1:n_groups-ind_lag),n_dims)/n_groups');
   execstr('num_taper('+str_colons+',ind_lag+1)=ind_lag');
end;
 
 
clear centered_window_means ;
// numerical standard error with tapered autocovariance functions
execstr('NSE_taper1=autocov_grouped_means('+str_colons+',1)')
execstr('NSE_taper2=sum(autocov_grouped_means('+str_colons+',2:n_taper),n_dims)')
execstr('NSE_taper3=sum(autocov_grouped_means('+str_colons+',2:n_taper).*num_taper('+str_colons+',2:n_taper),n_dims)')
NSE_taper=sqrt((NSE_taper1+2*NSE_taper2-2*NSE_taper3/n_taper)/n_groups);
if_taper=%nan*total_vars
rne_taper=%nan*total_vars
if_taper(total_vars~=0)=NSE_taper(total_vars~=0).^2 ./total_vars(total_vars~=0)*n_draws;
rne_taper(total_vars~=0)=total_vars(total_vars~=0)/n_draws./(NSE_taper(total_vars~=0).^2);
 
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
'geweke diagnostic on tvp var',nse,pct_taper,n_groups,NSE_taper,rne_taper,if_taper,...
median(if_taper),mean(if_taper(total_vars~=0)),if_taper_col(1),if_taper_col($),...
if_10pct,w1*if_taper_col(nif-floor(nif/10))+w2*if_taper_col(nif-ceil(nif/10)))
 
 
endfunction
