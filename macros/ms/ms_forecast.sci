function res=ms_forecast(grocer_rms,grocer_hprev,grocer_exo_com,grocer_exo_idio,grocer_prt)
 
// PURPOSE: forecast with a MSVAR model
// ------------------------------------------------------------
// INPUT:
// * grocer_rms = a tlist result from a ms switching estimation
// * grocer_hprev = the forecast period which can be either
//   . a [n1 n2] constant vector where n1 and n2 are the lead
//     over the last period of the estimation (n1<=0 means that
//     the forecast begins within the estimation period)
//   . a n constant which is equivalent to [1 n] (forecast
//     begins just after the estimation period)
//   . a [n1 n2] string vector where n1 and n2 are the time
//     periods for forecasting (a possibility open only if the
//     MS regression has been performed with ts)
//   . a n string which is equivalent to [1 n] (forecast
//     begins just after the estimation period)
// * grocer_exo_com = the data on the forecast horizon for the
//   non switching exogenous variables that can be:
//   . a (H x n_x) matrix with H the number of forecasts and
//     n_x the number of non switching exogenous variables
//   . a list of ts available over the forecasting horizon
//   . a list of (H x 1) vectors and ts available over the
//     forecasting horizon
//   . a (H x n_x) string matrix of names
//   (note: when the ms tlist results comes from a ms-mean
//    or a var estimation, the variables are useless and can
//    -therefore be omitted)
// * grocer_exo_idio = the data on the forecast horizon for the
//   switching exogenous variables that can be:
//   . a (H x n_z) matrix with H the number of forecasts and
//     n_z the number of switching exogenous variables
//   . a list of ts available over the forecasting horizon
//   . a list of (H x 1) vectors and ts available over the
//     forecasting horizon
//   . a (H x n_x) string matrix of names
//   (note: when the ms tlist results comes from a ms-mean
//    or a var estimation, the variables are useless and can
//    therefore be omitted)
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// * res('meth') = 'msf'
// * res('r_ms') = the tlist results from the MS estimation
// * res('pstates') = the (H x nb_states) matrix of the
//   probabilities of the respective states over the forecasting
//   horizon
// * res('prev_states') = the matrix of forecast of the endogenous
//   variables across the states
// * res('prev') = the matrix of forecast of the endogenous
//   variables
// * res('hprev') = the forecast period
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_nargout,grocer_nargin]=argn(0)
if grocer_nargin <5 then
   grocer_prt=%t
elseif strsubst(grocer_prt,' ','') == 'noprint' then
   grocer_prt=%f
end
 
// calculate the range for forecasting
[grocer_n0,grocer_nf,grocer_hprev]=hprev2vec(grocer_rms,grocer_hprev)
if grocer_n0 > 1 then
   disp('forecasts will be stored from the '+string(grocer_n0)+...
        ' the period after the estimation period, but forecasting will start'+ ...
        'immediately after the estimation period')
end
if grocer_nf < 0 then
   error(' you have entered only one period and it is before the end of estimation')
end
grocer_T=grocer_nf-grocer_n0+1
 
if typeof(grocer_hprev) == 'string' then
   grocer_boundsvar=grocer_hprev(:)
end
 
grocer_meth=grocer_rms('meth')
grocer_prests=grocer_rms('prests')
grocer_ny=grocer_rms('nendo')
 
select grocer_meth
 
case 'ms mean' then
   grocer_exo_comp=zeros(grocer_ny*grocer_T,1)
   grocer_exo_idiop=eye(grocer_ny,grocer_ny) .*. ones(grocer_T,1)
 
case 'ms regression' then
   if grocer_nargin <= 2 then
      grocer_exo_comp=grocer_rms('namex_co')
   end
 
   if grocer_nargin <= 3 then
      grocer_exo_idio=grocer_rms('namex_id')
   end
 
 
   [grocer_exo_com2,grocer_name1,grocer_exo_idio2,grocer_name2,grocer_junk,grocer_b]=explouniv(grocer_exo_com,grocer_exo_idio,[],['exo_com';'idio_com'])
 
   n_z=[0 ; grocer_rms('n_z')]
   cums_nz=cumsum(n_z)
   if size(grocer_exo_com2,2) ~= sum(n_z) then
      error('you have not entered as many common exogenous variables as in the original model')
   end
   if sum(n_z) == 0 then
      grocer_exo_comp=zeros(grocer_T*grocer_ny,1)
   else
      grocer_exo_comp=zeros(grocer_T*grocer_ny,sum(n_z))
      for i=1:size(n_z,1)-1
         grocer_exo_comp((i-1)*grocer_T+1:i*grocer_T,cums_nz(i)+1:cums_nz(i+1))=grocer_exo_com2(:,cums_nz(i)+1:cums_nz(i+1))
      end
   end
 
   n_x=[0 ; grocer_rms('n_x')]
   cums_nx=cumsum(n_x)
   if size(grocer_exo_idio2,2) ~= sum(n_x) then
      error('you have not entered as many common exogenous varibales as in the original model')
   end
   grocer_exo_idiop=zeros(grocer_T*grocer_ny,sum(n_x))
   for i=1:size(n_x,1)-1
      grocer_exo_idiop((i-1)*grocer_T+1:i*grocer_T,cums_nx(i)+1:cums_nx(i+1))=grocer_exo_idio2(:,cums_nx(i)+1:cums_nx(i+1))
   end
