function [listeq,all_paths]=auto_stage1_rec(listeq,estimpart,estimupd,multitest,test_func,y,x,z,namexos,namecomp,r,path,indx,all_paths,list_models,depth,nmax,alpha,eta,ncomp,list_vararg)
 
// PURPOSE: along a path
// 1) either:
// - explore all paths where sets of insignificant variables
//   of predefined size (set by input depth) are removed and
//   then variables with remaining lowest significance are
//   removed until all remaining variables are significant
// - explore only the path built by removing variables with
//   remaining lowest significance are removed until all
//   remaining variables are significant (case when input depth
//   is equal to 0)
// 2) if some specification tests are not passed, then
//   backtrack until all specification tests are passed
// ------------------------------------------------------------
// INPUT:
// * listeq = the list containing all preceding paths and the
//   corresponding estimation results
// * estimpart = a funtion, that provides the estimation with
//   only the output neeeded for testing the significance of
//   coefficients and model in its results tlist
// * multitest = a function, that performs the testing of an
//   estimated model against an encompassing one
// * test_func = a function, that performs the specification
//   tests
// * y = a (nobs x 1) vector of endogenous variables
// * x = a (nobs x k) matrix of exogenous variables that can
//   be present or absent in the final estimated model
// * z = a (nobs x l) matrix of exogenous variables that are
//   constrained to be in the final model
// * r0 = the starting estimation tlist
// * path = the path followed from the last general model, that
//   is the nndex of variables that have been removed in the
//   order they have been removed
// * indx = the index of the x variables in the regression
// * all_paths = a list, with all_paths(i) = the sorted indexes
//   of all sets of i variables which have been removed along
//   previous explored paths
// * list_models = a list, the list of models that have been
//   estimated untilnow along the explored path (useful in the
//   case when backtracking is needed: re-estimation is not
//   needed thanks to this storing
// * alpha = the simplification significance depth
// * eta = a vector equal to the significance depths for the
//   specification tests
// * z = matrix of the compulsory variables (the ones that must
//   be in the regression whatever significance they have)
// ------------------------------------------------------------
// OUTPUT:
// * listeq = the entry list plus the path followed here and,
//   if it leads to a new model, the corresponding estimation
//   results
// * all_paths = the updated list of paths
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2012
// http://grocer.toolbox.free.fr/grocer.html
 
gpvalue=real(r('pvalue')(ncomp+1:$))
 
if max(gpvalue) >= alpha & size(gpvalue,1) > 1 & depth > 0 then
   depth=depth-1
   nonsignif=find(gpvalue >= alpha)
   for i=nonsignif
   // drop one at a time all insignificant variables
      pathn=path
      list_modelsn=list_models
      pathn=[pathn indx(i)]
      ordpath=gsort(pathn,'g','d')
      npath=size(pathn,2)
      all_paths_i=all_paths(npath)
      for j=npath:-1:1
         all_paths_i(all_paths_i(:,j)~=ordpath(j),:)=[]
      end
      if ~isempty(all_paths_i) then
         //path already encoutered: stop there
         listeq($+1)=pathn
         listeq($+1)='path already encoutered'
         listeq($+1)=[]
         return
      end
      all_paths(npath)=[all_paths(npath) ; ordpath]
 
      indxn=indx
      indxn(i)=[]
      r=estimpart(r,y,x(:,indxn),z,ncomp,indxn,list_vararg)
      list_modelsn($+1)=r
      list_modelsn($+1)=indxn
      [listeq,all_paths]=auto_stage1_rec(listeq,estimpart,estimupd,multitest,test_func,y,x,z,namexos,namecomp,r,pathn,indxn,all_paths,list_modelsn,depth,nmax,alpha,eta,ncomp,list_vararg)
   end
 
elseif max(gpvalue) >= alpha
// now, drop variables by increasing significance
   [valmax,indmax]=max(gpvalue)
   while valmax > alpha & size(gpvalue,1) > 1
      // search for an insignificant variable to withdraw
      // start by removing the least significant variable
      indsuppr=indx(indmax)
      indx(indmax)=[]
      path=[path indsuppr]
 
      // updates the path
      npath=size(path,'*')
      ordpath=gsort(path,'g','d')
      all_paths_i=all_paths(npath)
      for j=npath:-1:1
         all_paths_i(all_paths_i(:,j)~=ordpath(j),:)=[]
      end
      if ~isempty(all_paths_i) then
         //path already encoutered: stop there
         listeq($+1)=path
         listeq($+1)='path already encoutered'
         listeq($+1)=[]
         return
      end
      all_paths(npath)=[all_paths(npath) ; ordpath]
      r=estimpart(r,y,x(:,indx),z,ncomp,indx,list_vararg)
      gpvalue=real(r('pvalue')(ncomp+1:$))
      [valmax,indmax]=max(gpvalue)
      list_models($+1)=r
      list_models($+1)=indx
   end
   [gpvalue,indpvalue]=gsort(r('pvalue')(ncomp+1:$),'g','d')
   [listeq,all_paths]=auto_back(estimpart,estimupd,listeq,r,list_models,path,all_paths,alpha,eta,namexos,namecomp,ncomp,list_vararg)
else
   [listeq,all_paths]=auto_back(estimpart,estimupd,listeq,r,list_models,path,all_paths,alpha,eta,namexos,namecomp,ncomp,list_vararg)
end
 
endfunction
