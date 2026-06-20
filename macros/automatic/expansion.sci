function ind_xfound=expansion(stage,ind_0,s,estim,estimfull,estimpart,estimupd,multitest,test_func,...
    y,x,z,namey,namexos,namecomp,prests,boundsvar,dropna,strategy,alpha,f0_tdo,...
    t0_tdo,groups_pval,f0_bup,gam,eta,crit,m2prt_test,wreliab,depth,descent,bs_nmax,ncomp,varargin)
 
// PURPOSE: performs the expansion step in a block search as
// adapted from Dorrnik (2009)
// ------------------------------------------------------------
// INPUT:
// * stage = the stage type ('A', 'B', 'C' of 'D')
// * ind_0 = a vector of integers, the index of the
//   exogenous variables used in the starting model
// * estim = a string, the econometric problem to deal with
//   (such as ols, probit, sur, ...)
// * estimfull = a funtion, that provides the estimation with
//   full output in its res_exp tlist
// * estimpart = a funtion, that provides the estimation with
//   only the output neeeded for testing the significance of
//   coefficients and model in its res_exp tlist
// * estimpupd = a funtion, that supplement the res_exp stored
//   by function estimpart to obtain all relevant estimation
//   res_exp
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
// * res_exp = a tlist with:
//   - res_exp('stage i expansion indexes') = the index of the
//    variables retained at the expansion phase of stage i
//   - res_exp('stage i reduction res_exp') = the res_exp
//     tlist obtained at the end of the reduction phase
//   - res_exp('final indexes') = the index of the exogenous
//     variables retained at the end of the process
//  * rf = the res_exp tlist of teh final model
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
 
write(%io(2),'performing stage: '+stage,'(a)')
 
[nobs,nx]=size(x)
nz=size(z,2)
c0=min(bs_nmax,0.4*(nobs-nz))
k0=size(ind_0,'*')
kb=max(c0-k0,floor(c0/4),2)
// kb is the # of new variables that can be added to the
// already discovered ones
ind_x=1:size(x,2)
ind_x(ind_0)=[]
// ind_x is the indexes of variables not discovered at previous stage
nx_excluded=size(ind_x,2)
nblocks=ceil(nx_excluded/kb)
kb_adj=ceil(nx_excluded/nblocks)
// kb_adj is adjusted to keep the size of the blocks almost/
// identical instead of having potentially a very small last block
list_indx=list()
 
remaining=ind_x
for i=1:nblocks-1
   ind_x_selected=[]
   nselected=0
   while nselected < kb_adj
      indx_blocki=grocer_i0+grocer_step*[0:kb_adj-nselected-1]
      indx_blocki=indx_blocki(indx_blocki <= size(remaining,2))
      nselected=nselected+size(indx_blocki,2)
      if nselected < kb_adj then
         grocer_i0=1
         grocer_step=max(grocer_step-1,1)
      end
      ind_x_selected=[ind_x_selected , remaining(indx_blocki) ]
      remaining(indx_blocki)=[]
 
   end
   list_indx(i)=gsort(ind_x_selected,'g','i')
end
list_indx(nblocks)=remaining
// list_x is a list of nblocks blocks containing indexes
// selected from an increasing start and with an increasing distance between them
adjusted=0
 
terminated=%f
while ~terminated
   ind_xfound=[]
   ind_x0=ind_x
   nx_perblock=ceil(size(ind_x0,2)/nblocks)
 
   for i=1:nblocks
      ind_xi=list_indx(i)
      ind_x0(1:min(nx_perblock,size(ind_x0,2)))=[]
      res_exp=automatic1(estim,estimfull,estimpart,estimupd,multitest,test_func,...
      y,x(:,[ind_0 ind_xi]),z,namey,namexos([ind_0 ind_xi]),namecomp,prests,boundsvar,dropna,strategy,alpha*s,f0_tdo,...
      t0_tdo,groups_pval,f0_bup,gam,eta,crit,m2prt_test,wreliab,depth,descent,ncomp,varargin)
      rf=res_exp('final model')
 
      if ~isempty(rf) then
         namex=rf('namex')
         for j=1:rf('nvar')
            ind_xfound=[ind_xfound find(namexos == namex(j))]
        end
     end
   end
 
   ind_xfound=unique(ind_xfound)
   nvar=size(ind_xfound,2)
   if  nvar < 3 then
      if or(stage == {'A';'B'}) & adjusted == 0 then
         s=8
         adjusted=1
      elseif or(stage == ['C' ; 'D']) & adjusted == 0 then
         s=2
         adjusted=1
      else
         terminated=%t
      end
   elseif nvar < c0 then
      terminated=%t
   else
      mult=floor(nvar/c0)
      s=min(s/2^mult,1)
   end
 
end
 
 
endfunction
