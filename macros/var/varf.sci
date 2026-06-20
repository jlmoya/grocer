function [rvarf]=varf(grocer_namevar,grocer_hprev,varargin)
 
// PURPOSE: performs forecasting by the mean of a vector
// autogressive estimation
// ------------------------------------------------------------
// INPUT:
// * grocer_namevar = the tlist results resulting from a VAR,
//   an ECM, a BVAR or a BECM estimation or the same grocer_between
//   quotes (tohave it's name saved)
// * grocer_hprev = the prevision period which can be either
//   . a [n1 n2] constant vector where n1 and n2 are the lead
//     over the last period of the estimation (n1<=0 means that
//     the forecast begins within the estimation period)
//   . a n constant which is equivalent to [1 n] (forecast
//     begins just after the estimation period)
//   . a [n1 n2] string vector where n1 and n2 are the time
//     periods for forecasting (a posibility open only if the
//     VAR has been performed with ts)
//   . a n string which is equivalent to [1 n] (forecast
//     begins just after the estimation period)
// * varargin
//   . 'xp=xx' (necessary if the variables in the VAR has been
//     given as a matrix) where xx is [# of forecasting dates ;
//      # of exogenous variables in the var] for the values of
//      exogenous variables over the forecasting period
//   . the string 'noprint' if the user doesn't want to
//     print the results of the forecast
// ------------------------------------------------------------
// OUTPUT:
// rvarf = a results tlist with:
//   . rvarf('grocer_meth')  = 'rvarf'
//   . rvarf('grocer_rvar')  = results tlist of the originating var
//   . rvarf('prev')  = matrix of forecasts
//   . grocer_rvar('prev_grocer_namex')  = vector or ts of forecasts called
//     by their names preceded by 'prev_'
// ------------------------------------------------------------
// NOTE: if the var structure comes from an ecm estimation,
// then what is stored is the forecasted levels; if it comes
// from an ordinary var, then what is stored is the forecasted
// values of the endogenous variables, as they have been given
// by the user (for instance, if she has given one as delts(ts),
// then what is forecasted is delts(ts), not ts)
// ------------------------------------------------------------
// Copyright Eric Dubois 2002-2010
// http://grocer.toolbox.free.fr/grocer.html
 
prt=%t
for i=1:length(varargin)
   if or(part(varargin(i),1:7) == ['exo_st=' ; 'exo_lt=']) then
      execstr('grocer_'+grocer_str7+'string2vec(part(grocer_argi,8:length(grocer_argi)),'';'')')
   elseif part(varargin(i),1:2) == 'xp' then
      execstr('grocer_exo_st='+'string2vec(part(grocer_argi,8:length(grocer_argi)),'';'')')
   elseif varargin(i) == 'noprint' then
      prt=%f
   end
end
 
  // give a name to the VAR and store the VAR itself
select type(grocer_namevar)
case 10 then
   execstr('grocer_rvar='+grocer_namevar)
case 16 then
   grocer_rvar=grocer_namevar
   grocer_namevar=emptystr()
end
 
// retrieves useful parameters from the structures
grocer_nlag=grocer_rvar('nlag')
grocer_nobs=grocer_rvar('nobs')+grocer_nlag
grocer_prests=grocer_rvar('prests')
grocer_bet=grocer_rvar('beta')
// retrive the name of exogenous and remove the indication
// (if any) that the variable has been constrained to be
// present in the regression
grocer_namex=strsubst(grocer_rvar('namex'),' (*)','')
grocer_namey=grocer_rvar('namey')
grocer_ny=size(grocer_namey,1)
grocer_meth=grocer_rvar('meth')
grocer_ecmflag=%f
 
grocer_nbr=0
if grocer_meth == 'ecm' | grocer_meth == 'becm' then
   jres=grocer_rvar('jres')
   grocer_namey=jres('namey')
   grocer_nbr=grocer_rvar('nb_coint_relat')
   if grocer_nbr ~= 0 then
      grocer_ecmflag=%t
   end
end
// for forecasting, it does not matter whether the var is
// bayesian or not
 
// calculate the range for forecasting
[grocer_n0,grocer_nf,grocer_hprev]=hprev2vec(grocer_rvar,grocer_hprev)
 
if grocer_prests then
   lastbound=grocer_rvar('bounds')($)
   grocer_bounds_st=num2date(date2num(lastbound)+[grocer_n0 grocer_nf],date2fq(lastbound))
   grocer_bounds_lt=num2date(date2num(lastbound)+[grocer_n0 grocer_nf]-1,date2fq(lastbound))
