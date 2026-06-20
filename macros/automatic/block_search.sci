function [results,rf]=block_search(grocer_namey,varargin)
 
// PURPOSE: block search selection of a model along the lines
// suggested by Doornik(2009): starting from the
// list of exogenous variables provided by the user, the
// function select the "best" regression, that is one where
// all variables are significant, all specification tests are
// passed, and, if more than one regression have these
// properties, the one with the smallest aic criterion
// ------------------------------------------------------------
// REFERENCES:
// * Krolzig, H.-M. and Hendry, D.F. (2001): "Computer
// Automation of General-to-Specific Model Selection
// Procedures", Journal of Economic Dynamics and Control, 25
// (6-7), 831-866.
// * Doornik, J.A. (2009). Autometrics. in Castle, J.L. and
// Shephard, N. (2009), The Methodology and Practice of
// Econometrics, Oxford University Press.
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (n x 1) vector
//   . a string equal to the name of a time series or a (n x 1)
//     real vector between quotes
//   . the string 'estim=xxx' where xxx is the estimation method
//     the user wants to use (default ols); available methods
//     in Grocer are 'ols', 'nwest', 'probit' and 'var'; if the
//     user wants to use automatuc with her own method, say
//     'mymeth' she has to write 4 programs:
//     mymeth4auto-explode, mymeth4auto_full, mymeth4auto_part,
//     mymeth4auto_upd (see the user manual chapter n° 15 for
//     details)
//   . the string 'depth=n' where n is the number of non
//     significant variables that are systematically combinated
//     before starting a backward step-wise alogrithm
//   . the string 'strategy=liberal' or 'strategy=conservative'
//     if the user wants to use a predefined strategy
//     (default = liberal)
//   . the string 'descent=n' where n is the he factor by which
//     p-values of specifiaction tests muts be divided to obtain
//     the new levels used in the subsequent estimations (default 5)
//   . the string 'alpha=p' for the simplification significance
//     depth (default = set by the chosen strategy)
//   . the string 'f0_tdo=p' for the top_down pre-test significance
//     depth (default = set by the chosen strategy)
//   . the string 'f0_bup=p' for the bottom-up pre-test significance
//     depth (default = set by the chosen strategy)
//   . the string 'eta=p' for the specification tests significance
//     depth (default = 0.01)
//   . the string 'gam=p' for the F-tests significance level
//     (default = set by the chosen strategy)
//   . the string 'groups_pval=m1;m2;...;mp' where the mi's
//     are thresholds: coefficient whose p-values are greater
//     than a given threshold are gathered to form a model included
//     in stage 1 models
//     (default = set by the chosen strategy)
//   . the string 'crit=x' where x= aic, bic, or hq(default bic)
//   . the string 'test=x1,...,xp' where xi is the name of a
//     test function
//   . the string 'newname(x1,x2)' where x1 is the name of a
//     test function and x2 is the corresponding name the user
//     wants the program to display
//   . the string 'comp=x1;...;xn' where xi is the name of a
//     variable that must be in the regression whatever
//     significance it has
//   . the string 'dropna' if the user wants to remove the NA
//      values from the data
//   . the string 'win=xx' where xx is the length of the
//     Bartlett window (for the Newey-West estimation)
//   . the string 'prt=opt1,opt2,...,optn'
//   where opti is one of the following available options:
//     - nothing (nothing printed !)
//     - initial (results of initial model printed)
//     - st0_mod (results of stage 0 model printed)
//     - st1_mod (results of stage 1 models printed)
//     - st1_union (results of stage 1 union model printed)
//     - st2_mod (results of stage 2 models printed)
//     - st2_union (results of stage 2 union model printed)
//     - final (results of final model printed)
//     - test_inter (results of specification tests for the
//       intermediate results printed)
//     - test_final (results of specification tests for the
//       final model printed)
//     - test (specification tests printed for every regression
//       result printed)
//     - st1_path (results of stage 1 paths printed)
//     - st2_path (results of stage 2 paths printed)
//     - all (all results printed: can be very long !)
//   . the string 'test=opt1,opt2,...,optn'
//   where opti is one of the following available options:
//     - chowtest(p)
//     - predfailin(p)
//     - doornhans
//     - bpagan(p)
//     - hetero_sq
// ------------------------------------------------------------
// OUTPUT:
// a results tlist with the following fields:
// * results('meth') = 'automatic'
// * results('estim') = estimation method (ols, nwest, var,
// probit or another  )
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
// PRINTS: results along the options given by the user
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
[grocer_estim_meth,varargin]=automatic_method(varargin(:))
 
execstr('[auto_opt,y,namey,x,namexos,z,namecomp,prests,boundsvarb,nonna,multitest,testfunc,m2prt_test,ncomp,varargin]='+grocer_estim_meth+'4auto_explode(grocer_namey,''test_nbexog=%f'',varargin(:))')
 
// print the results
[results,rf]=block_search1([],grocer_estim_meth,evstr(grocer_estim_meth+'4auto_full'),...
      evstr(grocer_estim_meth+'4auto_part'),evstr(grocer_estim_meth+'4auto_upd'),...
      multitest,testfunc,y,x,z,namey,namexos,namecomp,prests,boundsvarb,...
      auto_opt('dropna'),auto_opt('strategy'),auto_opt('alpha'),auto_opt('f0_tdo'),...
      auto_opt('t0_tdo'),auto_opt('groups_pval'),auto_opt('f0_bup'),...
      auto_opt('gam'),auto_opt('eta'),auto_opt('crit'),...
      m2prt_test,auto_opt('wreliab'),auto_opt('depth'),auto_opt('descent'),...
      auto_opt('block_nmax'),ncomp,varargin(:))
 
if auto_opt('prt') ~= 'nothing' then
    prt_blocksearch(results,%io(2))
end
 
endfunction
