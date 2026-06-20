function [list_contrib_q_unb,list_contrib_q_bal,list_contmonth,grocer_mainf]=contrib_logm2grq(grocer_namey,varargin)
 
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
// * list_contrib_q_bal = list of the unbalanced yearly
//   contributions
// * list_contrib_q_bal = list of the balanced yearly
//   contributions
// * list_contmonth = list of the quarterly contributions
// * grocer_mainf = the matrix of infinite moving averages
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003-2007
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_trim=%f
grocer_prtmainf=%f
grocer_prtmonth=%f
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
            grocer_prtmonth=%t
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
if grocer_prtmonth then
   write(%io(2),'quarterly growthr rate of and contributions to:','(a)')
   write(%io(2),' ','(a)')
   execstr('prtts(delts(log('+grocer_namey+')),'+joinstr('grocer_contrib',string([1:grocer_nargin]),',')+...
   ',''names=delts(log('+grocer_namey+'));'+joinstr('cont. of ',grocer_listvar,';')+''')')
end
 
grocer_yqs=m2q(grocer_y,-1)
grocer_yq1=m2q(grocer_y,1)
grocer_yq2=m2q(grocer_y,2)
grocer_yq3=m2q(grocer_y,3)
grocer_yqsl=lagts(grocer_yqs)
 
w6=grocer_yq3/grocer_yqsl
w5=w6+grocer_yq3/grocer_yqsl
w4=w5+grocer_yq2/grocer_yqsl
w3=w4*(1-lagts(grocer_yq3)/grocer_yqsl)
w2=w3-w5*lagts(grocer_yq2)/grocer_yqsl
 
for grocer_i=1:grocer_nargin
   grocer_varaux=w2*lagts(m2q(evstr('grocer_contrib'+string(grocer_i)),2))...
      +w3*lagts(m2q(evstr('grocer_contrib'+string(grocer_i)),3))...
      +w4*m2q(evstr('grocer_contrib'+string(grocer_i)),1)...
      +w5*m2q(evstr('grocer_contrib'+string(grocer_i)),2)...
      +w6*m2q(evstr('grocer_contrib'+string(grocer_i)),3);
   execstr('grocer_q_contrib'+string(grocer_i)+'=grocer_varaux')
end
 
if grocer_prtunbal then
   write(%io(2),'part of the quarterly growth rate of '+grocer_namey+' explained by its contribution:','(a)')
   write(%io(2),evstr('('+joinstr('grocer_q_contrib',string([1:grocer_nargin]),'+')+')/growthr(grocer_yqs)'),'(a)')
end
 
execstr('balance_identity(growthr(grocer_yqs),'+joinstr('''grocer_m_contrib',string([1:grocer_nargin]),''',')+''',''prefix=new'')')
 
execstr('list_contrib_q_unb='+'list('+joinstr('grocer_q_contrib',string([1:grocer_nargin]),',')+')')
execstr('list_contrib_q_bal='+'list('+joinstr('new_grocer_q_contrib',string([1:grocer_nargin]),',')+')')
list_contexecstr('month='+'list('+joinstr('grocer_contrib',string([1:grocer_nargin]),',')+')')
 
if grocer_prtcont then
   write(%io(2),'quarterly growth rate of and contributions to:','(a)')
   write(%io(2),' ','(a)')
   execstr('prtts(growthr(grocer_yqs),'+joinstr('grocer_m_contrib',string([1:grocer_nargin]),',')+...
   ',''names=growthr('+grocer_namey+');	'+joinstr('cont. of ',grocer_listvar,';')+''')')
end
 
endfunction
