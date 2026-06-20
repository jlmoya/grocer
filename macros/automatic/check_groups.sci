function [results,r_checks,nbmodst1,list1_2]=check_groups(results,y,x,z,groups_pval,gpvalue,gam,eta,rmod,list1_2,nbmodst1)
 
// PURPOSE: estimate models with variables whose significance
// is greater than prespecified levels, whose strigency is
// increasing and stops whenever the model is not rejected
// against the stage 0 model or specification tests are
// rejected
// ------------------------------------------------------------
// REFERENCES:
// Krolzig, H.-M. and Hendry, D.F. (2001): "Computer Automation
//  of General-to-Specific Model Selection Procedures", Journal
// of Economic Dynamics and Control, 25 (6-7), 831-866.
// ------------------------------------------------------------
// INPUT:
// * results = an automatic tlist results
// * y = vector of the endogenous variable
// * z = matrix of the compulsory variables (the ones that must
//   be in the regression whatever significance they have)
// * x = matrix of the exogenous variables
// * groups_pval = a vector of significance levels ordered from
//   the lowest to the greatest
// * gpvalue = the vector of p-values from the previous
//  (stage 0) regression
// * indpvalue1_0 = the corresponding vector of indexes in the
//   list of initial variables
// * gam = the significance-level of F-tests
// * eta = a vector equal to the significance levels for the
//   specification tests
// * rmod = a tlist defined by def_results
// * list1_2 = the list of models selected before
// * nbmodst1 = the corresponding number of models
// * indcte = the booelan indicating the presence or the
//   absence of the constant in the regression
// ------------------------------------------------------------
// OUTPUT:
// * results = an automatic tlist results
// * r_checks = the first estimated model that is accepted
//   against the initial one or the last that passes the
//   specification tests
// * nbmodst1 = the number of models selected at the end of
//   stage 1
// * list1_2 = the list of models selected at the end of
//   stage 1
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2014
// http://grocer.toolbox.free.fr/grocer.html
 
 
results(1)($+1)='checking process'
ind_check=find(gpvalue < groups_pval($))
if isempty(ind_check) then
// all variables are not significant even at the lowest level
   r_checks=[]
   results('checking process')=[]
   return
end
 
fp=0
i=1
p=0
nz=size(z,2)
nvar_0=size(gpvalue,1)
 
while ((fp < gam) | or(p < eta)) & (i <= size(groups_pval,1)) then
   ind_check=find(gpvalue < groups_pval(i))
   if ~isempty(ind_check) then
      indxf=[1:nvar_0]
      indxf(ind_check)=[]
      r_checks=estimpart(r1_0,y,x(:,indxf),z,nz,indxf)
      [val,p]=test_func(r_checks)
      [fstat,fp]=waldf0(r_checks,results('initial model'))
   end
   i=i+1
end
 
if i == size(groups_pval,1)+1 then
   results('checking process')=[]
 
else
   p$=string(groups_pval(i-1))
   r_checks=estimupd(r_checks,y,[namecomp;namexos],indxf,val,p,nz,varargin(:))
   results('checking process')=r_checks
   list1_2($+1)=['variables with t-probs intially > '+p$+' eliminated:' ; r1_0('namex')(ind_check)]
   list1_2($+1)=indxf
   list1_2($+1)=r_checks
   nbmodst1=nbmodst1+1
end
 
endfunction
 
