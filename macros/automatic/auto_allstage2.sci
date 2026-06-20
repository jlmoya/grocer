function [results]=auto_allstage2(results,estimpart,estimupd,y,x,z,namexos,namecomp,r0,indx2_00,crit,depth,alpha,eta,gam,ncomp,list_vararg)
 
// PURPOSE: in an automatic estimation, estimates all stage 2
// models
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
// * x = a (nobs x k) matrix of exogenous variables that can
//   be present or absent in the final estimated model
// * z = a (nobs x l) matrix of exogenous variables that are
//   constrained to be in the final model
// * namexos = a (k+l) vector of strings, the name of all
//   exogenous variables
//   results
// * r0 = a predefined tlist result whose needed fileds
//   already exist
// * indx2_00 = a integer vector, the index of the x variables
//   at entry in the function
// * crit = the selection criterion used for selecting models
//   at the end of the process
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
//   new results (stage 2 models, union of stage 2 models and
//   final model)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2012
// http://grocer.toolbox.free.fr/grocer.html
 
nmax=size(indx2_00,'*')
r2_00=estimpart(r0,y,x(:,indx2_00),z,ncomp,indx2_00,list_vararg)
[val,p]=test_func(r2_00)
r2_00=estimupd(r2_00,y,[namecomp ; namexos],indx2_00,val,p,ncomp,list_vararg)
results(1)($+1)='stage 2.0 model'
results('stage 2.0 model')=r2_00
depth=min(depth,nmax)
 
nz=size(z,2)
all_paths=[]
path=[]
list_models=list()
listeq2=list()
 
list_models=list(r2_00,indx2_00)
 
all_paths=list([])
for i=1:nmax-1
   all_paths(i)=[]
end
listeq2=auto_stage1_rec(listeq2,estimpart,estimupd,multitest,test_func,y,x,z,namexos,namecomp,r2_00,[],indx2_00,all_paths,list_models,depth,nmax,alpha,eta,ncomp,list_vararg)
 
sizelst2=length(listeq2)/3
list2_2=list()
for i=1:sizelst2
   if listeq2(3*i-1) == 'model contains only compulsory variables' then
      rz=listeq2(3*i)
   elseif typeof(listeq2(3*i)) == 'results' then
      list2_2($+1)=namexos(listeq2(3*i-2))
      list2_2($+1)=listeq2(3*i-1)
      list2_2($+1)=listeq2(3*i)
   end
end
results(1)($+1)='stage 2.1 models'
results('stage 2.1 models')=list2_2
nbmodst2=length(list2_2)/3
 
select nbmodst2
 
case 0 then
   nonsignif=find(real(r2_00('pvalue')(nz+1:$)) > alpha)
   if nonsignif == 0 then
      results('ending reason')='all variables significant in stage 2.0 model '
   else
      results('ending reason')='no variable can be withdrawn in stage 1 union model '
   end
   results('final model')=r2_00
 
case 1 then
   results('ending reason')='only one model selected by stage 2'
   results('final model')=list2_2(3)
   results(1)($+1)='stage 2 models'
   results('stage 2 models')=list2_2
 
else
   [r2_3,numx3,accept]=auto_union(results,estimpart,estimupd,multitest,test_func,y,x,z,namexos,namecomp,r0,list2_2,nbmodst2,ncomp,list_vararg)
 
   sumaccept=sum(accept)
   indl_accept=find(accept)
 
   select sumaccept
   case 0 then
      // all terminal models are rejected
      results('ending reason')='all stage 2 models rejected against their union'
      results(1)($+1)='stage 2 models'
      [val,p]=test_func(r2_3)
      results('stage 2 models')=list([],[],r2_3,[val p])
      results('final model')=r2_3
 
   case 1 then
      // only one terminal model is not rejected:
      // it is the final model
      results('ending reason')='only one stage 2 model not rejected against their union'
      results('final model')=list2_2(3*indl_accept(1))
   else
      // more than one model are accepted
      results(1)($+1)='stage 2 models'
      crit0=%inf
      lst2_mod=list()
      for i=1:sumaccept
         r=list2_2(3*indl_accept(i))
         crit_i=real(r(crit))
         if crit_i < crit0 then
            indmof=i
            crit0=crit_i
         end
         lst2_mod($+1)=list2_2(3*indl_accept(i)-2)
         lst2_mod($+1)=list2_2(3*indl_accept(i)-1)
         lst2_mod($+1)=list2_2(3*indl_accept(i))
      end
      results('stage 2 models')=lst2_mod
      results('ending reason')='stage 2 models selected by '+crit+' criterion'
      results('final model')=list2_2(3*indl_accept(indmof))
   end
end
 
 
endfunction
