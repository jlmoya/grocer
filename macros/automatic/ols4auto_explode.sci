function [grocer_opt,y,namey,x,namexos,z,namecomp,prests,boundsvarb,nonna,multitest,testfunc,m2prt_test,nz,list_func,output_list]=ols4auto_explode(grocer_namey,varargin)
 
// PURPOSE: explode the various arguments entered in function
// automatic when applied to ols
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = the name of the endogenous variable
// * varargin = variable arguments entered into function
//   automatic
// ------------------------------------------------------------
// OUTPUT:
// * grocer_opt = a tlist with:
//   - grocer_opt('strategy') = a string, the name of the
//     startegy used by the user
//   - grocer_opt('descent') = a scalar, the number used to
//     adjust specification tests when they fail for the
//     Generalized Unrestricted Model
//   - grocer_opt('crit') = a string, the selection criterion
//     used to select terminal models
//   - grocer_opt('groups_pval') = a real vector, the values of
//     thresholds: coefficient whose p-values are greater
//     than a given threshold are gathered to form a model
//     included
//   - grocer_opt('eta') = a scalar, the significance level of
//     the specification tests
//   - grocer_opt('gam') = a scalar, the significance level of
//     F-tests significance level
//   - grocer_opt('f0_tdo') = a scalar, the top-down Fisher
//     pre-test significance level
//   - grocer_opt('t0_tdo') = a scalar, the top-down Student
//     pre-test significance level
//   - grocer_opt('f0_bup') = a scalar, the bottom-up Fisher
//     pre-test significance level
//   - grocer_opt('alpha') = a scalar, the level of the
//     simplification significance Stuendt-test
//   - grocer_opt('depth') = a scalar, the size of the set of
//     non significant coefficients whose combination will be
//     removed in a systematic way before only the less
//     siginficant remaining one is removed
//   - grocer_opt('wreliab') = a real vector, the values given
//     to the relaibility codes
//   - grocer_opt('dropna') = a booelan indiciating whether NA
//     values are removed from the data
//   - grocer_opt('prt') = a string, the models that will be
//     displayed at teh end of automatic
// * y = (nobs x 1) matrix of endogenous variables
// * namey = the string collecting its name
// * x = (nobs x k) matrix of exogenous non compulsory
//       variables
// * namex = (k x 1) string collecting their name
// * z = (nobs x ncomp) matrix of exogenous non compulsory
//       variables
// * namecomp = (ncomp x 1) string collecting their name
// * prests = a boolean indicating the presence or absence of a
//            time series in the regression
// * boundsvarb = if there is a timeseries in the regression,
//                the bounds of the regression
//                if not, then an empty matrix
// * nonna = a vector of integers, the index of NA values (if
//           any) in the data
// * multitest = the function used to test a restricted model
//               agasint the alternative
// * testfunc = the function used to perform specification tests
// * m2prt_test = a string vector, the names of the
//                specification tests
// * nz =  a scalar, the number of complusory variables
// * junk = an empty list
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
grocer_optexpert=['eta';'gam';'f0_tdo';'t0_tdo';'alpha']
grocer_optnum=['descent';'wreliab';'dropna';'depth';'groups_pval']
grocer_comp=[]
grocer_test=emptystr()
grocer_expert=%f
grocer_test_nbexog=%t
grocer_saturated='none'
 
grocer_liberal=[0.125 0.075 0.075 0.05  0.025 ; // F tests
               0.1   0.05  0.05  0.025 0.01 ;  // t tests
               0.90  0.75  0.625 0.5   0.25 ;   // top-down F tests
               0.125 0.075 0.075 0.05  0.025 ;  // top-down t-tests (1rst step)
               0.6   0.4   0.3   0.2   0.075   // bottom-up F tests
               ]
 
grocer_conservative=[0.05 0.02  0.015 0.01  0.002 ; // F tests
               0.025 0.01  0.01  0.005 0.001 ;  // t tests
               0.75  0.5  0.25  0.1  0.05 ;   // top-down F tests (1rst step)
               0.05 0.020 0.075 0.05  0.025 ;  // top-down t-tests (1rst step)
               0.6   0.4   0.3   0.2   0.075   // bottom-up F tests
               ]
 
grocer_names=tlist(['names';'jbnorm';'doornhans';'hetero_sq';...
     'chowtest';'predfailin';'arlm';'arch'],'Jarque & Bera',...
     'Doornik & Hansen','hetero x_squared','Chow',...
     'Chow pred. fail. ','AR','ARCH')
 
