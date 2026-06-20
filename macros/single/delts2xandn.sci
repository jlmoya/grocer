function [x,n,endstr]=delts2xandn(sinp)
 
// PURPOSE: from a string containing 'delts' recovers the name
// of the differentiating variable (x), the differentiation
// order (n) and the index of the end of the corresponding
// string (end_right)
// ------------------------------------------------------------
// INPUT:
// * sinp = a string containing delts
// ------------------------------------------------------------
// OUTPUT:
// * x = a string, the name of the differentiating variable
// * n = a string, either empty (if the order is implcit) or
//   the differentiation order followed by ','
// * end_right = the index of the end of the corresponding
//   string
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_left=[strindex(sinp,'(') length(sinp)+1]
ind_right=strindex(sinp,')')
closing_right=ind_right(find((ind_left(2:$)-ind_right) > 0))
end_right=closing_right(1)
str_delts=part(sinp,1:end_right)
endstr=part(sinp,end_right+1:length(sinp))
 
ind_comma=strindex(str_delts,',')
if isempty(ind_comma) then
   x=part(str_delts,7:length(str_delts)-1)
   n=emptystr()
else
   // remove the left parenthesis relative to delts itself
   ind_left(1)=[]
   cont=%t
   ind_comma_i=0
 
   while cont & (ind_comma_i < size(ind_comma,2))
      ind_comma_i=ind_comma_i+1
      ind_comma_d=ind_comma(ind_comma_i)
      nb_left=size(find(ind_left < ind_comma_d),2)
      nb_right=size(find(ind_right < ind_comma_d),2)
      if nb_left == nb_right then
         cont=%f
         n=part(str_delts,7:ind_comma_d)
         x=part(str_delts,ind_comma_d+1:length(str_delts)-1)
      end
   end
 
   if cont then
   // there are commas, but they do not betray a differentation in delts
      x=part(str_delts,7:length(str_delts)-1)
      n=emptystr()
   end
end
 
endfunction
