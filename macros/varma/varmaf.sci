function rvarmaf=varmaf(grocer_namevarma,grocer_hprev,varargin)
 
// PURPOSE: performs forecasting from a VARMA model
// ------------------------------------------------------------
// INPUT:
// * grocer_namevarma = the tlist results resulting from a VARMA
//   estimation or the same between quotes (to have its name
//   saved)
// * grocer_hprev = the forecast period which can be either
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
// rvarmaf = a results tlist with:
//   . rvarmaf('meth')  = 'varmaf'
//   . rvarmaf('namevarma') = the name of the varma tlist result
//    (if entered between quotes)
//   . rvarmaf('rvarma') = the varma tlist result used for
//     forecasting
//   . rvarmaf('h forecast') = the forecast horizon
//   . rvarmaf('forecast') = the forecast
//   . rvarmaf('forecast var') = the forecast variance
//   . rvarmaf('fore_namei')  = vector or ts of forecasts called
//     by its name prefixed by 'fore_'
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2013
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prt=%t
 
// give a name to the VARMA and store the VARMA itself
select type(grocer_namevarma)
case 10 then
   execstr('grocer_rvarma='+grocer_namevarma)
case 16 then
   grocer_rvarma=grocer_namevarma
   grocer_namevarma=emptystr()
end
 
// retrieve some elements stored in the varma results tlist
grocer_prests=grocer_rvarma('prests')
for i=22:26
   execstr('grocer_'+grocer_rvarma(1)(i)+'=grocer_rvarma(i)')
end
 
labels1='grocer_e4_'+['m';'s';'r';'g';'k'; 'q'; 'Q' ; 'p' ;'P';'type';'r';'n']
labels1b='grocer_'+['G';'V';'namey';'E4OPTION';'e4param']
labels1=[labels1 ;labels1b]
labels2=['nendo';'seas';'nexo';'lagexo';'k'; 'q'; 'Q' ; 'p' ;'P';'type';...
'nexo';'n';'G';'V';'namey';'E4OPTION';'e4param']
for i=1:size(labels1,1)
   execstr(labels1(i)+'=grocer_rvarma('''+labels2(i)+''')')
end
grocer_e4_userflag=0
 
grocer_e4_nargin=length(varargin)
for grocer_e4_i=grocer_e4_nargin:-1:1
   select typeof(varargin(grocer_e4_i))
   case 'string' then
      grocer_e4_varaux=strsubst(varargin(grocer_e4_i),' ','')
      if part(grocer_e4_varaux,1:4) == 'exo=' then
         execstr('grocer_e4_exo='+part(grocer_e4_varaux,5:length(grocer_e4_varaux)))
         varargin(grocer_e4_i)=null()
      elseif grocer_e4_varaux == 'noprint' then
         grocer_prt=%f
      end
   end
end
 
// calculate the range for forecasting
[grocer_n0,grocer_nf,grocer_hprev]=hprev2vec(grocer_rvarma,grocer_hprev)
grocer_e4_z=grocer_rvarma('z')
 
// calculate the values of the vector z of endogenous and exogenous (if any)
// variables before the forecasting period
if grocer_e4_r & ~exists('grocer_e4_exo','local') then
   if grocer_rvarma('prests') then
      grocer_b0=grocer_rvarma('bounds')
      grocer_b1=grocer_b0
      [grocer_b0num,grocer_f0]=date2num_fq(grocer_b0($))
      grocer_b1num=[grocer_b0num+min(grocer_n0,0) ; grocer_b0num($)+grocer_nf]
      grocer_b1num2=[grocer_b1num(1):grocer_b1num(2)]
      for grocer_i=2:size(grocer_b1,1)/2
         grocer_b1num2=[grocer_b1num2 , grocer_b1num(2*grocer_i-1):grocer_b1num(2*grocer_i)]
      end
      grocer_aux=tlist(['ts';'freq';'dates';'series'],grocer_f0,grocer_b1num2',[grocer_e4_z(:,1) ; zeros(grocer_nf,1)])
      grocer_e4_exo=explouniv(grocer_rvarma('namexos'),'grocer_aux',[grocer_b0(1:$-1) ; grocer_hprev($)],['endo';'exo'],%f,%f)
      grocer_e4_exo=grocer_e4_exo($-grocer_nf+min(grocer_n0,0)+1:$)
 
   else
      grocer_aux=[grocer_y ; zeros(grocer_nf,1)]
      grocer_e4_exo=explouniv(grocer_rvarma('namexos'),'grocer_aux',[],['endo';'exo'],%f,%f)
      grocer_e4_exo=grocer_e4_exo($-grocer_nf+min(grocer_n0,0)+1:$)
   end
end
 
if grocer_e4_r then
   [yf,Bf] = foremod(grocer_rvarma('coeff'),grocer_rvarma('theta2mat'),grocer_e4_z,[grocer_n0 grocer_nf],grocer_e4_exo)
else
   [yf,Bf] = foremod(grocer_rvarma('coeff'),grocer_rvarma('theta2mat'),grocer_e4_z,[grocer_n0 grocer_nf])
end
 
rvarmaf=tlist(['results';'meth';'namevarma';'rvarma';'h forecast';'forecast';'forecast var'],...
'varmaf',grocer_namevarma,grocer_rvarma,grocer_hprev,yf,Bf)
 
for i=1:grocer_e4_m
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
   nam=strsubst(nam,' ','_')
   ch='prev_'+nam+'=aux'
   execstr(ch)
   rvarmaf(1)($+1)='fore_'+nam
   ch='prev_'+nam
   execstr('rvarmaf($+1)='+ch)
end
 
if grocer_prt then
   prtvarf(rvarmaf,%io(2))
end
 
endfunction
 
