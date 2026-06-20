function [listeq,all_paths]=auto_back(estimpart,estimupd,listeq,r,list_models,path,all_paths,alpha,eta,namexos,namecomp,nz,list_vararg)
 
// PURPOSE: after a model has been found that has only
// significant varaibles, check if some specification tests are
// not passed and if thi is teh case, then backtrack
// until all specification tests are passed
// ------------------------------------------------------------
// INPUT:
// * listeq = the list containing all preceding paths and the
//   corresponding estimation results
// * r = the results tlist for the found model
// * list_models = the list of estimated models on the path
//   followed to obtain the found model
// * path = the path followed from the last general model, that
//   is the nndex of variables that have been removed in the
//   order they have been removed
// * all_paths = a list, with all_paths(i) = the sorted indexes
//   of all sets of i variables which have been removed along
//   previous explored paths
// * list_models = a list, the list of models that have been
//   estimated untilnow along the explored path (useful in the
//   case when backtracking is needed: re-estimation is not
//   needed thanks to this storing
// * gpvalue = the p-values of the estimated coefficients of the
//   non compulsory variables, sorted by increasing significance
// * indpvalue = the indexes of the corresponding exoegnous
//   variables
// * alpha = the simplification significance level
// * eta = a vector equal to the significance levels for the
//   specification tests
// ------------------------------------------------------------
// OUTPUT:
// * listeq = the entry list plus the path followed here and,
//   if it leads to a new model, the corresponding estimation
//   results
// * all_paths = the updated list of paths
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
[val,p]=test_func(r)
gpvalue=r('pvalue')(nz+1:$)
 
if and(p >= eta) then
   indx=list_models($)
   if max(real(gpvalue)) >= alpha & size(gpvalue,1) == 1 then
      path=[path indx]
      listeq($+1)=path
      if nz == 0 then
         listeq($+1)='empty model'
         listeq($+1)=[]
      else
         r=estimpart(r,y,[],z,nz,[],list_vararg)
         r=estimupd(r,y,[namecomp],[],val,p,nz,list_vararg)
         listeq($+1)='model contains only compulsory variables'
         listeq($+1)=r
      end
   else
      r=estimupd(r,y,[namecomp;namexos],indx,val,p,nz,list_vararg)
      listeq($+1)=path
      listeq($+1)=indx
      listeq($+1)=r
   end
 
else
   while or(p < eta) & length(list_models) > 2 then
      // one of the specification tests fails, backtrack until
      // all specification tests are passed
      // first remove the path from the list of already encountered paths,
      // sicne you can arrive to it with other regressions that may pass
      // the specification tests
      npath=size(path,'*')
      all_paths_i=all_paths(npath)
      all_paths(npath)=all_paths_i(1:$-1,:)
      list_models($)=null()
      list_models($)=null()
      path($)=[]
      r=list_models($-1)
      [val,p]=test_func(r)
   end
   if and(p >= eta) then
      // update the list listeq of stage 1 models
      // fill all the fields in the results tlist r that have not been filled
      // for the sake of speed
      listeq($+1)=path
      indx=list_models($)
      r=estimupd(r,y,[namecomp;namexos],indx,val,p,nz,list_vararg)
      listeq($+1)=indx
      listeq($+1)=r
   else
      listeq($+1)=[]
      listeq($+1)='invalid path because of specification tests'
      listeq($+1)=[]
 
   end
end
endfunction