grocer_opt=tlist(['options';'strategy';'descent';'crit';'groups_pval';...
'eta';'gam';'f0_tdo';'t0_tdo';'f0_bup';'alpha';...
'depth';'wreliab';'dropna';'prt';'saturate';'saturate_post';'block search';...
'thresh_block';'block_nmax'],...
'liberal',5,'bic',[],...
0.01,[],[],[],[],[],...
1,[0.3 ; 0.6 ; 0.4 ; 0.7],%f,[],%f,%f,%f,0.6,128)
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_var=strsubst(varargin(grocer_i),' ','')
      if size(grocer_var,'*') == 1 then
         grocer_indeq=strindex(grocer_var,'=')
         if ~isempty(grocer_indeq) then
            grocer_nameopt=part(grocer_var,1:grocer_indeq(1)-1)
            grocer_valopt=part(grocer_var,grocer_indeq(1)+1:length(grocer_var))
 
            if grocer_nameopt == 'comp' then
                grocer_ind_semicol=[0 , strindex(grocer_valopt,';') , length(grocer_valopt)+1]
                grocer_nvar=size(grocer_ind_semicol,2)-1
                grocer_comp=emptystr(grocer_nvar,1)
                for grocer_j=1:grocer_nvar
                    grocer_comp(grocer_j)=part(grocer_valopt,grocer_ind_semicol(grocer_j)+1:grocer_ind_semicol(grocer_j+1)-1)
                end
 
            elseif grocer_nameopt == 'test' then
                grocer_test=grocer_valopt
 
            elseif grocer_nameopt == 'test_nbexog' then
                execstr('grocer_test_nbexog='+grocer_valopt)
 
            elseif grocer_nameopt == 'block_nmax' then
                execstr('grocer_opt(grocer_nameopt)='+grocer_valopt)
 
            elseif or(grocer_nameopt == grocer_optexpert) then
               execstr('grocer_opt(grocer_nameopt)='+grocer_valopt)
               grocer_expert=%t
 
            elseif or(grocer_nameopt == grocer_optnum) then
               execstr('grocer_opt(grocer_nameopt)='+grocer_valopt)
 
            else
               grocer_opt(grocer_nameopt)=grocer_valopt
            end
            varargin(grocer_i)=null()
 
         elseif part(grocer_var,1:8) == 'newnames' then
            indcom=strindex(grocer_var,',')
            grocer_names(1)($+1)=part(grocer_var,strindex(grocer_var,'(')+1:indcom-1)
            grocer_names($+1)=part(grocer_var,indcom+1:strindex(grocer_var,')')-1)
            varargin(grocer_i)=null()
 
         elseif grocer_var == 'saturate_post' then
            grocer_opt('saturate_post')=%t
            varargin(grocer_i)=null()
 
         elseif grocer_var == 'saturate' then
            grocer_opt('saturate')=%t
            varargin(grocer_i)=null()
 
         elseif varargin(grocer_i) == 'block search' then
            grocer_opt('block search')=%t
            varargin(grocer_i)=null()
 
         end
      end
   end
end
 
[mats,names,prests,boundsvarb,nonna]=explon(list(grocer_namey,grocer_comp,varargin),...
['endogenous';'compulsory';'exogenous'],[],%t,grocer_opt('dropna'))
y=mats(1)
z=mats(2)
x=mats(3)
namey=names(1)
namecomp=names(2)
namexos=names(3)
 
// create the function testfunc performing the specification tests  and the
// string matrix collecting their names
[nobs,nx]=size(x)
nz=size(z,2)
nvar=nx+nz
if nvar >= grocer_opt('thresh_block')*nobs then
   grocer_opt('block search')=%t
end
 
if ~exists('grocer_testfunc','local') then
   [testfunc,m2prt_test,nvarmax]=auto_test(grocer_names,grocer_test,nobs,nvar,test_spec0)
   if ~grocer_opt('block search') & grocer_test_nbexog & nvar > nvarmax then
      error('too many exogenous variables')
   end
end
 
execstr('tab=grocer_'+grocer_opt('strategy'))
// if necessary set the significance levels of the test
strat_col=1+(nobs>60)+(nobs>120)+(nobs>200)+(nobs>1000)
 
if isempty(grocer_opt('gam')) then
   grocer_opt('gam')=tab(1,strat_col)
end
if isempty(grocer_opt('alpha')) then
   grocer_opt('alpha')=tab(2,strat_col)
end
if isempty(grocer_opt('f0_tdo')) then
   grocer_opt('f0_tdo')=tab(3,strat_col)
end
if isempty(grocer_opt('t0_tdo')) then
   grocer_opt('t0_tdo')=tab(4,strat_col)
end
if isempty(grocer_opt('f0_bup')) then
   grocer_opt('f0_bup')=tab(5,strat_col)
end
multitest=auto_waldf0
list_func=list(ols4auto_part,ols4auto_upd,ols4auto_full)
output_list=list()
 
 
endfunction
