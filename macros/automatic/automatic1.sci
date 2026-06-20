function results=automatic1(estim,estimpart,estimupd,estimfull,multitest,test_func,...
    y,x,z,namey,namexos,namecomp,prests,boundsvar,dropna,strategy,alpha,f0_tdo,...
    t0_tdo,groups_pval,f0_bup,gam,eta,crit,m2prt_test,wreliab,depth,descent,ncomp,list_vararg)
 
// PURPOSE: automatic selection of a model by least-squares
// regressions; this function is the low-depth counterpart
// of general function automatic
// ------------------------------------------------------------
// INPUT:
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
// results = a results tlist with:
// * results('meth') = 'automatic'
// * results('estim') = estimation method (ols or nwest)
// * results('strategy') = estimation strategy (liberal,
//   conservative or expert)
// * results('alpha') = simplification significance
//     depth (default = set by the chosen strategy)
// * results('f0_tdo') = top_down pre-test significance
//     depth (default = set by the chosen strategy)
// * results('f0_bup') = bottom-up pre-test significance
//     depth (default = set by the chosen strategy)
// * results('gam') = F-tests significance level
//     (default = set by the chosen strategy)
// * results('eta') = specification tests significance
//     depth (default = 0.01)
// * results('comp') = matrix of values for the compulsory
//   variables
// * results('f_test') = the function used to perform the
//                      specification tests
// * results('m_test') = the names of the specification tests
// * results('initial model') = the estimation results of the
//                            unrestricted model
// * results('ending reason') = the reason why the final model
//                            has been chosen
// * results('final model') = the estimation results of the
//                            final model
// * results('wind length') = the size of the Bartlett window
//   (if the Nwest correction has been used)
// * results('top-down model') = the top-down model
// * results('bottom-up model') = the bottom-up model
// * results('stage 0 model') = the estimation results of the
//                             stage 0 restricted model (all
//                             variables whose individual tstat
//                             depth is lower than 1 and whose
//                             joint significance depth is
//                             lower than f0_tdo are withdrawn)
// * results('selected stage 0 model') = the way the stage 0
//   model has been selected
// * results('checking process model') = the model resulting
//   from the group checking process
// * results('stage i models') = the estimation results of the
//   stage i (i=1, 2.0, 2.1) models and the corresponding paths
// * results('stage i union model') = the estimation results of
//                            the model built from the union of
//                            stage i (i=1, 2.0, 2.1) models
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
if isempty(eta) then
   eta=0
end
if f0_tdo == [] then
   f0_tdo=0
end
nz=size(z,2)
// estimate the gum model
[r1_00,eta,x,namexos]=auto_gum(estimfull,test_func,y,z,x,namey,namexos,namecomp,prests,boundsvar,dropna,eta,m2prt_test,descent,ncomp,list_vararg)
 
// define the high depth tlist associated to the automatic results
results=tlist(['results';'meth';'estim';'strategy';'alpha';'f0_tdo';'f0_bup';...
      'gam';'eta';'comp';'criterion';'f_test';'m_test';...
      'initial model';'ending reason';'final model';...
      'reliability parameters'],'automatic',estim,strategy,alpha,f0_tdo,...
       f0_bup,gam,eta,z,crit,test_func,m2prt_test,r1_00,[],[],wreliab)
 
// stage 0: eliminate variables at a loose significance depth
// and estimate the bottom-up model
[results,done,indxf_r0,list_models]=auto_stage0(results,estimpart,estimupd,multitest,test_func,...
y,x,z,namexos,namecomp,r1_00,alpha,f0_tdo,t0_tdo,f0_bup,eta,ncomp,list_vararg)
 
if ~done then
   // the general case: there are still non significant variables
   r0=results('stage 0 model')
   // estimate all stage 1 models
   [results,done,list1_2,nbmodst1]=auto_allstage1(results,estimfull,estimpart,estimupd,multitest,test_func,...
                                   y,x,z,namexos,namecomp,r0,indxf_r0,depth,alpha,eta,gam,groups_pval,list_models,ncomp,list_vararg)
   if ~done then
      results(1)($+1)='stage 1 models'
      results('stage 1 models')=list1_2
      results(1)($+1)='stage 1 paths'
      results('stage 1 paths')=list(list1_2(3*[1:nbmodst1]-2))
 
      if nbmodst1 == 1 then
         results('ending reason')='only one model selected by stage 1'
         results('final model')=list1_2(3)
      else
         // estimate the union model
         [r1_3,numx3,accept]=auto_union(results,estimpart,estimupd,multitest,test_func,...
                             y,x,z,namexos,namecomp,r0,list1_2,nbmodst1,ncomp,list_vararg)
         results(1)($+1)='stage 1 union model'
         results('stage 1 union model')=r1_3
         sumaccept=sum(accept)
         indl_accept=find(accept)
         if sumaccept == 1 then
            //   only one terminal model is not rejected:
            //  it is the final model
            results('ending reason')='only one stage 1 model not rejected against their union'
            results('final model')=list1_2(3*indl_accept(1))
         else
        // a different number of models than one are accepted
        // form the union of the accepted models
            if sumaccept  == 0 then
               // all models rejected agaisnt union model; hence
               // start from the union model
               indx2_00=numx3
            else
               // select the accepted models and start from
               // the union of these models
               indx_accept=list1_2(3*indl_accept(1)-1)
               for j=2:sumaccept
                  indx_accept=[indx_accept list1_2(3*indl_accept(j)-1)]
               end
 
               indx2_00=vec2row(unique(gsort(indx_accept,'g','i')))
 
            end
 
            // end the estimation process with stage 2
            results=auto_allstage2(results,estimpart,estimupd,y,x,z,namexos,namecomp,r0,indx2_00,crit,depth,alpha,eta,gam,ncomp,list_vararg)
 
         end
      end
   end
end
 
// reliability of the selected variables
if results('ending reason') ~= 'final model is empty' then
   resl=reliability(results('final model'),wreliab,alpha,'noprint')
else
   resl=[]
end
results(1)($+1)='reliab'
results('reliab')=resl
 
endfunction
