function [resacf]=acf1(x,m,s)
 
// PURPOSE: find sample autocorrelation coefficients
//---------------------------------------------------
// INPUT:
// * x = a a real (nx1) vector
// * m = a scalar, the # of calculated coefficients
// * s= the size of the confidence band
//---------------------------------------------------
// OUTPUT:
// resacf = a tlist with
//   . resacf('meth')   = 'acf'
//   . resacf('y')      = values of the input variable
//   . resacf('acf')   = autocorrelation coefficients
//   . resacf('acf_l') = low bound of the confidence interval
//   . resacf('acf_u') = upper bound of the confidence interval
//   . resacf('size') = size of the confidence band
// --------------------------------------------------
// Copyright INRIA/ Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
 
[cova,Mean]=corr(x,m+1);
ac=cova/cova(1);
varac=cumsum(2*(ac.^2))/size(x,'*')
 
bandsize=cdfnor("X",0,1,s/2,1-s/2)
ul = bandsize*sqrt(varac)
ll = -bandsize*sqrt(varac)
 
resacf=tlist(['results';'meth';'y';'acf';'acf_l';'acf_u';...
'size'],'acf',x,ac(2:$)',ll(2:$)',ul(2:$)',s)
 
endfunction
 
 
