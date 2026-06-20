function [v]=gauss2sci_local(v)
 
// PURPOSE: put the definitions of local variables in a gauss
// file between comments
// ------------------------------------------------------------
// INPUT:
// * v = a string vector representing a gauss program
// ------------------------------------------------------------
// OUTPUT:
// * v = the same programm with local variables between
//   comments
// ------------------------------------------------------------
// Copyright: Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
nlines=size(v,1)
i=1
 
while i<nlines
   v(i)=strsubst_trueobj(v(i),'local','/* local',[' ' ';'],[' '],%f)
   indloc=strindex(v(i),'/* local')
   indsemicol=strindex(v(i),';')
   if isempty(indloc) then
      i=i+1
   elseif ~isempty(indsemicol($)>indloc($)) then
      for j=size(indloc,2):-1:1
         k=indloc(j)
         l=find(indsemicol>k)
         v(i)=part(v(i),1:indsemicol(l(1))-1)+'*/'+part(v(i),indsemicol(l(1))+1:length(v(i)))
      end
      i=i+1
   else
      // the last word 'local' is not ended by a semi-column on the same line
      indsemicol=[]
      while i<nlines & isempty(indsemicol) then
         i=i+1
         indsemicol=strindex(v(i),';')
      end
      if isempty(indsemicol) then
         error('instruction ''local'' should end with a '';'' in your gausse file')
      end
      v(i)=part(v(i),1:indsemicol(1)-1)+'*/'+part(v(i),indsemicol(1)+1:length(v(i)))
   end
end
 
endfunction
