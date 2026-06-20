function [results,rf]=block_search1(ind_0,estim,estimfull,estimpart,estimupd,multitest,test_func,...
    y,x,z,namey,namexos,namecomp,prests,boundsvar,dropna,strategy,alpha,f0_tdo,...
    t0_tdo,groups_pval,f0_bup,gam,eta,crit,m2prt_test,wreliab,depth,descent,bs_nmax,ncomp,varargin)
 
// PURPOSE: provides automatic block search algorithm
// adapted from Dorrnik (2009)
// ------------------------------------------------------------
// INPUT:
// * ind_0 = a vector of integers, the index of the
//   exogenous variables used in the starting model
// * estim = a string, the econometric problem to deal with
//   (such as ols, probit, sur, ...)
// * estimfull = a funtion, that provides the estimation with
//   full output in its results tlist
// * estimpart = a funtion, that provides the estimation with
//   only the output neeeded for testing the significance of
//   coefficients and model in its results tlist
// * estimpupd = a funtion, that supplement the results stored
//   by function estimpart to obtain all relevant estimation
//   results
// * multitest = a function, that performs the testing of an
//   estimated model against an encompassing one
// * test_func = a function, that performs the specification
//   tests
// * y = a (nobs x 1) vector of endogenous variables
// * x = a (nobs x k) matrix of exogenous variables that can
//   be present or absent in the final estimated model
// * z = a (nobs x m) matrix of exogenous variables that are
//   constrained to be in the final model
// * namey = a string, the name of the endogenous variable
// * namexos = a (k x l) vector of strings, the name of all
//   compulsory exogenous variables
// * namecomp = a (m x l) vector of strings, the name of all
//   exogenous variables
// * prests = a boolean, indicating whether there are ts in
//   list of variables
// * boundsvar = a string vector, the bounds of the regression
//   if any
// * dropna = a boolean, indicating whether the NA values has
//   been removed from the data
// * strategy = the strategy used by the user
// * alpha = the simplification significance level
// * f0_tdo = the top_down pre-test significance level
// * t0_tdo = the top_down Student significance level
// * groups_pval = vector of values for which coeeficients
//   that have a p-value greater than this value are
//   gathered to form a model included
// * f0_bup = the bottom-up pre-test significance level
// * gam = the F-tests significance level
// * eta = the specification tests significance level
    // * crit = the selection criterion used for selecting models
//   at the end of the process
// * m2prt_test = names of these tests
// * wreliab = the vector of reliability coefficients values
// * depth = the depth of the branches for which all
//   combinations of insignificant variables are removed
// ------------------------------------------------------------
// OUTPUT:
// * results = a tlist with:
//   - results('stage i expansion indexes') = the index of the
//    variables retained at the expansion phase of stage i
//   - results('stage i reduction results') = the results
//     tlist obtained at the end of the reduction phase
//   - results('final indexes') = the index of the exogenous
//     variables retained at the end of the process
//  * rf = the results tlist of teh final model
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
 
 
write(%io(2),' ','(a)')
write(%io(2),'Entering the block search process...','(a)')
 
stage='A'
s=1
convg=%f
ind_fus=ind_0
ind_si=ind_0
results=tlist(['results';'meth'],'block search')
num_expansion=1
num_reduction=1
grocer_i0=1
grocer_step=1
 
while ~convg then
   ind_exp=expansion(stage,ind_si,s,estim,estimfull,estimpart,estimupd,multitest,test_empty,...
      y,x,z,namey,namexos,namecomp,prests,boundsvar,dropna,strategy,alpha,3*f0_tdo,...
      3*t0_tdo,groups_pval,3*f0_bup,gam,eta,crit,m2prt_test,wreliab,depth,descent,bs_nmax,ncomp,varargin)
 
   grocer_i0=grocer_i0+1
   grocer_step=grocer_step+1
 
   if isempty(ind_exp) then
      if stage == 'A' then
         write(%io(2),'expansion in stage A leads to an empty model: you probably have no significant variable in your model','(a)')
      else
         ind_exp=ind_exp0
      end
   end
 
   ind_exp0=ind_exp
   if stage == 'A' | stage == 'C' then
      results(1)($+1)='stage '+stage+' expansion indexes'
   else
      results(1)($+1)='stage '+stage+' expansion indexes # '+string(num_expansion)
   end
   results($+1)=ind_exp
 
   res_stage=automatic1(estim,estimfull,estimpart,estimupd,multitest,test_func,...
      y,x(:,ind_exp),z,namey,namexos(ind_exp),namecomp,prests,boundsvar,dropna,strategy,alpha,f0_tdo,...
      t0_tdo,groups_pval,f0_bup,gam,eta,crit,m2prt_test,wreliab,depth,descent,ncomp,varargin)
 
   if stage == 'A' | stage == 'C' then
      results(1)($+1)='stage '+stage+' reduction results'
   else
      results(1)($+1)='stage '+stage+' reduction results # '+string(num_reduction)
   end
   results($+1)=res_stage
 
   rf=res_stage('final model')
 
   if isempty(rf) then
      convg=%t
 
   else
      namex=rf('namex')
      for j=1:rf('nvar')
        ind_si=[ind_si find(namexos == namex(j))]
      end
      ind_si= unique(ind_si)
      ind_fusnew=unique([ind_fus ind_si])
      if stage == 'A' then
         stage='B'
         s=1
 
      elseif stage == 'C' then
         stage='D'
         s=4
 
      elseif size(ind_fusnew,2) == size(ind_fus,2) then
         if stage == 'B' then
            stage='C'
            s=2
            num_reduction=1
            num_expansion=1
         else
            convg=%t
         end
 
      else
         num_reduction=num_reduction+1
         num_expansion=num_expansion+1
         if stage == 'D' then
            s=1
         end
      end
      ind_fus=ind_fusnew
   end
end
 
results(1)($+1)='final model'
results(1)($+1)='final indexes'
results('final model')=rf
results('final indexes')=ind_si
 
endfunction
