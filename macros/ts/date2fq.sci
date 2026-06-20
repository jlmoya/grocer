function [fq,namefq]=date2fq(dat,indw)
 
// PURPOSE: return the frequency of a date
// ------------------------------------------------------------
// INPUT:
// * dat = a date string
// * indw = 'w' if the date is given as a day date but
//   corresponds to a week
// ------------------------------------------------------------
// OUTPUT:
// * fq = an integer (the frequency of the date)
// * namefq = a string (the string characteristic of the date)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin]=argn(0)
load(GROCERDIR+'\param\basets.dat')
load(GROCERDIR+'\param\dailyform.dat')
 
indf=strindex(dat,'f')
indz=strindex(dat,'z')
 
if isempty(dat) then
   fq=[]
   namefq=[]
 
elseif length(indf) ~= 0 then
 
   fq=[evstr(part(dat,indf+1:strindex(dat,'d')-1)) 1]
   namefq='f'
 
elseif length(indz) ~= 0 then
   fq=[1 evstr(part(dat,indz+1:length(dat)))]
   namefq='z'
 
else
 
   found=~isempty(strindex(dat,grocer_dailysep))
   if found then
      if nargin == 2 then
         if indw == 'w' then
            fq=[52 1]
            namefq='w'
         else
            error(string(varargin(1))+': not an available option')
         end
      else
         fq=[365 1]
         namefq='da'
      end
   else
      i=1
 
      while ~found & (i <= size(grocer_basefqnum,1))
         chars=grocer_basefqlit(i)
         ind=strindex(dat,chars(1))
         for j=2:size(chars,'*')
            ind=[ind ; strindex(dat,chars(j)) ]
         end
 
         if ~isempty(ind) then
            found=%t
            fq=grocer_basefqnum(i,:)
            namefq=grocer_basefqlit(i)
         end
         i=i+1
      end
   end
 
   if ~found & and(ascii(dat)>47) & and(ascii(dat)<58) then
      fq=[1 1]
      namefq='a'
   end
end
 
endfunction
