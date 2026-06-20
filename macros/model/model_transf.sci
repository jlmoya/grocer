function grocer_model=model_transf(grocer_model,varargin)
 
// PURPOSE: from a model tlist containing only lists of
// equations, endogenous, exogenous, coefficients... build
// various objects useful for simulation: function and
// Jacobian with endogenous replaced by a vector grocer_param
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model tlist with the list of endogenous,
//                  exogenous, residuals, coefficients and
//                  equations fields filled
// ------------------------------------------------------------
// OUTPUT:
// * grocer_model = a model tlist with all fields filled
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2015
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_nargin=length(varargin)
grocer_GS=%f
grocer_verbose=%f
for grocer_i=1:grocer_nargin
   select varargin(grocer_i)
   case 'GS' then
      grocer_GS=%t
   case 'verbose' then
      grocer_verbose=%t
   end
end
 
global grocer_listpredef grocer_unknown GROCERDIR ;
load(GROCERDIR+'\param\symb_listfunc.dat')
 
grocer_eq=grocer_model('equations')
grocer_neq=size(grocer_eq,1)
grocer_nameq=grocer_model('name eq')
 
[grocer_namendo,grocer_ind]=unique(grocer_model('name endo'))
grocer_ind=gsort(grocer_ind,'g','i')
grocer_namendo=grocer_model('name endo')(grocer_ind)
grocer_nendo=size(grocer_namendo,1)
grocer_listeqperendo=spzeros(grocer_nendo,grocer_neq)
grocer_listeqperendo_wol=spzeros(grocer_nendo,grocer_neq)
grocer_lags_endos=list()
for grocer_i=1:grocer_nendo
   grocer_lags_endos(grocer_i)=[]
end
 
[grocer_namecoeff,grocer_ind]=unique(grocer_model('name coeff'))
grocer_ind=gsort(grocer_ind,'g','i')
grocer_namecoeff=grocer_model('name coeff')(grocer_ind)
grocer_ncoeffs=size(grocer_namecoeff,1)
grocer_listeqpercoeff=spzeros(grocer_ncoeffs,grocer_neq)
 
[grocer_nameparam,grocer_ind]=unique(grocer_model('name param'))
grocer_ind=gsort(grocer_ind,'g','i')
grocer_nameparam=grocer_model('name param')(grocer_ind)
grocer_nparam=size(grocer_nameparam,1)
grocer_listeqperparam=spzeros(grocer_nparam,grocer_neq)
 
[grocer_namexo,grocer_ind]=unique(grocer_model('name exo'))
grocer_ind=gsort(grocer_ind,'g','i')
grocer_namexo=grocer_model('name exo')(grocer_ind)
grocer_nexo=size(grocer_namexo,1)
grocer_listeqperexo=spzeros(grocer_nexo,grocer_neq)
grocer_lags_exos=list()
for grocer_i=1:grocer_nexo
   grocer_lags_exos(grocer_i)=[]
end
 
[grocer_nameresid,grocer_ind]=unique(grocer_model('name resid'))
grocer_ind=gsort(grocer_ind,'g','i')
grocer_nameresid=grocer_model('name resid')(grocer_ind)
grocer_nresid=size(grocer_nameresid,1)
grocer_listeqperresid=spzeros(grocer_nresid,grocer_neq)
grocer_lags_resid=list()
for grocer_i=1:grocer_nresid
   grocer_lags_resid(grocer_i)=[]
end
 
grocer_nameall=[grocer_namendo ; grocer_namexo]
 
grocer_texts=list()
for grocer_i=1:grocer_neq
   grocer_texts(grocer_i)=[]
end
grocer_analyses=grocer_texts
grocer_indendos=grocer_texts
grocer_indsigns=grocer_texts
grocer_laginfos=grocer_texts
grocer_listnamex=grocer_texts
grocer_listcoeffpereq=grocer_texts
grocer_linear=(zeros(grocer_neq,1) == 0)
grocer_maxlag=0
 
