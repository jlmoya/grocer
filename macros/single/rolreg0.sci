function rreg=rolreg0(y,x,varargin)
 
// PURPOSE: computes rolling/recursive coefficients
//    and forecatst of linear model
//------------------------------------------------------------
// INPUT:
// * y = (n x 1) vector or exogenous variable
// * x = (n x k) vector or endogenous variables
// * varargin = arguments which can be:
//   . 'roll' or 'recu' : if the user want to use
//      a rolling or recursive window ('recu')
//   . 'win=xx' : estimation window
//         if 'roll', the size of the rolling window
//         if 'recu', size of the first estimation window
//         default = nrow(y)/10
//   . 'hstep=xx': number of out-of-sample forecasts
//   . 'ols', 'nwest' or 'white' estimation
//   . 'mul=1': if the user wants to keep forecast from 1 to hstep
//        (otherwise the hstep forecast is conserved)
//	 . 'trunc=xx': size of the truncation window for Newey-West estimation
//	 . 'cst' if the user want a constant in the model
//   . 'signs =[''>0'',...,''<0'']' signs restriction.
//       When they are not satisfied, the variable is omitted during
//      estimation and forcasts. 'signs' must have k elements
//------------------------------------------------------------
// OUTPUT: rreg tlist results which arguments can
//   . rreg('meth')  = 'rolling' / 'recursive'
//   . rreg('beta')  =  rolling/recursive betas
//   . rreg('rsqr')  =  rolling/recursive r-square
//   . rreg('rbar')  =  rolling/recursive r-square
//   . rreg('tstat')  = rolling/recursive tstats
//   . rreg('pvalue') = rolling/recursive pvalue of the betas
//   . rreg('yfor')  =  out-of-sample forecasts
//   . rreg('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//------------------------------------------------------------
 
tstat=%f
simu='recu'
start=[]
emeth='ols'
hstep=0
win=0
mul=0
cst=%f
signs=[]
 
nargin=length(varargin)
for i=nargin:-1:1
  if typeof(varargin(i)) == 'string' then
    argi=strsubst(varargin(i),' ','')
    str3=part(argi,1:3)
    str4=part(argi,1:4)
    str5=part(argi,1:5)
    str6=part(argi,1:6)
    if str3=='win' then
      execstr(varargin(i))
      varargin(i)=null()
    elseif str3=='mul' then
      execstr(varargin(i))
      varargin(i)=null()
    elseif str3=='cte' then
      cst=%t
      varargin(i)=null()
    elseif str4=='meth' then
      execstr(varargin(i))
      varargin(i)=null()
    elseif str4=='recu' | str4=='roll' then
      simu=str4
      varargin(i)=null()
    elseif str6=='const' then
      cst=%t
      varargin(i)=null()
    elseif str5 =='trunc' | str5  == 'hstep' then
      execstr(varargin(i))
      varargin(i)=null()
    elseif str5 =='signs' then
      execstr(varargin(i))
      varargin(i)=null()
    elseif str5 == 'nwest' | str5== 'white' then
      emeth=str5
      varargin(i)=null()
    end
  elseif typeof(varargin(i)) ~= 'constant' &...
                typeof(varargin(i)) ~= 'ts' then
    error('wrong type for entry number '+string(i+2))
  end
end
 
n=size(y,1)
n2=size(x,1)
p=size(x,2)
 
// determines number of forecasts
if (length(win)>1) then
  nfor=win(1)+win(2)-1
  win=win(1)
else
  nfor=n
end
 
if (nfor+hstep~=n2) then
  if (nfor==n2) then
    nfor=nfor-hstep
  else
    error("#r of rows of x doesn''t match with that of y")
  end
end
 
duro=0
if simu=='roll' then
  duro=1
end
 
if (win==0) then
  win=size(y,1)/2
end
 
// type of constant
if cst==%t then
  x=[x,ones(n,1)]
  dcst=1
else
  indcte=search_cte(x)
  if ~isempty(indcte) then
    dcst = 1
  else
    dcst =0
  end
end
 
