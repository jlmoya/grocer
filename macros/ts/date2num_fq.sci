function [num,fq,fqlit]=date2num_fq(dat,varargin)
 
// PURPOSE: return the numerical representation and the
// frequency of a date
// ------------------------------------------------------------
// INPUT:
// * dat = a date string
// * varargin = 'w' if the date is given as a day date but
//   corresponds to a week
// ------------------------------------------------------------
// OUTPUT:
// * num = the numerical representation of the date
// * fq = its (2x1) frequency
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2007
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
load(GROCERDIR+'\param\basets.dat')
 
[fq,fqlit]=date2fq(dat,varargin(:))
 
if fqlit == 'da' then
   fq=[365 ;1]
   load(GROCERDIR+'\param\dailyform.dat')
   ind=strindex(dat,grocer_dailysep)
   execstr('p=['+part(dat,1:ind(1)-1) +';'+ part(dat,ind(1)+1:ind(2)-1) +';'+ part(dat,ind(2)+1:length(dat))+']')
   num=datenum(p(grocer_dailypart(1)),p(grocer_dailypart(2)),p(grocer_dailypart(3)))
 
elseif fqlit =='w' then
   fq=[52 ; 1]
   load(GROCERDIR+'\param\dailyform.dat')
   ind=strindex(dat,grocer_dailysep)
   execstr('p=['+part(dat,1:ind(1)-1) +';'+ part(dat,ind(1)+1:ind(2)-1) +';'+ part(dat,ind(2)+1:length(dat))+']')
   num=int((datenum(p(grocer_dailypart(1)),p(grocer_dailypart(2)),p(grocer_dailypart(3)))-3)/7)
 
 
else
   ind=strindex(dat,fqlit)
   if isempty(ind) then
      if and(ascii(dat) >= 46) & and(ascii(dat) <= 57) then
         execstr('num='+dat)
      else
         error('not an available date: '+dat)
      end
 
   elseif fq(1) == 1 then
      execstr('num='+part(dat,1:ind-1))
 
   elseif fq(2) == 1 then
 
      if fqlit == 'f' then
         execstr('p='+part(dat,strindex(dat,'d')+1:length(dat)))
      else
         execstr('p='+part(dat,ind+1:length(dat)))
      end
 
      if p > fq(1) then
         error('period is greater than frequency')
      else
         execstr('num='+part(dat,1:ind-1)+'*fq(1)+p')
      end
 
   else
      execstr('num='+part(dat,1:ind-1))
 
   end
end
 
endfunction
