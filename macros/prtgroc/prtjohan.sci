function []=prtjohan(res,boots,out)
 
// PURPOSE: prints the results of a Johansen cointegration test
// on the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a johansen regression
// * boots = a string, the kind of p-value that will be used
//   ('fast' -default for fast fouble bootsrap, anyhthing else
//    for the simple bootstrap)
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following function:
// johansen()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
select nargin
case 1 then
   out=%io(2)
   boots='fast'
case 2 then
   out=%io(2)
end
 
lr1=res('lr1')
lr2=res('lr2')
nvar=res('nvar')
 
 
write(out,' ')
write(out,'Johansen estimation results for variables:')
write(out,joinstr(res('namey'),', '))
write(out,' ')
write(out,'exogenous variables restricted to lie in the cointegration space:')
if isempty(res('namexo_lt')) then
  write(out,'none')
else
  write(out,strcat(res('namexo_lt'),', '))
end
write(out,'unrestricted exogenous variables:')
write(out,' ')
if isempty(res('namexo_st')) then
  write(out,'none')
else
  write(out,strcat(res('namexo_st'),', '))
end
write(out,' ')
write(out,'# of lags: '+string(res('nlags')))
 
write(out,' ')
 
mat2prt=['lambda'+string([1:nvar]') string(res('eig')) ]
printmat(mat2prt,out)
 
write(out,' ')
if res('stat_meth') == 'bootstrap' then
   if boots == 'fast' then
      lr1_p=res('p double trace')
      lr2_p=res('p double lmax')
   else
      lr1_p=res('p trace')
      lr2_p=res('p lmax')
   end
 
   mat2prt=['NULL:   ' 'Trace Statistic'  'p-value';...
          ['r = 0 ' 'r <= '+string([1:nvar-1])]' string([lr1 lr1_p]) ]
 
   vaux=find([ lr1_p ; 1 ]> 0.1)
   nrel1=vaux(1)-1
 
   vaux=find([ lr1_p ; 1 ]> 0.05)
   nrel2=vaux(1)-1
 
   vaux=find([ lr1_p ; 1 ]> 0.01)
   nrel3=vaux(1)-1
 
else
 
   cvt=res('cvt')
   mat2prt=['NULL:   ' 'Trace Statistic'  '10% critical value' '5% critical value' '1% critical value';...
          ['r = 0 ' 'r <= '+string([1:nvar-1])]' string([lr1 cvt]) ]
 
   vaux=find(lr1>=cvt(:,1))
   nrel1=0+vaux($)
 
   vaux=find(lr1>=cvt(:,2))
   nrel2=0+vaux($)
 
   vaux=find(lr1>=cvt(:,3))
   nrel3=0+vaux($)
 
end
 
printmat(mat2prt,out)
write(out,' ')
write(out,'conclusions from the trace statistics:')
write(out,'at a 10% level, there are '+string(nrel1)+' cointegration relation(s)')
write(out,'at a 5% level, there are '+string(nrel2)+' cointegration relation(s)')
write(out,'at a 1% level, there are '+string(nrel3)+' cointegration relation(s)')
 
write(out,' ')
 
if res('stat_meth') == 'bootstrap' then
   mat2prt=['NULL:   ' 'Max Eigenvalues Statistic ' 'p-value';...
         'l <= '+string([0:nvar-1]') string([lr2 lr2_p]) ]
 
   vaux=find([0; lr2_p ] < 0.1)
   nrel1=vaux($)-1
 
   vaux=find([0; lr2_p ] < 0.05)
   nrel2=vaux($)-1
 
   vaux=find([0; lr2_p ] < 0.01)
   nrel3=vaux($)-1
 
else
   cvm=res('cvm')
   mat2prt=['NULL:   ' 'Max Eigenvalues Statistic ' '10% critical value' '5% critical value' '1% critical value';...
         'l <= '+string([0:nvar-1]') string([lr2 cvm]) ]
 
   vaux=find(lr2<=cvm(:,1))
   if isempty(vaux) then
       nrel1=nvar
   else
      nrel1=vaux(1)-1
   end
 
   vaux=find(lr2<=cvm(:,2))
   if isempty(vaux) then
       nrel2=nvar
   else
      nrel2=vaux(1)-1
   end
 
   vaux=find(lr2<=cvm(:,3))
   if isempty(vaux) then
      nrel3=nvar
   else
      nrel3=vaux(1)-1
   end
 
end
printmat(mat2prt,out)
 
write(out,' ')
write(out,'conclusions from the maximal eigenvalues statistics:')
write(out,'at a 10% level, there are '+string(nrel1)+' cointegration relation(s)')
write(out,'at a 5% level, there are '+string(nrel2)+' cointegration relation(s)')
write(out,'at a 1% level, there are '+string(nrel3)+' cointegration relation(s)')
 
printsep(out)
 
endfunction
