function [grocer_model,rsur]=surmod(grocer_model,grocer_tsmat,grocer_indeq,varargin)
 
// PURPOSE: estimate by ols equations of a model
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model tlist
// * grocer_tsmat = a tsmat containing all data needed for
//   estimating the equation (should be the tsmat associated to
//    the model, created by function create_dbmod)
// * grocer_indeq =
//   - a string, the name of the equation to estimate or the
//   keyword 'all' (to estimate all equations)
//   - or an integer, the index of the equation in the model
// * varargin = optional arguments:
//   - 'noprint' if the user does not want to print the result
//   (default: results are displayed on screen)
//   - 'save=%t' if the user wants to save the estimated
//   coefficients in the model tlist
//   - the string 'maxit=xx' if the user wants to set the
//     maximum # of iterations to xx (default=100)
//   - the string 'tol=xx' if the user wants to set the
//     convergence criterion to xx (default=sqrt(%eps))
// ------------------------------------------------------------
// OUTPUT:
// varargout =  a variable number of arguments with:
// * Arg # 1: the input model tlist, updated with the estimated
//   coefficients of the equations given in argument
//   grocer_indeq if the user has entered the option 'save=%t'
// * following arguments: a variable number of ols results
//   tlists, each one corresponding to the results of the
//   corresponding estimated equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018-2019
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_dropna=%f
grocer_prt=%t
grocer_save=%f
grocer_itmax=100
grocer_crit=sqrt(%eps)
varargout=list(grocer_model)
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      if part(grocer_argi,1:4) == 'save' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif grocer_argi == 'noprint' then
         varargin(grocer_i)=null()
         grocer_prt=%f
      elseif grocer_argi == 'dropna' then
         varargin(grocer_i)=null()
         grocer_prt=%f
      end
   end
end
 
if typeof(grocer_model) == 'string' then
   grocer_model=create_model(grocer_model)
end
 
grocer_equations=grocer_model('equations')
grocer_linear=grocer_model('linearity')
grocer_coeffs=grocer_model('coeffs')
grocer_params=grocer_model('params')
grocer_namecoeffs=grocer_coeffs(1)(2:$)
grocer_nameparams=grocer_params(1)(2:$)
for grocer_i=1:size(grocer_nameparams,1)
    execstr(grocer_nameparams(grocer_i)+'=grocer_params(grocer_i+1)')
end
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
      grocer_indeqnum=[grocer_indeqnum ; grocer_indeqnumj]
   end
 
elseif typeof(grocer_indeq) == 'constant' then
   grocer_indeqnum=grocer_indeq
 
end
 
grocer_neq=size(grocer_indeqnum,1)
grocer_namey=emptystr(grocer_neq,1)
grocer_eqs=emptystr(grocer_neq,1)
grocer_namex=[]
grocer_indx=zeros(grocer_neq,1)
grocer_names4sur=[]
 
grocer_j=1
while grocer_j <=grocer_neq
// I use while instead of for, because there may happen problems with the stack with for under
// Scilab 5.x
   grocer_linearj=grocer_linear(grocer_j)
   if ~grocer_linearj then
      write(%io(2),'equation # '+string(grocer_j)+' is not linear and system wo''nt be estimated','(a)')
   else
 
      grocer_indeqj=grocer_indeqnum(grocer_j)
      grocer_eqj=grocer_equations(grocer_indeqj)
      grocer_eqs(grocer_j)=grocer_eqj
      grocer_indeqj_listexog=grocer_listexog(grocer_indeqj)
      grocer_indeqj_namecoeff=grocer_indeqj_listexog(:,1)
      grocer_indeqj_namexos=grocer_indeqj_listexog(:,2)
      grocer_eqj_namevari=[grocer_namendos(find(grocer_model('eq endos')(:,grocer_indeqj)~=0)) ;
                       grocer_namexos(find(grocer_model('eq exos')(:,grocer_indeqj)~=0)) ]
 
      for grocer_i=1:size(grocer_eqj_namevari,1)
         grocer_k=find(grocer_tsmat_names == grocer_eqj_namevari(grocer_i))
         grocer_ts('series')=grocer_series(:,grocer_k)
         execstr(grocer_eqj_namevari(grocer_i)+'=grocer_ts')
      end
      grocer_eqj_resid=grocer_nameresids(find(grocer_model('eq resids')(:,grocer_indeqj)~=0))
      for grocer_i=1:size(grocer_eqj_resid,1)
         execstr(grocer_eqj_resid(grocer_i)+'=grocer_zero')
      end
      // set the value of the coefficients in the uqyuation to 0
      // in order to calculate properly the values of the endogenous variables
      execstr(grocer_indeqj_namecoeff+'=0')
      grocer_indequal=strindex(grocer_eqj,'=')
      grocer_namey(grocer_j)=strsubst(part(grocer_eqj,1:grocer_indequal-1)+'-('+part(grocer_eqj,grocer_indequal+1:length(grocer_eqj))'+')',' ','')
      grocer_namex=[grocer_namex ; strsubst(grocer_indeqj_namexos,' ','')]
      grocer_names4sur=[grocer_names4sur ; grocer_indeqj_namecoeff ]
      grocer_indx(grocer_j)=size(grocer_indeqj_namexos,1)
   end
   grocer_j=grocer_j+1
end
[mats,names,prests,b]=explon(list(grocer_namey,grocer_namex),['endogenous'  'exogenous'],[],%t,grocer_dropna)
y=mats(1)
xall=mats(2)
nobs=size(y,1)
indxc=[0 ; cumsum(grocer_indx) ]
x=zeros(nobs*grocer_neq,indxc($))
for i=1:grocer_neq
   x(1+(i-1)*nobs:i*nobs,indxc(i)+1:indxc(i+1))=xall(:,indxc(i)+1:indxc(i+1))
end
 
rsur=sur1(y,x,grocer_crit,grocer_itmax)
rsur('prests')=prests
if prests then
   rsur(1)($+1)='bounds'
   rsur('bounds')=b
end
rsur('dropna')=grocer_dropna
rsur('namecoef')=grocer_names4sur
rsur('namey')=grocer_eqs
rsur('eqs')=grocer_eqs
listcoef=list()
for j=1:grocer_neq
   listcoef($+1)=[indxc(j)+1:indxc(j+1)]'
end
rsur('coefs')=listcoef
if grocer_save then
   for j=1:size(grocer_names4sur,1)
      execstr('grocer_coeffs('''+grocer_names4sur(j)+''')=rsur(''beta'')('+string(j)+')')
   end
    grocer_model('coeffs')=grocer_coeffs
end
 
if grocer_prt then
   prtsys(rsur)
end
 
endfunction
