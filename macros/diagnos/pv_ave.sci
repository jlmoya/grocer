function [p] = pv_ave(tn,k,l) 


if l < 1 then
  tau = l;
else
  tau = 1/mtlb_a(1,sqrt(l));
end;
if k==1 then
  m = 4;
elseif k==2 then
  m = 3;
else
  m = 2;
end;

global GROCERDIR
load(GROCERDIR+'\data\ave_beta.dat')
execstr('bet=beta_'+string(k));

x = bet(:,1:m)*(tn .^(0:m-1)');
x = x .*(x>0)
pp = 1-cdfgam("PQ",x,0.5*bet(:,m+1),0.5*ones(x));

if tau==0.5 then
   p = 1-cdfgam("PQ",tn,0.5*k,0.5*ones(k))

elseif tau<=.01 then
   p = pp(25);

elseif tau>=.49 then
   p=((.5-tau)*pp(1)+(tau-.49)*(1-cdfgam("PQ",tn,0.5*k,0.5*ones(k))))*100;

else
  taua = (.5-tau+.01)*50;
  tau1 = floor(taua);
  p=(tau1+1-taua)*pp(tau1)+(taua-tau1)*pp(tau1+1);

end;

endfunction
