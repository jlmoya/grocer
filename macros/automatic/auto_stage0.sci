function [results,done,indxf_0,list_models]=auto_stage0(results,estimpart,estimupd,multitest,test_func,y,x,z,namex,namecomp,r00,alpha,f0_tdo,t0_tdo,f0_bup,eta,ncomp,list_vararg)
 
// PURPOSE: eliminates variables whose joint significance is
// lower than f0_sig under the condition that no diagnostic
// fails
// ------------------------------------------------------------
// INPUT:
// * results = a results tlist collecting part of the
//   automatic results
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
// * z = a (nobs x l) matrix of exogenous variables that are
//   constrained to be in the final model
// * namex = a (k x l) vector of strings, the name of all
//   compulsory exogenous variables
// * namecomp = a (m x l) vector of strings, the name of all
//   exogenous variables
// * r00 = results of the estimation of the general model
// * alpha = the simplification significance level
// * f0_tdo = the top_down pre-test significance level
// * t0_tdo = the top_down Student significance level
// * f0_bup = the bottom-up pre-test significance level
// * eta = a vector equal to the significance levels for the
//   specification tests
// * varargin = variable arguments passed to function estimpart
// ------------------------------------------------------------
// OUTPUT:
// * results = the upadated results tlist collecting part of
//   the automatic results
// * done = %t if all variables are significant, %f otherwise
// * r0 = results structure of the final model (the one without
//  the eliminated variables) as provided by ols2
// * indxf: indexes in x of the remaining exogenous variables
// ------------------------------------------------------------
// NOTES:
// * used by automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2012
// http://grocer.toolbox.free.fr/grocer.html
 
// sort pvalues by decreasing order and save in indpvalue
// their indexes
 
ym = y-mean0(y);
[gpvalue,indpvalue]=gsort(r00('pvalue')(ncomp+1:$),'g','d')
 
list_models=list(1:size(x,2)+ncomp,r00)
 
if gpvalue(1) < alpha then
// the lowest tstat is nevertheless significant: the initial model is the final one!
   done=%t
   results('final model')=r00
   results('ending reason')='initial model=final model'
   indxf_0=[]
 
else
   nvar=r00('nvar')
   done=%f
   r0=r00
   count=1
   nmax=min([sum(gpvalue > t0_tdo) ; (sum(nvar)-ncomp)])
   fp=1
   pval=1
   p=ones(size(eta,1),1)
 
   while (fp >= f0_tdo) & count < nmax & pval > 0.317 then
   // eliminate the next less significant variable from the list
   // of exogenous variables
      count=count+1
      indxf_0=gsort(indpvalue(count:$),'g','i')'
   // estimate the new model with minimal output and use of a
   // preexisting tlist structure to save time
 
      r0=estimpart(r00,y,x(:,indxf_0),z,ncomp,indxf_0,list_vararg)
      [fstat,fp]=multitest(r0,r00)
      list_models($+1)=indxf_0
      list_models($+1)=r0
      pval=real(r0('pvalue')(find(indxf_0==indpvalue(count))))
   end
 
   [val,p]=test_func(r0)
   while or((p - eta) <= 0) & length(list_models) > 2 then
   // one of the specification tests fails, backtrack until
   // all specification tests are passed
      count=count-1
      list_models($)=null()
      list_models($)=null()
      r0=list_models($)
      [val,p]=test_func(r0)
   end
 
   if or((p-eta) <=0) then
   // the first model did not pass the specification tests;
      r0=r00
   end
 
   if (count == sum(nvar)) then
      // there is only one variable left in the model
      fp=multitest([],r00)
      if fp >= f0_tdo then
         done=%t
         results('final model')=[]
         results('ending reason')='stage 0 model is empty'
         return
       end
   end
 
   // update and complete the tlist structure corresponding to
   // the last regression
   indxf_0=gsort(indpvalue(count:$),'g','i')'
 
   r0=estimupd(r0,y,[namecomp ; namex],indxf_0,val,p,ncomp,list_vararg)
   results(1)($+1)='top-down model'
   results($+1)=r0
   results(1)($+1)='stage 0 model'
   results(1)($+1)='selected stage 0 model'
 
   // now undertake the bottom-up step
   // select all coefficient with p-value above the threshold
   // and test if the corresponding model is accepted against
   // the gum
   ind_sig=find(gpvalue < t0_tdo)
   if isempty(ind_sig) then
      results('stage 0 model')=r0
      results('selected stage 0 model')='top down model'
 
   else
      indxf=gsort(indpvalue(ind_sig(1):$),'g','i')'
      if indxf == indxf_0 then
         results(1)($+1)='bottom-up model'
         results('bottom-up model')=r0
         results('stage 0 model')=r0
         results('selected stage 0 model')='bottom-up model'
 
      else
         r=estimpart(r00,y,x(:,indxf),z,ncomp,indxf,list_vararg)
         [val,p]=test_func(r)
 
         if and(p > eta) then
         // the bottom-up model passes the specification tests:
         // it is therefore valid
 
            [fstat,fp]=multitest(r,r0)
 
            // update and complete the tlist structure corresponding to
            // the last regression
            r=estimupd(r,y,[namecomp;namex],indxf,val,p,ncomp,list_vararg)
            r('spec_test')=[val p]
            r(1)($+1)='indxf'
            r('indxf')=indxf
 
            results($+1)=r
 
            if fp > f0_bup then
               results('stage 0 model')=r
               results('selected stage 0 model')='bottom-up model'
               indxf_0=indxf
               list_models=list(indxf,r)
            else
               results('stage 0 model')=r0
               results('selected stage 0 model')='top down model'
            end
 
         else
            results('stage 0 model')=r0
            results('selected stage 0 model')='top down model'
         end
      end
   end
end
 
endfunction
 
