function [grocer_model,grocer_listout]=estim_univmod(grocer_model,grocer_indeq,grocer_func,grocer_save,grocer_prt,varargin)
 
// PURPOSE: estimate equations of a model for some univariate
// methods (nls and iv excluded)
// ------------------------------------------------------------
// INPUT:grocer_indeqj_namecoeff
// * grocer_model = a model tlist
// * grocer_tsmat = a tsmat containing all data needed for
//   estimating the equation (should be the tsmat associated to
//    the model, created by function create_dbmod)
// * grocer_indeq =
//   - a string, the name of the equation to estimate or the
//   keyword 'all' (to estimate all equations)
//   - or an integer, the index of the equation in the model
// * grocer_func = a low level function such as ols2, lad1,
//   olst1, etc.
// * grocer_save = a (neq x 1 ) vector of booleans indicating
//   whether the equations must be saved
// * grocer_prt = a (neq x 1 ) vector of booleans indicating
//   whether the results of the equations must be displayed
// * varargin = arguments beyond y and x in the function
//   grocer_func
// ------------------------------------------------------------
// OUTPUT:
// * grocer_model = the input model tlist, updated with the
//   estimated coefficients of the equations given in argument
//   grocer_indeq if the user has entered the option 'save=%t'
// * grocer_listout = a list of results tlists, one for each
//   equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018-2019
// http://dubois.ensae.net/grocer.html
 
grocer_listout=list()
if typeof(grocer_model) == 'string' then
   grocer_model=create_model(grocer_model)
end
 
grocer_equations=grocer_model('equations')
grocer_linear=grocer_model('linearity')
grocer_coeffs=grocer_model('coeffs')
grocer_indcoeffs=spget(grocer_model('eq params'))
grocer_params=grocer_model('params')
grocer_indparams=spget(grocer_model('eq params'))
grocer_valparams=zeros(length(grocer_params),1)
for i=2:size(grocer_params)
   grocer_valparams(i-1)=grocer_params(i)
end
grocer_namecoeffs=grocer_coeffs(1)(2:$)
grocer_nameparams=grocer_params(1)(2:$)
grocer_namendos=grocer_model('name endo')
grocer_namexos=grocer_model('name exo')
grocer_nameresids=grocer_model('name resid')
grocer_listexog=grocer_model('names for regressions')
 
grocer_resid=grocer_model('name resid')
 
grocer_tsmat_names=grocer_tsmat('names')
grocer_series=grocer_tsmat('series')
 
grocer_one=tlist(['ts';'freq';'dates';'series'],grocer_tsmat('freq'),grocer_tsmat('dates'),ones(size(grocer_series,1),1))
grocer_ts=grocer_one
grocer_zero=grocer_ts
grocer_zero('series')=zeros(size(grocer_series,1),1)
 
if typeof(grocer_indeq) == 'string' then
   grocer_indeqnum=[]
   grocer_nameq=grocer_model('name eq')
   for grocer_j=1:size(grocer_indeq,'*')
      grocer_indeqj=stripblanks(grocer_indeq(grocer_j))
      grocer_indeqnumj=find(grocer_nameq == grocer_indeqj)
      if isempty(grocer_indeqnumj) then
         warning('equation '+grocer_indeqj+' not found')
      end
      grocer_indeqnum=[grocer_indeqnum ; grocer_indeqnumj]
   end
 
elseif typeof(grocer_indeq) == 'constant' then
   grocer_indeqnum=grocer_indeq
 
end
 
grocer_neq=size(grocer_indeqnum,1)
if size(grocer_save,'*') == 1 then
   grocer_save=grocer_save*ones(grocer_neq,1)
end
 
