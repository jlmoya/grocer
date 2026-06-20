function list_arg=extract_arg(str,sep,start_par,end_par,charsym)
 
// PURPOSE: extract the list of arguments of a function when
// one knows where the text after the name of the function
// starts and ends
// ------------------------------------------------------------
// INPUT:
// * str = a string, the list of arguments separated by the
//   separator sep (parentheses delimiting the function
//   removed)
// * sep = a string, the separator of arguments (for a function
//   it should be ',')
// * start_par = a string vector, containing the list of
//   opening parentheses (for instance ['(';'['])
// * end_par = a string vector, containing the list of
//   ending parentheses (for instance [')';']'])
// * charsym = a string vector, made of the symbol delineating
//   strings
// -----------------------------------------------------------
// OUTPUT:
// * list_arg = a [n x 1] string vector, ecah element being an
//   argument of the function
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_sep=strindex(str,sep)
for i=1:size(start_par,2)
   ind_start_par=strindex(str,start_par(i))
   if ~isempty(ind_start_par) then
      ind_start_par=[ind_start_par ; 1+0*ind_start_par]
      ind_end_par=strindex(str,end_par(i))
      ind_end_par=[ind_end_par ; -1+0*ind_end_par]
      ind_fuspar=fusion_par(ind_start_par,ind_end_par)
      for j=1:size(ind_start_par,2)
         ind_start=ind_start_par(1,j)
         ind_fuspar=ind_fuspar(:,ind_fuspar(1,:)>ind_start)
         ind_end=find(ind_fuspar(4,:)==0)
         ind_end=ind_fuspar(1,ind_end(1))
         ind_sep((ind_sep > ind_start) & (ind_sep < ind_end))=[]
      end
   end
 
end
 
for i=1:size(charsym,'*')
   ind_charsym=strindex(str,charsym(i))
   if ~isempty(ind_charsym) then
      for j=1:size(ind_charsym,2)/2
         ind_sep(ind_sep > ind_charsym(2*j-1) & ind_sep < ind_charsym(2*j))=[]
      end
   end
end
 
list_arg=emptystr(size(ind_sep,2),1)
ind_sep=[0 ind_sep length(str)+1]
for i=1:size(ind_sep,2)-1
   list_arg(i)=part(str,ind_sep(i)+1:ind_sep(i+1)-1)
end
 
endfunction
