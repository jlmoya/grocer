function []=prtvarma(results,out)
 
// PURPOSE: prints the results of a ARMA or VARMA estimation on
// the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a Varma regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// varma()
// ------------------------------------------------------------
// Copyright (c) Eric Dubois 2004
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   out=%io(2)
end
 
theta=results('coeff')
labtheta=results('lab')
y=results('y')
[nobs,nvar]=size(y)
fval=results('like')
g=results('grad')
std=results('std')
tstat=results('tstat')
corrm=results('cov')
k=results('nvar')
Y2print = results('namey')
nendo=size(Y2print,1)
 
mod=''
if or(part(labtheta,1:3)=='AR ') then
   mod=mod+'(1+AR(L))*'
end
if or(part(labtheta,1:3) == 'ARS') then
   mod=mod+'(1+ARS(L^'+string(results('seas'))+')) * '
end
mod=mod+'Y = '
if or(part(labtheta,1:3) == 'MA ') then
   mod=mod+'(1+MA(L))*'
end
if or(part(labtheta,1:3) == 'MAS') then
   mod=mod+'(1+MAS(L^'+string(results('seas'))+')) * '
end
mod=mod+'e'
 
if results('nexo') then
   namexos=results('namexos')
   nexos=size(namexos,1)
   if results('lagexo') == 0 then
      mod=mod+'+ G*'
   else
      mod=mod+'+ G(L)*'
   end
   if nexos == 1 then
      mod = mod+ namexos
   else
      mod=mod+'['+joinstr(namexos,' , ')+']'''
   end
end
 
write(out,' ');
if nvar == 1 then
   write(out,'*************** ARMA estimation Results for model: ***************');
else
   write(out,'*************** VARMA estimation Results for model: ***************');
end
write(out,mod)
write(out,'with:')
if nendo > 1 then
   Y2print=[emptystr(nendo,1)+'      [' Y2print emptystr(nendo,1)+' ]' ]
   Y2print(floor(nendo/2)+1,1) = '- Y = ['
   printmat(Y2print,out)
else
   write(out,'- Y = '+Y2print)
end
write(out,'- V(e) = V')
 
write(out,'')
if results('prests') then
   ch='estimation period: '
   boundsvar=results('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
 
write(out,' ');
write(out,'Log-likelihood: '+string(fval));
write(out,'Information criteria: AIC = '+string(results('AIC'))+', BIC = '+string(results('BIC')))
write(out,' ');
if results('exact') then
   mat2print = ['Parameter' 'Estimate'  'Std. Dev.'       't-test' ];
else
   mat2print = ['Parameter' 'Estimate'  'Appr.Std.Dev.'       't-test' ]
end
 
if nvar == 1 then
   mat2print = [mat2print ; labtheta string([theta std tstat])]
else
   deb_lab=part(labtheta(1),1:strindex(labtheta(1),'eq')-4)
   nstars=emptystr()
   for j=1:length(deb_lab)
      nstars=nstars+'*'
   end
   mat2print2=' '+emptystr(3,4)
   mat2print2(2:3,1)=[deb_lab ; nstars]
 
   mat2print = [mat2print ; mat2print2]
 
   nparam=size(theta,1)
   i=1
   enddisp=%f
   while i<=nparam & ~enddisp then
      if or(part(labtheta(i),1:2) == ['MA';'AR']) then
         if part(labtheta(i),1:strindex(labtheta(i),'eq')-4) == deb_lab then
            mat2print = [mat2print ; part(labtheta(i),strindex(labtheta(i),'eq'):length(labtheta(i))) ...
                         string([theta(i) std(i) tstat(i)])]
             i=i+1
         else
            mat2print = [mat2print ; ' ',' ',' ',' ']
            deb_lab = part(labtheta(i),1:strindex(labtheta(i),'eq')-4)
            nstars=emptystr()
            for j=1:length(deb_lab)
              nstars=nstars+'*'
            end
            mat2print2(2:3,1)=[deb_lab ; nstars]
            mat2print = [mat2print ; mat2print2]
         end
      else
         enddisp=%t
      end
   end
   mat2print=[mat2print ; ' ',' ',' ',' '; labtheta(i:nparam) ...
              string([theta(i:nparam) std(i:nparam) tstat(i:nparam)])]
end
 
 
printmat(mat2print,out)
printsep(out)
 
endfunction