// signs constraints
selc=0
if max(size(signs)) ~= 0 then
  if max(size(signs))~=(min(size(x))-dcst) then
    error('# of signs restriction is different than # of exogenous variables')
  else
    test =((signs=='<0') | (signs=='>0'))
    stest=1:max(size(signs))
    selc=stest(test)
  end
end
 
 
// define method for estimation
if selc~=0 then // presence of signs restricions
  if emeth == 'nwest' then
    if trunc ~= 0 then
      sregr='res=nwest1(yt,xt(:,sexo),trunc)'
    else
      sregr='res=nwest1(yt,xt(:,sexo))'
    end
  elseif emeth == 'white' then
    sregr='res=hwhite(yt,xt(:,sexo),''noprint'')'
  else
    sregr='res=ols2(yt,xt(:,sexo))'
  end
end
 
if emeth=='nwest' then
  if trunc~=0 then
    sreg='res=nwest1(yt,xt,trunc)'
  else
    sreg='res=nwest1(yt,xt)'
  end
elseif emeth=='white' then
  sreg='res=hwhite(yt,xt,''noprint'')'
else
  sreg='res=ols2(yt,xt)'
end
 
[n,k]=size(y)
if length(win)==[] then
  win=n/2
end
 
duh=0
if (mul~=0) then
  duh=hstep-1
end
 
rbeta=[]
rpval=[]
rtstat=[]
rrsqr=[]
rrbar=[]
r=1
yhat=[]
 
// rolling/recursive estimations
if selc==0 then
  for t=win:nfor
    yt=y(r:t,:)
    xt=x(r:t,:)
    xtf=x(t+hstep-duh:t+hstep,:)
 
    execstr(sreg) // execute regressions
    bet=res('beta')
    pval=res('pvalue')
    tstat=res('tstat')
 
    rbeta=[rbeta;bet']
    rtstat=[rtstat;tstat']
    rpval=[rpval;pval']
 
    if dcst ~= 0 & p ~= 1 then
      rrsqr = [rrsqr,res('rsqr')]
      rrbar = [rrbar,res('rbar')]
    end
 
    yhat0=bet($)+xtf*bet(1:p)
    yhat=[yhat;yhat0']
 
    r=r+duro
  end
else
  for t=win:n
    yt=y(r:t,:)
    xt=x(r:t,:)
    xtf=x(t+hstep-duh:t+hstep,:)
 
    execstr(sreg) // execute regression instructions
 
    bet =res('beta')
    execstr('tbet='+'bets('+string(selc)+')'+signs(selc))
 
    // all signs contraints are satisfied
    if and(tbet == %t) then
      rbeta = [rbeta,res('beta')]
      rtstat = [rtstat, res('tstat')]
      rpval= [rpval,res('pvalue')]
 
    // execute new regression where exogeneous variables
    //  with wrong signs were deleted
    else
      sexo=1:max(size(bet))
      sexo(~tbet)=[]
      if max(size(sexo))==0 then
        error('The model is empty: none of the sign restriction is satisfied')
      end
 
      // execute regression on a subset of exogenous variables
      execstr(sregr)
 
      bet = zeros(max(size(bet)),1)
      tbet = zeros(max(size(bet)),1)
      pbet = zeros(max(size(bet)),1)
 
      bet(sexo) = res('beta')
      tbet(sexo) = res('tstat')
      pbet(sexo) = res('pvalue')
 
      rbeta = [rbeta,bet]
      rtstat = [rtstat,tbet]
      rpval= [rpval,pbet]
 
    end
    if dcst ~= 0 & p ~= 1 then
      rrsqr = [rrsqr,res('rsqr')]
      rrbar = [rrbar,res('rbar')]
    end
    yhat0=bet($)+xtf*bet(1:p)
    yhat=[yhat;yhat0']
 
    r=r+duro
  end
end
rreg=tlist(['results';'meth';'beta';'tstat';'pvalue';'yfor';'prescst'],...
         simu,rbeta,rtstat,rpval,yhat,cst)
endfunction
 
