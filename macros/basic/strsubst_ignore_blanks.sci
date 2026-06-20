function txt=strsubst_ignore_blanks(txt,obj1,obj2)
 
// PURPOSE: susbititue obj2 to obj1 in string txt, with blanks
// in obj1 being ignored
// ------------------------------------------------------------
// INPUT:
// * txt = a string
// * obj1 = a string to substitue in txt
// * obj2 = the new string
// ------------------------------------------------------------
// OUTPUT:
// * txt = the new txt
// ------------------------------------------------------------
// Copyright: Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
firstchars=strindex(txt,part(obj1,1))
n_firstchars=size(firstchars,2)
 
for i=1:n_firstchars
   found=%t
   ind_i=firstchars(i)
   ind_start=ind_i+1
   j=2
   while j <= length(obj1) & found then
      ind_delstartn=strindex(part(txt,ind_start:length(txt)),part(obj1,j))
      if isempty(ind_delstartn) then
         found=%f
      elseif ~isempty(strsubst(part(txt,ind_start:ind_start+ind_delstartn(1)-2),' ','')) then
         found=%f
      else
         ind_start=ind_start+ind_delstartn(1)
      end
      j=j+1
   end
 
    if found then
      txt=part(txt,1:ind_i-1)+obj2+part(txt,ind_start:length(txt))
      firstchars(i+1:$)=firstchars(i+1:$)-(ind_start-ind_i-length(obj2))+length(obj2)-length(obj1)
   end
end
 
endfunction
 
