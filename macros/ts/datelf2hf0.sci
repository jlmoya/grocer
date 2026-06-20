function datenew=datelf2hf0(dat,divfq,indlow,varargin)
 
// PURPOSE: for a given date, gives the corresponding date at a
// highest frequency and for the subdivision ind of the
// original date
// ------------------------------------------------------------
// INPUT:
// * dat = a string representing a grocer date
// * divfq = the high frequency to low frequency ratio
// * ind = a scalar equal to the high frequency part of the
//   initial date
// ------------------------------------------------------------
// OUTPUT:
// * datenew = the corresponding high frequency date
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2016
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
load(GROCERDIR+'\param\basets.dat')
 
[fq,fqlit]=date2fq(dat,varargin(:))
 
ind=strindex(dat,fqlit)
if isempty(ind) then
   if and(ascii(dat) >= 46) & and(ascii(dat) <= 57) then
      datenew=dat+freq2car(divfq)+string(indlow)
   else
      error('not an available date: '+dat)
   end
 
elseif fq(1) == 1 then
   if divfq >= fq(2) then
      fqnew=[divfq/fq(2) , 1 ]
      ind_fq=find(fqnew(1) == grocer_basefqnum(:,1))
      datenew=part(dat,1:ind-1)+grocer_basefqlit(ind_fq)+string(indlow)
   end
 
elseif fq(2) == 1 then
   year=part(dat,1:ind-1)
   fqnew=fq(1)*divfq
   ind_fq=find(fqnew == grocer_basefqnum(:,1))
   if isempty(ind_fq) then
      datenew=year+'f'+string(fqnew)+'d'+string(indlow)
   else
      datenew=year+grocer_basefqlit(ind_fq)+string(indlow)
   end
 
end
 
endfunction