// first analyses the equations and fill various interim fields
for grocer_i=1:grocer_neq
   [txt_eq,analysed_eq,indendo_eq,ind_signs_eq,lags_info_eq,grocer_listeqperendo,grocer_listeqperendo_wol,...
      grocer_listeqperexo,grocer_listeqperresid,grocer_listeqpercoeff,grocer_listeqperparam,grocer_namexo,namex4regression,linear,...
       grocer_lags_endos,grocer_lags_exos,grocer_lags_resid,grocer_maxlag,grocer_namendo,grocer_nameresid,grocer_namecoeff,grocer_nameparam,grocer_eqi]=...
      model_transfeq1(grocer_i,grocer_eq(grocer_i),grocer_nameq(grocer_i),...
      grocer_listeqperendo,grocer_listeqperendo_wol,grocer_listeqperexo,...
      grocer_listeqperresid,grocer_listeqpercoeff,grocer_listeqperparam,grocer_namendo,grocer_namexo,grocer_nameresid,grocer_namecoeff,grocer_nameparam,...
      grocer_lags_endos,grocer_lags_exos,grocer_lags_resid,grocer_maxlag,grocer_verbose)
   grocer_eq(grocer_i)=grocer_eqi
   grocer_texts(grocer_i)=txt_eq
   grocer_analyses(grocer_i)=analysed_eq
   grocer_indendos(grocer_i)=indendo_eq
   grocer_indsigns(grocer_i)=ind_signs_eq
   grocer_laginfos(grocer_i)=lags_info_eq
   grocer_listnamex(grocer_i)=namex4regression
   grocer_linear(grocer_i)=linear
 
end
 
n_newcoeff=size(grocer_namecoeff,1)-size(grocer_model('name coeff'),1)
grocer_model('name coeff')=grocer_namecoeff
grocer_model('coeffs')(1)=['coeffs' ;grocer_namecoeff]
for i=1:n_newcoeff
   grocer_model('coeffs')($+1)=[]
end
 
n_newparam=size(grocer_nameparam,1)-size(grocer_model('name param'),1)
grocer_model('name param')=grocer_nameparam
grocer_model('params')(1)=['params'; grocer_nameparam]
for i=1:n_newparam
   grocer_model('params')($+1)=[]
end
 
grocer_model('name endo')=grocer_namendo
grocer_model('name exo')=grocer_namexo
grocer_model('name resid')=unique(grocer_model('name resid'))
grocer_model('name coeff')=grocer_namecoeff
 
grocer_model('equations')=grocer_eq
grocer_model('eq coeffs')=grocer_listeqpercoeff
grocer_model('eq params')=grocer_listeqperparam
grocer_model('eq endos')=grocer_listeqperendo
grocer_model('eq exos')=grocer_listeqperexo
grocer_model('eq resids')=grocer_listeqperresid
grocer_model('lags endos')=grocer_lags_endos
grocer_model('lags exos')=grocer_lags_exos
grocer_model('lags resids')=grocer_lags_resid
grocer_model('maxlag')=grocer_maxlag
grocer_model('name exo')=grocer_namexo
grocer_model('names for regressions')=grocer_listnamex
grocer_model('linearity')=grocer_linear
 
nexo=size(grocer_model('name exo'),1)
nresid=size(grocer_model('name resid'),1)
 
lagged_endos=1:grocer_nendo
for i=grocer_nendo:-1:1
   if sum(abs(grocer_lags_endos(i))) == 0 then
      lagged_endos(i)=[]
   end
end
grocer_model('non empty lagged endos')=lagged_endos
 
if grocer_neq ~= grocer_nendo then
   warning('# of equations ('+string(grocer_neq)+') different from the # of endogenous variables ('+string(grocer_nendo)+')')
   grocer_model('transf')=%f
 
