function [grocer_opt,grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_z,grocer_namecomp,prests,grocer_boundsvarb,nonna,multitest,testfunc,m2prt_test,nz,list_func,output_list]=ppooled4auto_explode(grocer_namey,varargin)
 
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
 
 
grocer_boundsvarb = []
grocer_optexpert=['eta';'gam';'f0_tdo';'t0_tdo';'alpha']
grocer_optnum=['descent';'wreliab';'dropna';'depth';'groups_pval']
grocer_comp=[]
grocer_test=emptystr()
grocer_expert=%f
grocer_test_nbexog=%t
grocer_saturated='none'
grocer_opt_ppooled=tlist(['hac';'alpha';'nboot'])
grocer_subnameid = %f
grocer_hac=0
grocer_nboot=0
grocer_alpha=0
grocer_win=[]
 
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
 
grocer_arg1 = varargin(1)
grocer_nargin=length(varargin)
grocer_z=[]
if typeof(grocer_arg1) == 'panel data' then
 
   grocer_namecomp=[]
   grocer_namep=grocer_arg1('namex')(:)
// grocer_namep is the vector of names in the data base
 
   grocer_xp=grocer_arg1('x')
// grocer_xp is the vector of values in the data base
 
   execstr(grocer_namep'+'=grocer_xp(:,'+string(1:size(grocer_namep,'*'))+')')
   execstr('grocer_y='+grocer_namey)
   const=1+0*grocer_y
   grocer_namexos=grocer_namep'
 
   grocer_id=grocer_arg1('id')
// grocer_id is the vector of individuals
 
   grocer_nameid=grocer_arg1('nameid')
// and grocer_nameid is their name
 
   for grocer_i=grocer_nargin:-1:2
 
      if typeof(varargin(grocer_i)) == 'string' then
         grocer_argi=strsubst(varargin(grocer_i),' ','')
         grocer_indeq=strindex(grocer_argi,'=')
         if ~isempty(grocer_indeq) then
            grocer_nameopt=part(grocer_argi,1:grocer_indeq(1)-1)
            grocer_valopt=part(grocer_argi,grocer_indeq(1)+1:length(grocer_argi))
 
            if grocer_nameopt == 'comp' then
               grocer_ind_semicol=[0 , strindex(grocer_valopt,';') , length(grocer_valopt)+1]
               grocer_nvar=size(grocer_ind_semicol,2)-1
               grocer_namecomp=emptystr(grocer_nvar,1)
               for grocer_j=1:grocer_nvar
                  grocer_namecomp(grocer_j)=part(grocer_valopt,grocer_ind_semicol(grocer_j)+1:grocer_ind_semicol(grocer_j+1)-1)
               end
               execstr('grocer_z='+grocer_namecomp(1))
               for grocer_j=2:grocer_var
                  grocer_z=[grocer_z , grocer_namecomp(grocer_j)]
               end
 
            elseif grocer_nameopt ==  'nameid' then
// the user has given the name of the individuals, which is a subset
// of the names in the database
               grocer_subnameid=%T
               grocer_nameid0=grocer_nameid
               grocer_nameid=str2vec(varargin(grocer_i))
 
            elseif grocer_nameopt == 'x' then
               // the user has given the name of the variables
               grocer_namexos=str2vec(grocer_argi)
               grocer_argi=strsubst(grocer_argi,';',',')
               grocer_argi=strsubst(grocer_argi,'=','=[')+']'
               execstr('grocer_'+grocer_argi)
 
            elseif or(grocer_nameopt == grocer_optexpert) then
               execstr('grocer_opt(grocer_nameopt)='+grocer_valopt)
               grocer_expert=%t
 
            elseif or(grocer_nameopt == grocer_optnum) then
               execstr('grocer_opt(grocer_nameopt)='+grocer_valopt)
 
            elseif grocer_nameopt == 'hac' then
               execstr('grocer_hac='''+grocer_valopt+'''')
 
            elseif grocer_nameopt == 'win' then
               execstr('grocer_'+grocer_argi)
 
            end
 
         elseif argi == 'dropna' then
            grocer_dropna=%t
 
         elseif grocer_argi == 'noprint' then
            grocer_prt=%f
 
         end
      end
   end
 
   if grocer_subnameid then
 
      [grocer_B,grocer_ind]=gsort(vec2col(grocer_id),'g','d')
      grocer_dB=[grocer_B(2:$)-grocer_B(1:$-1) ; 1]
      // eliminates the redundant values
      grocer_binv=grocer_B(grocer_dB ~= 0)
      // take the inverse of binv to obtain the increasing order
      grocer_uniq=grocer_binv($:-1:1)
 
      for grocer_j=1:size(grocer_nameid0,1)
         if and(grocer_nameid ~= grocer_nameid0(grocer_j)) then
            f=find(grocer_id ==grocer_uniq(grocer_j))
            grocer_id(f)=[]
            grocer_y(f)=[]
            grocer_x(f,:)=[]
 
         end
      end
   end
 
   nonna=find(sum(isnan([grocer_y grocer_x]),'c') == 0)
 
   if or(isnan([grocer_y grocer_x])) then
      if grocer_dropna then
         grocer_y=grocer_y(nonna)
         grocer_x=grocer_x(nonna,:)
         grocer_id=grocer_id(nonna,:)
      else
         error('there are %nan values in your panel data')
      end
   end
 
else
 
   grocer_lx=varargin
   for grocer_i=grocer_nargin:-1:2
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      grocer_nameopt=part(grocer_argi,1:grocer_indeq(1)-1)
      grocer_valopt=part(grocer_argi,grocer_indeq(1)+1:length(grocer_var))
 
      if grocer_nameopt == 'comp' then
         grocer_ind_semicol=[0 , strindex(grocer_valopt,';') , length(grocer_valopt)+1]
         grocer_nvar=size(grocer_ind_semicol,2)-1
         grocer_comp=emptystr(grocer_nvar,1)
         for grocer_j=1:grocer_nvar
            grocer_comp(grocer_j)=part(grocer_valopt,grocer_ind_semicol(grocer_j)+1:grocer_ind_semicol(grocer_j+1)-1)
         end
         grocer_lx(grocer_i) = null()
 
      elseif grocer_nameopt == 'id' then
         execstr('grocer_'+grocer_argi)
         grocer_lx(grocer_i) = null()
 
      elseif grocer_nameopt ==  'hac' then
         execstr('grocer_'+grocer_argi)
         grocer_lx(grocer_i) = null()
 
      elseif grocer_nameopt == 'win' then
         execstr('grocer_'+grocer_argi)
         grocer_lx(grocer_i) = null()
 
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
         grocer_lx(grocer_i) = null()
 
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         grocer_lx(grocer_i) = null()
 
      end
   end
	
   if ~exists('grocer_nameid','local') then
      grocer_nameid='individual # '+string(unique(vec2col(grocer_id)))
   end
   [grocer_mats,grocer_names,prests,grocer_boundsvarb,nonna]=explon(list(grocer_namey,grocer_comp,grocer_lx),...
                                       ['endogenous';'compulsory';'exogenous'],[],%t,grocer_opt('dropna'))
   grocer_y=grocer_mats(1)
   grocer_z=grocer_mats(2)
   grocer_x=grocer_mats(3)
   grocer_namey=grocer_names(1)
   grocer_namecomp=grocer_names(2)
   grocer_namexos=grocer_names(3)
 
end
 
[nobs,nx]=size(grocer_x)
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
 
if grocer_expert then
   grocer_opt('strategy')='expert'
end
 
if grocer_hac==0 then
   list_func=list(ppooled4auto_part,ppooled4auto_upd,ppooled4auto_full)
else
   if grocer_hac=='ccm' then
      grocer_hac=1
   elseif grocer_hac=='nw' then
      uniq=unique(grocer_id)
      nindiv=size(uniq,'*')
      Ti=zeros(nindiv,1)
      for i = 1:nindiv
         id_i=find(grocer_id == uniq(i));
         Ti(i)=size(id_i,2);
       end
 
      if length(unique(Ti))==1 then
         grocer_hac=2
      else
         error('Newey-West type variance matrix doesn''t work with unbalanced panel');
      end
 
   end
  list_func=list(ppooledhac4auto_part,ppooled4auto_upd,ppooledhac4auto_full)
end
 
multitest=auto_waldf0
prests=%f
boundsvarb=[]
testfunc=test_empty
m2prt_test=[]
nz=size(grocer_z,2)
output_list=list(grocer_nameid,grocer_id,grocer_hac,grocer_win)
 
endfunction
