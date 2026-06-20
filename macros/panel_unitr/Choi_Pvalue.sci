function [pvalue] = Choi_Pvalue(Xa,Ta,model)

global GROCERDIR ;
 
load(GROCERDIR+'/data/Choi_pvalues.dat')
select model // Determination of Regression Parameters
 
case 0 then
   per = per_2 // Critical Values for model with constant
 
case 1 then
   per = per_3 // Critical Values for model with constant and trend
 
end;
 
GLS_Critical = per*[1 ; 1/Ta ; 1/Ta^2]
np=size(GLS_Critical,1)
 
[a,b] = min(abs((Xa-GLS_Critical)))// Interpolation
 
select b
 
case 1 then
   pvalue = 0.0001; // Pvalue < 0.0025
 
case np then
   pvalue = 0.9999; // Pvalue > 9.9975
 
else // Pvalue>0 and Pvalue<0
   sXa = sign([GLS_Critical(b-1:b+1)- Xa]);
   proba = [1:np]'/np
 
   if sXa(1)== -1 & sXa(2)==1 then
      posi=(Xa-GLS_Critical(b-1))/(GLS_Critical(b)-GLS_Critical(b-1))
      pvalue=proba(b-1)*(1-posi)+proba(b)*posi
 
   else
      posi=(GLS_Critical(b+1)-Xa)/(GLS_Critical(b+1)-GLS_Critical(b));
      pvalue=proba(b)*(1-posi)+proba(b+1)*posi
 
   end;
end;
 
endfunction