end
 
if grocer_ecmflag then
   grocer_namex=grocer_namex(grocer_nbr+1:$)
end
 
if ~exists('grocer_exo_st','local') & or(grocer_namex ~= 'const') then
      bounds(grocer_bounds_st(1),grocer_bounds_st(2))
      grocer_exo_st=explone(grocer_namex)
elseif or(grocer_namex ~= 'const') then
   execstr(grocer_exo_st)
else
   grocer_exo_st=ones(grocer_nf-grocer_n0+1,1)
end
 
if grocer_ecmflag then
   evec=jres('evec')
   yvec=jres('y')
   if ~exists('grocer_exo_lt','local') then
      bounds(grocer_bounds_st(1),grocer_bounds_st(2))
      grocer_namexo_lt=jres('namexo_lt')
      grocer_namexo_lt(grocer_namexo_lt == 'trend')='trend^1'
      grocer_exo_lt=explone(grocer_namexo_lt)
      for i=1:size(grocer_namexo_lt,1)
         if part(grocer_namexo_lt,1:6) == 'trend^' then
            execstr('expon='+part(grocer_namexo_lt,7))
            grocer_exo_lt(:,i)=(jres('nobs')+jres('nlags')+[grocer_n0:grocer_nf]').^expon
         end
      end
   else
      execstr(grocer_exo_lt)
   end
   grocer_exo_lt=[grocer_exo_lt ; zeros(1,size(grocer_exo_lt,2))]
end
 
if grocer_n0 <= 1 & grocer_n0 > -grocer_nobs then
   yext=grocer_rvar('yall')(grocer_nobs+grocer_n0-1:-1:grocer_nobs-grocer_nlag+grocer_n0,:)
   if grocer_ecmflag then
      lyp=[yvec($+grocer_n0-1,:) grocer_exo_lt(1,:)]
   end
else
// forecasting begins some period after the estimation period
// a possibility open only for ts
// then use the underlying data whose name has been stored
// in the var tlist
   yext=zeros(grocer_nlag,grocer_ny)
// first adjust the bounds to feed the first lags
   fq=date2fq(grocer_hprev(1))
   b1=num2date(date2num(grocer_hprev(1))-grocer_nlag,fq)
   b2=num2date(date2num(grocer_hprev(1))-1,fq)
   for i=1:grocer_ny
      val=ts2vec(evstr(grocer_rvar('grocer_namey')(i)),[b1 ; b2])
      yext(:,i)=val(grocer_nlag:-1:1)
   end
   if grocer_ecmflag then
      lyp=[zeros(1,grocer_ny) grocer_exo_lt(1,:)]
      for i=1:grocer_ny
         lyp(i) = values(evstr(jres('grocer_namey')(i)),b2)
      end
   end
end
 
yp=zeros(grocer_nf-grocer_n0+1,grocer_ny)
// start forecasting
for i=grocer_n0:grocer_nf
   if grocer_ecmflag then
      yp(i-grocer_n0+1,:)=[matrix(yext',1,grocer_nlag*grocer_ny) lyp($,:)*evec(:,1:grocer_nbr) grocer_exo_st(i-grocer_n0+1,:)]*grocer_bet
      lyp=[lyp ;lyp($,1:grocer_ny)+yp(i-grocer_n0+1,:) grocer_exo_lt(i+1,:)]
   else
      yp(i-grocer_n0+1,:)=[matrix(yext',1,grocer_nlag*grocer_ny) grocer_exo_st(i)]*grocer_bet
   end
   yext(grocer_nlag,:)=[]
   yext=[yp(i-grocer_n0+1,:) ; yext]
end
 
if grocer_ecmflag then
   yp=lyp(2:$,1:$-size(grocer_exo_lt,2))
end
 
rvarf=tlist(['results';'meth';'namevar';'rvar';'h forecast';'forecast'],...
'varf',grocer_namevar,grocer_rvar,grocer_hprev,yp)
 
for i=1:grocer_ny
   if grocer_prests then
      aux=reshape(yp(:,i),grocer_hprev(1))
   else
      aux=yp(:,i)
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
   rvarf(1)($+1)='prev_'+nam
   ch='prev_'+nam
   execstr('rvarf($+1)='+ch)
end
 
if prt then
   prtvarf(rvarf,%io(2))
end
 
endfunction
