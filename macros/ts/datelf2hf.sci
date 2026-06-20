function datnew=datelf2hf(dat,divfq,ind)
 
// PURPOSE: For a given date, give the corresponding date at
// a higher frequency, with the corresponding subdivision given
// by ind. The same purpose as datelf2hf0 but with some tests
// on the input
// ------------------------------------------------------------
// INPUT:
// * dat = a string representing a grocer date
// * fq = the destination frequency
// * ind = a scalar indicating
// ------------------------------------------------------------
// OUTPUT:
// * datenew = the corresponding high frequency date
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   ind=1
elseif ind <= 0 then
   ind = 1
else
   [fq0,fqname0]=date2fq(dat)
   if ind > divfq then
      error('3rd argument should be lower or equal to the 2nd one')
   end
end
 
datnew=datelf2hf0(dat,divfq,ind)
 
endfunction