else
    if grocer_meth ~= 'ms var' then
       error(grocer_meth+' is not an available type for first arg in ms_forecast')
    end
end
 
 // recover useful output from the results tlist
ptrans=grocer_rms('ptrans')
psmoothed=grocer_rms('smoothed probs')
nobs=grocer_rms('nobs')
nendo=grocer_rms('nendo')
nb_states=grocer_rms('nb_states')
beta_co=grocer_rms('beta_co')
if isempty(beta_co) then
   beta_co=0
   zmat=zeros(nobs*nendo,1)
end
beta_id=grocer_rms('beta_id')
xmat=grocer_rms('xmat')
zmat=grocer_rms('zmat')
 
 
// if the user wants only forecasts from an horizon far in the future,
// then define the start of the underlying forecast at date T+1
grocer_startfore=min(1,grocer_n0)
pstates=zeros(grocer_nf-grocer_startfore+2,nb_states)
pstates(1,:)=psmoothed(nobs+grocer_startfore-1,:)
 
for i=grocer_startfore:grocer_nf
// update probas of each states using the probabilities of transition
   pstates(i-grocer_startfore+2,:)=pstates(i-grocer_startfore+1,:)*ptrans'
end
// remove the last observed proba used to feed the forecasted ones
pstates=pstates(grocer_n0-grocer_startfore+2:grocer_nf-grocer_startfore+2,:)
 
if grocer_meth == 'ms var' then
   nlag=grocer_rms('nlag')
   ys=zeros((grocer_nf-grocer_startfore+1)*nendo,nb_states)
   y=zeros((grocer_nf-grocer_startfore+1),nendo)
 
   // recover the last observed values to feed the var
   select grocer_rms('typemod')
 
   case 2 then
   // all coeffs are regime dependent
      yp= xmat($-grocer_startfore+1,(nendo-1)*(nendo*nlag+1)+1:nendo*(nendo*nlag+1))
      for i=grocer_startfore:grocer_nf
         ys=(eye(nendo,nendo) .*. yp)*beta_id
         y(i-grocer_startfore+1,:)=sum(ys .* (ones(nendo,1) .*. pstates(i-grocer_startfore+1,:)),'c')'
         yp=[y(i-grocer_startfore+1,:) yp(1:nendo*(nlag-1)) 1]
      end
 
   case 3 then
 
   // only the const is regime dependent
      yp=zmat($-grocer_startfore+1,(nendo-1)*(nendo*nlag)+1:nendo*(nendo*nlag))
 
      for i=grocer_startfore:grocer_nf
         ys=(eye(nendo,nendo) .*. yp)*(ones(1,nendo) .*. beta_co)+beta_id
         y(i-grocer_startfore+1,:)=sum(ys.* (ones(nendo,1) .*. pstates(i-grocer_startfore+1,:)),'c')'
         yp=[y(i-grocer_startfore+1,:) yp(1:nendo*(nlag-1))]
      end
   end
   // remove the forecasts that do not interest the user
   ys([1:grocer_n0-1]*nendo,:)=[]
   y(1:grocer_n0-1,:)=[]
 
else
   ys=(grocer_exo_comp*beta_co) .*. ones(1,nb_states)+grocer_exo_idiop*beta_id
   ys=matrix(ys,grocer_T,nendo*nb_states)
 
   y_weighted=ys .* (pstates .*. ones(1,nendo))
   y=y_weighted*(ones(nb_states,1) .*. eye(nendo,nendo))
end
 
res=tlist(['results';'meth';'r_ms';'probf';'prev_states';'forecast';'h forecast'],'msf',grocer_rms,pstates,ys,y,grocer_hprev)
 
if grocer_prests then
// transform the matrix of forecasts into ts and store them into
// the results tlist
   for i=1:nendo
      execstr('res(1)($+1)='''+grocer_rms('namey')(i)+'_f''')
      execstr('res($+1)=reshape(y(:,'+string(i)+'),'''+grocer_hprev(1)+''')')
   end
 
else
// transform the matrix of forecasts into vectors and store them into
// the results tlist
  for i=1:nendo
     execstr('res(1)($+1)='''+grocer_rms('namey')(i)+'_f''')
     execstr('res($+1)=y(:,'+string(i)+')')
  end
 
end
 
if grocer_prt then
   prtvarf(res,%io(2))
end
 
endfunction
 