else
   // determine the prolog of the model and the corresponding objects
   [prolog_string2run,prolog_func_txts,prolog_Jac_txts,remaining_eq,remaining_endo,removed_eq,removed_endo]=...
   model_prolog(grocer_model,grocer_namendo,grocer_texts,grocer_analyses,grocer_indendos,grocer_indsigns,grocer_laginfos)
   grocer_model('prolog string2run')=prolog_string2run
   grocer_model('prolog func txts')=prolog_func_txts
   grocer_model('prolog Jac txts')=prolog_Jac_txts
   grocer_model('prolog endo')=removed_endo
   grocer_model('prolog eq')=removed_eq
   n_removed_endo=size(removed_endo,2)
   n_removed_eq=size(removed_endo,2 )
 
    // determine the epilog of the model and the corresponding objects
   [epilog_string2run,epilog_func_txts,epilog_Jac_txts,remaining_eq,remaining_endo,removed_eq,removed_endo]=...
   model_epilog(remaining_eq,remaining_endo,removed_eq,removed_endo,grocer_listeqperendo_wol,...
   grocer_namendo,grocer_texts,grocer_analyses,grocer_indendos,grocer_indsigns,grocer_laginfos)
   grocer_model('epilog string2run')=epilog_string2run
   grocer_model('epilog func txts')=epilog_func_txts
   grocer_model('epilog Jac txts')=epilog_Jac_txts
   grocer_model('epilog endo')=removed_endo(n_removed_endo+1:$)
   grocer_model('epilog eq')=removed_eq(n_removed_eq+1:$)
 
   // determine the objects corresponding to the heart of the model
   [func_hearttext,Jac_hearttext,Jac_indexes,Jac_rhs,gs_string2run,func_gstxts,Jac_gstxts,pivots]=model_heart(remaining_eq,remaining_endo,removed_eq,removed_endo,...
   grocer_namendo,grocer_texts,grocer_analyses,grocer_indendos,grocer_indsigns,grocer_laginfos,grocer_GS)
 
   grocer_model('heart func txt')=func_hearttext
   grocer_model('heart Jac txt')=Jac_hearttext
   grocer_model('heart Jac rhs')=Jac_rhs
   grocer_model('heart Jac indexes')=Jac_indexes
   grocer_model('heart endogenous')=pivots'
   grocer_model('heart equations')=remaining_eq
   grocer_model('gs string2run')=gs_string2run
   grocer_model('gs func txts')=func_gstxts
   grocer_model('gs Jac txts')=Jac_gstxts
 
   // now check if there are variables declared both endogenous and exogenous
   variables=[grocer_model('name endo') ; grocer_model('name exo')]
   [lone_vari,ind_vari]=unique(variables)
   total=1:grocer_nendo+nexo;
   total(ind_vari)=[]
   // now total contains only the indexes of variables that have been already declared
   // endogenous and exogenous
   ind_endo_exo=find(grocer_nendo+1 <= total & total <= grocer_nendo+nexo)
   if ~isempty(ind_endo_exo) then
      warning('variable '+variables(total(ind_endo_exo))+' has been declared both as endogenous and exogenous')
   end
 
   // now check if there are variables declared endogenous and residuals
   variables=[grocer_model('name endo') ; grocer_model('name resid')]
   [lone_vari,ind_vari]=unique(variables)
   total=1:grocer_nendo+nresid;
   total(ind_vari)=[]
   // now total contains only the indexes of variables that have been already declared
 
   // endogenous and exogenous
   ind_endo_resid=find(grocer_nendo+1 <= total & total <= grocer_nendo+nresid)
   if ~isempty(ind_endo_resid) then
      warning('variable '+variables(total(ind_endo_resid))+' has been declared both as endogenous and residual')
   end
 
   // now check if there are variables declared exogenous and residuals
   variables=[grocer_model('name exo') ; grocer_model('name resid')]
   [lone_vari,ind_vari]=unique(variables)
   total=1:nexo+nresid;
   total(ind_vari)=[]
   // now total contains only the indexes of variables that have been already declared
   // endogenous and exogenous
   ind_exo_resid=find(nexo+1 <= total & total <= nexo+nresid)
   if ~isempty(ind_exo_resid) then
      warning('variable '+variables(total(ind_endo_resid))+' has been declared both as exogenous and residual')
   end
   grocer_model('transf')=%t
 
end
 
endfunction
