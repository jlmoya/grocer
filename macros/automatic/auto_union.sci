function [res,numx,accept]=auto_union(results,estimpart,estimupd,multitest,test_func,y,xpath,z,namexos,namecomp,r0,list1_2,nbmodst,ncomp,list_vararg)
 
// PURPOSE: automatic selection of a model by least-squares
// regressions; this function is the low-depth counterpart
// of general function automatic
// ------------------------------------------------------------
// INPUT:
// * results = a results automatic tlist, containing already
//   some parameters and results (GUM, stage 1 models,...)
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
// * xpath = a (nobs x k) matrix of exogenous variables that
//   were present at entry at the search paths which are
//   examined here
// * z = a (nobs x l) matrix of exogenous variables that are
//   constrained to be in the final model
// * namexos = a (k+l) vector of strings, the name of all
//   exogenous variables
// * r0 = a predefined tlist result whose needed fileds
//   already exist
// * list1_2 = a list with (3 x N) elements where
//   - N is the # of models found during stage 1
//   - each 3*k+1 (k=0,...,N-1) element is a vector with the
//     names of exogenous variables present in the regression
//   - each 3*k+2 element is a vector with the indexes of the
//     variabels withdrawn to obtain the regression
//   - each 3*k+3 element is a results tlist with the results
//     of the regression
// * nbmodst = the # of models found in the followed paths
// ------------------------------------------------------------
// OUTPUT:
// * res = the results tlist for the union model
// * numx = the column indexes in the matrix of exogenous
//   variables of the union model
// * accept = a vector of booleans, indicating whether the
//   models in the input list are accepted against their union
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
numx=list1_2(2)
for i=2:nbmodst
   numx=[numx , list1_2(3*i-1)]
end
numx=unique(numx)
 
res=estimpart(r0,y,x(:,numx),z,ncomp,[1:size(z,2) numx],list_vararg)
[val,p]=test_func(res)
res=estimupd(res,y,[namecomp;namexos],numx,val,p,ncomp,list_vararg)
 
accept = ~zeros(nbmodst,1)
for i=1:nbmodst
   if list1_2(3*i)('nvar') == res('nvar') then
      // selected model = union model; cannot perform
      // wald test, but must accept selected model !
      accept(i) = %t
   else
      [fstat,fp]=multitest(list1_2(3*i),res)
      accept(i) = (fp>gam)
   end
end
 
 
endfunction