grocer_j=1
while grocer_j <= grocer_neq
// I use while instead of for, because there may happen problems with the stack with
//  versions under Scilab 5.x
 
   grocer_indeqj=grocer_indeqnum(grocer_j)
   grocer_linearj=grocer_linear(grocer_indeqj)
   if ~grocer_linearj then
      write(%io(2),'equation '+grocer_indeq(grocer_j)+' is not linear and wo''nt be estimated','(a)')
      grocer_listout($+1)='not estimated'
   else
      grocer_indparam_j=find(grocer_indparams(:,2) == grocer_indeqj)
      for grocer_k=1:size(grocer_indparam_j,2)
          execstr(grocer_nameparams(grocer_indparam_j(grocer_k))+'=grocer_valparams(grocer_indparam_j(grocer_k))')
      end
       
      grocer_eqj=grocer_equations(grocer_indeqj)
      grocer_indeqj_listexog=grocer_listexog(grocer_indeqj)
      grocer_indeqj_namecoeff=grocer_indeqj_listexog(:,1)
      grocer_indeqj_namexos=grocer_indeqj_listexog(:,2)
      grocer_eqj_namevari=[grocer_namendos(find(grocer_model('eq endos')(:,grocer_indeqj)~=0)) ;
                       grocer_namexos(find(grocer_model('eq exos')(:,grocer_indeqj)~=0)) ]
      for grocer_i=1:size(grocer_eqj_namevari,1)
         grocer_k=find(grocer_tsmat_names == grocer_eqj_namevari(grocer_i))
         if isempty(grocer_k) then
            warning('series '+grocer_eqj_namevari(grocer_i)+' not in input tsmat; progra    m will use an existing variable with that name, if any')
         else
            grocer_ts('series')=grocer_series(:,grocer_k)
            execstr(grocer_eqj_namevari(grocer_i)+'=grocer_ts')
         end
      end
 
      grocer_eqj_resid=grocer_nameresids(find(grocer_model('eq resids')(:,grocer_indeqj)~=0))
      for grocer_i=1:size(grocer_eqj_resid,1)
         execstr(grocer_eqj_resid(grocer_i)+'=grocer_zero')
      end
      // set the value of the coefficients in the equation to 0
      // in order to calculate properly the values of the endogenous variables
      execstr(grocer_indeqj_namecoeff+'=0')
      grocer_indequal=strindex(grocer_eqj,'=')
      [y,namey,x,namexos,prests,boundsvarb,nonna]=...
      explouniv(strsubst(part(grocer_eqj,1:grocer_indequal-1)+'-('+part(grocer_eqj,grocer_indequal+1:length(grocer_eqj))'+')',' ',''),...
             strsubst(grocer_indeqj_namexos,' ',''),[],['endogenous';'exogenous'],%t,grocer_dropna)
      // provides the results from the regression of the vector y
      // on the vector x
      result=grocer_func(y,x,varargin(:))
 
      // saves the names, the bounds if the regression involves ts
      result(1)($+1) = 'prests'
      result(1)($+1) = 'namey'
      result(1)($+1) = 'namex'
      result(1)($+1) = 'dropna'
      result('prests')=prests
      result('namex')=grocer_indeqj_namecoeff
      result('namey')=grocer_eqj
      result('dropna')=grocer_dropna
 
      if prests then
         result(1)($+1) = 'bounds'
         result('bounds')=boundsvarb
      end
 
      if grocer_dropna then
         result(1)($+1)='nonna'
         result('nonna')=nonna
      end
      execstr('result'+string(grocer_j)+'=result')
      execstr('grocer_listout($+1)=result'+string(grocer_j))
      if grocer_prt then
         prtuniv(result)
         pltuniv(result,'all')
      end
      if grocer_save(grocer_j) then
         grocer_bet=result('beta')
         for grocer_k=1:size(grocer_indeqj_namecoeff,1)
            grocer_indcoeff_k=find(grocer_namecoeffs == grocer_indeqj_namecoeff(grocer_k))
            grocer_coeffs(grocer_indcoeff_k+1)=grocer_bet(grocer_k)
         end
         grocer_model('coeffs')=grocer_coeffs
      end
   end
   grocer_j=grocer_j+1
end
    //
 
endfunction
