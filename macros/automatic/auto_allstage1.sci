function [results,done,list1_2,nbmodst1]=auto_allstage1(results,estimfull,estimpart,estimupd,multitest,test_func,y,x,z,namexos,namecomp,r1_0,indx0,depth,alpha,eta,gam,groups_pval,list_models,...
ncomp,list_vararg)
 
// PURPOSE: in an automatic estimation, estimates all stage 1
// models
// ------------------------------------------------------------
// INPUT:
// * results = a results automatic tlist, containing already
//   some parameters and results (GUM)
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
// * z = a (nobs x l) matrix of exogenous variables that are
//   constrained to be in the final model
// * namexos = a (k+l) vector of strings, the name of all
//   exogenous variables
//   results
// * r1_0 = a predefined tlist result whose needed fields
//   already exist
// * indx0 = a integer vector, the index of the x variables
//   at entry in the function
// * depth = the depth of the branches for which all
//   combinations of insigficant variabales are removded
// * alpha = a scalar, the size of the significance tests of
//   individual coeffcients
// * eta = a vector equal to the significance depths for the
//   specification tests
// * gam = scalar, the size of the significance tests of
//   blocks of coeffcients
// * groups_pval = vector of values for which coeeficients
//   that have a p-value greater than this value are
//   gathered to form a model included
// ------------------------------------------------------------
// OUTPUT:
// * results = the extended results automatic tlist, containing
//   new results (stage 1 models)
// * done = a boolean, %t if the entry model is the good one
// * list1_2 = a list with (3 x N) elements where
//   - N is the # of models found during stage 1
//   - each 3*k+1 (k=0,...,N-1) element is a vector with the
//     names of exogenous variables present in the regression
//   - each 3*k+2 element is a vector with the indexes of the
//     variabels withdrawn to obtain the regression
//   - each 3*k+3 element is a results tlist with the results
//     of the regression
// * nbmodst1_0 = # of models found in the stage 1 regression
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2012
// http://grocer.toolbox.free.fr/grocer.html
 
done=%f
// for all non significant variables, explore the corresponding
// path
nonsignif=find(real(r1_0('pvalue')(nz+1:$)) > alpha)
nb_nonsignif=size(nonsignif,2)
 
if nb_nonsignif == 0 then
   results('ending reason')='all variables significant in stage 0 model'
   results('final model')=r1_0
   done=%t
   list1_2=list(results('initial model'),r1_0)
   nbmodst1=1
 
else
   nmax=size(indx0,'*')
   depth=min(depth,nmax)
   nz=size(z,2)
   listeq1=list()
   all_paths=list([])
   for i=1:nmax
       all_paths(i)=[]
   end
   path=[]
   list_models=list(r1_0,indx0)
   [listeq1,all_paths]=auto_stage1_rec(listeq1,estimpart,estimupd,multitest,test_func,y,x,z,namexos,namecomp,r1_0,path,indx0,all_paths,list_models,depth,nmax,alpha,eta,ncomp,list_vararg)
 
   sizelst1=length(listeq1)/3
   list1_2=list()
   nb_r1_0=0
   // keep only the paths that have lead to a valid model
   for i=1:sizelst1
      r=listeq1(3*i)
      if listeq1(3*i-1) == 'model contains only compulsory variables' then
          rz=listeq1(3*i)
 
      elseif typeof(r) == 'results' then
         if size(r('beta'),1) == size(r1_0('beta'),1) then
            nb_r1_0=nb_r1_0+1
            if nb_r1_0 == 1 then
               // this si the first stage 0 model found in the list
               // of selected models: keep it, but not the next ones, if any
               list1_2($+1)=namexos(listeq1(3*i-2))
               list1_2($+1)=listeq1(3*i-1)
               list1_2($+1)=r
             end
         else
            list1_2($+1)=namexos(listeq1(3*i-2))
            list1_2($+1)=listeq1(3*i-1)
            list1_2($+1)=r
         end
      end
   end
 
   nbmodst1=length(list1_2)/3
   if size(groups_pval,1) ~= 0 then
      r00=results('initial model')
      gpvalue=r00('pvalue')(nz+1:$)
      [results,r_checks,nbmodst1,list1_2]=check_groups(results,y,x,z,groups_pval,gpvalue,...
      gam,eta,r1_0,list1_2,nbmodst1)
   end
 
   if  nbmodst1 == 0 then
   //the final model is empty or contains only complusory variables
   // in that case listeq1 has a path, but no model
      if nz == 0 then
         results('ending reason')='final model is empty'
         results('final model')=[]
      else
         results('ending reason')='final model contains only compulsory variables'
         results('final model')=rz
      end
      done=%t
   end
end
 
endfunction
