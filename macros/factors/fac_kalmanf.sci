function rfacf=fac_kalmanf(grocer_resfac,grocer_hprev,varargin)
 
// PURPOSE: performs forecasting from a dynamic factor model
// estimated by Kalman filter
// ------------------------------------------------------------
// INPUT:
// * grocer_resfac = the tlist results resulting from adynamic
//  factor model estimated by Kalman filter or the same between
//  quotes (to have its name saved)
// * hprev = the prevision period which can be either
//   . a [n1 n2] constant vector where n1 and n2 are the lead
//     over the last period of the estimation (n1<=0 means that
//     the forecast begins within the estimation period)
//   . a n constant which is equivalent to [1 n] (forecast
//     begins just after the estimation period)
//   . a [n1 n2] string vector where n1 and n2 are the time
//     periods for forecasting (a posibility open only if the
//     VARMA has been estimated on ts)
//   . a n string which is equivalent to [1 n] (forecast
//     begins just after the estimation period)
// * varargin = a variable # of arguments that can be:
//   . 'exo=xx' (necessary if the variables in the VARMA has
//     been given as a matrix) where xx is either a string
//     betweeen double quotes, a ts or a matrix of size [# of
//     forecasting dates ; # of exogenous variables in the var]
//     for the values of exogenous variables over the
//     forecasting period
//   . the string 'noprint' if the user doesn't want to
//     print the results of the forecast
// ------------------------------------------------------------
// OUTPUT:
// rvarf = a results tlist with:
//   . rvarf('meth')  = 'rvarf'
//   . rvarf('rvar')  = results tlist of the originating var
//   . rvarf('prev')  = matrix of forecasts
//   . rvarf('varprev')  = variance of forecasts
//   . rvar('prev_namex')  = vector or ts of forecasts called
//     by their names preceded by 'prev_'
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prt=%t
 
// give a name to the VARMA and store the VARMA itself
select type(grocer_resfac)
case 10 then
   execstr('grocer_rfac='+grocer_resfac)
case 16 then
   grocer_rfac=grocer_resfac
   grocer_resfac=emptystr()
end
 
// retrieve some elements stored in the varma results tlist
grocer_prests=grocer_rfac('prests')
for i=22:26
   execstr('grocer_'+grocer_rfac(1)(i)+'=grocer_rfac(i)')
end
 
labels1=['E4OPTION';'e4param';'namey']
labels2=['E4OPTION';'e4param';'namey']
for i=1:size(labels1,1)
   execstr('grocer_'+labels1(i)+'=grocer_rfac('''+labels2(i)+''')')
end
grocer_e4_userflag=0
 
grocer_e4_nargin=length(varargin)
for grocer_e4_i=grocer_e4_nargin:-1:1
   grocer_varaux=varargin(grocer_i)
   if tyepof(grocer_varuax) == 'string' then
      if grocer_e4_varaux == 'noprint' then
         grocer_prt=%f
      end
   end
end
 
// calculate the range for forecasting
[grocer_n0,grocer_nf,grocer_hprev]=hprev2vec(grocer_rfac,grocer_hprev)
 
[yf,Bf,xf] = foremod(grocer_rfac('coeff'),grocer_rfac('theta2mat'),grocer_e4_z,[grocer_n0 grocer_nf],[])
yf=yf+(ones(grocer_nf-grocer_n0+1,1) .*. mean(grocer_rfac('y'),'r'))
 
rfacf=tlist(['results';'meth';'namefac_kalm';'rfac';'h forecast';'forecast';'fac forecast'],...
'fac_kalmanf',grocer_resfac,grocer_rfac,grocer_hprev,yf,xf(:,1:size(grocer_rfac('fac'),2)))
 
for i=1:size(grocer_namey,1)
   if grocer_prests then
      aux=reshape(yf(:,i),grocer_hprev(1))
   else
      aux=yf(:,i)
   end
   // remove all signs which can be interpreted as operations
   nam=grocer_namey(i)
   nam=strsubst(nam,'(','')
   nam=strsubst(nam,')','')
   nam=strsubst(nam,'+','_p_')
   nam=strsubst(nam,'-','_s_')
   nam=strsubst(nam,'*','_m_')
   nam=strsubst(nam,'/','_d_')
   ch='prev_'+nam+'=aux'
   execstr(ch)
   rfacf(1)($+1)='fore_'+nam
   ch='prev_'+nam
   execstr('rfacf($+1)='+ch)
end
 
if grocer_prt then
   prtvarf(rfacf,%io(2))
end
 
endfunction
 
