function [list_contrib_a_unb,list_contrib_a_bal,list_conttrim,grocer_mainf]=contrib_logq2gra(grocer_namey,varargin)
 
// PURPOSE: Calculates contributions of exogenous variables to
// the annual growth rate of an endogenous variable when the
// econometric equation is estimated on the logarithm of the
// quarterly observations of the variable
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a string represnting the name of a ts
// * varargin = arguments that can be:
//   - a ts
//   - a matrix
//   - a string representing the name of a ts or a vector
//   - a list of such objects
//   - the string 'prefix=xxxx' where xxxx is the prefix added
//   to the name of the variables to produce the new variables
//   (optional: if not given, the names are given by the user
//   through the output)
// ------------------------------------------------------------
// OUTPUT:
// * list_contrib_a_bal = list of the unbalanced yearly
//   contributions
// * list_contrib_a_bal = list of the balanced yearly
//   contributions
// * list_conttrim = list of the quarterly contributions
// * grocer_mainf = the matrix of infinite moving averages
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003-2007
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_trim=%f
grocer_prtmainf=%f
grocer_prttrim=%f
grocer_prtunbal=%f
grocer_prtcont=%f
grocer_prtall=%f
grocer_listnames=list()
grocer_listvar=[]
grocer_listts=list()
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      varargin(grocer_i)=stripblanks(varargin(grocer_i))
      if part(varargin(grocer_i),1:4) == 'prt=' then
         grocer_prt='grocer_prt'+str2vec(varargin(grocer_i))
         for grocer_j=1:size(grocer_prt,1)
            execstr(grocer_prt(grocer_j)+'=%t')
         end
         if grocer_prtall then
            grocer_prttrim=%t
            grocer_prtmainf=%t
            grocer_prtunbal=%t
            grocer_prtcont=%t
         end
      end
      varargin(grocer_i)=null()
   elseif typeof(varargin(grocer_i)) ~= 'list' then
      error(typeof(varargin(grocer_i))+' is not admissible in contrib_logq2gra')
   end
end
 
grocer_nargin=length(varargin)
for grocer_i=1:grocer_nargin
   grocer_listnames($+1)=varargin(grocer_i)
   grocer_listvar=[grocer_listvar varargin(grocer_i)(1)]
   execstr('grocer_listts($+1)='+grocer_listvar($))
end
execstr('grocer_y='+grocer_namey)
 
nobsn=[]
for grocer_i=1:grocer_nargin
   nobsn=[nobsn ; size(series(grocer_listts(grocer_i)),1)]
end
nobs=max(nobsn)
 
grocer_mainf=[]
for grocer_i=1:grocer_nargin
   varaux_mainf=mainf(grocer_listnames(grocer_i)(2),...
      grocer_listnames(grocer_i)(3),nobs)
   execstr('grocer_contrib'+string(grocer_i)+'=contrib(delts('+...
      grocer_listvar(grocer_i)+'),varaux_mainf)')
   grocer_mainf=[grocer_mainf varaux_mainf]
end
 
if grocer_prtmainf then
   write(%io(2),'Impulse response functions of endogenous variable '+grocer_namey+' to:','(a)')
   write(%io(2),' ','(a)')
   mat2prt=[grocer_listvar ; string(grocer_mainf)]
   printmat(mat2prt,%io(2))
   write(%io(2),' ','(a)')
end
if grocer_prttrim then
   write(%io(2),'quarterly growthr rate of and contributions to:','(a)')
   write(%io(2),' ','(a)')
   execstr('prtts(delts(log('+grocer_namey+')),'+joinstr('grocer_contrib',string([1:grocer_nargin]),',')+...
   ',''names=delts(log('+grocer_namey+'));'+joinstr('cont. of ',grocer_listvar,';')+''')')
end
grocer_yas=q2a(grocer_y,-1)
grocer_ya1=q2a(grocer_y,1)
grocer_ya2=q2a(grocer_y,2)
grocer_ya3=q2a(grocer_y,3)
grocer_ya4=q2a(grocer_y,4)
grocer_yasl=lagts(grocer_yas)
 
w8=grocer_ya4/grocer_yasl
w7=w8+grocer_ya3/grocer_yasl
w6=w7+grocer_ya2/grocer_yasl
w5=w6+grocer_ya1/grocer_yasl
w4=w5*(1-lagts(grocer_ya4)/grocer_yasl)
w3=w4-w5*lagts(grocer_ya3)/grocer_yasl
w2=w3-w5*lagts(grocer_ya2)/grocer_yasl
 
for grocer_i=1:grocer_nargin
   grocer_varaux=w2*lagts(q2a(evstr('grocer_contrib'+string(grocer_i)),2))...
      +w3*lagts(q2a(evstr('grocer_contrib'+string(grocer_i)),3))...
      +w4*lagts(q2a(evstr('grocer_contrib'+string(grocer_i)),4))...
      +w5*q2a(evstr('grocer_contrib'+string(grocer_i)),1)...
      +w6*q2a(evstr('grocer_contrib'+string(grocer_i)),2)...
      +w7*q2a(evstr('grocer_contrib'+string(grocer_i)),3)...
      +w8*q2a(evstr('grocer_contrib'+string(grocer_i)),4);
   execstr('grocer_a_contrib'+string(grocer_i)+'=grocer_varaux')
end
 
if grocer_prtunbal then
   write(%io(2),'part of the annual growth rate of '+grocer_namey+' explained by its contribution:','(a)')
   disp(evstr('('+joinstr('grocer_a_contrib',string([1:grocer_nargin]),'+')+')/growthr(grocer_yas)'))
end
 
execstr('balance_identity(growthr(grocer_yas),'+joinstr('''grocer_a_contrib',string([1:grocer_nargin]),''',')+''',''prefix=new'')')
 
execstr('list_contrib_a_unb='+'list('+joinstr('grocer_a_contrib',string([1:grocer_nargin]),',')+')')
execstr('list_contrib_a_bal='+'list('+joinstr('new_grocer_a_contrib',string([1:grocer_nargin]),',')+')')
execstr('list_conttrim='+'list('+joinstr('grocer_contrib',string([1:grocer_nargin]),',')+')')
 
if grocer_prtcont then
   write(%io(2),'annual growth rate of and contributions to:','(a)')
   write(%io(2),' ','(a)')
   execstr('prtts(growthr(grocer_yas),'+joinstr('grocer_a_contrib',string([1:grocer_nargin]),',')+...
   ',''names=growthr('+grocer_namey+');	'+joinstr('cont. of ',grocer_listvar,';')+''')')
end
endfunction
