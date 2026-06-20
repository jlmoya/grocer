function end_sim=deal_endnamey(endnamey,end_sim)
 
// PURPOSE: from a string starting with '+', '-', '*', '/' or
// '/', transfrom it from a lhs to a rhs
// ------------------------------------------------------------
// INPUT:
// * endnamey = a string starting with '+', '-', '*', '/' or
//   '/'
// * end_sim = a string: the rhs to which add the transformed
//   string
// ------------------------------------------------------------
// OUTPUT:
// * end_sim = a string: the transformed rhs
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
start_sim=''
end_simnew=''
while ~isempty(endnamey)
   select part(endnamey,1)
 
   case '+' then
      end_simnew='-('+part(endnamey,2:length(endnamey))+')'+end_simnew
      endnamey=emptystr()
 
   case '-' then
      end_simnew='-('+part(endnamey,1:length(endnamey))+')'+end_simnew
      endnamey=emptystr()
 
   case '/' then
      start_sim=start_sim+'('
      [firstpart,endnamey]=cut_express(part(endnamey,2:length(endnamey)))
      end_simnew=end_simnew+')*'+firstpart
 
   case '*' then
      start_sim=start_sim+'('
      [firstpart,endnamey]=cut_express(part(endnamey,2:length(endnamey)))
      end_simnew=end_simnew+')/'+firstpart
 
   case '^' then
      [firstpart,endnamey]=cut_express(part(endnamey,2:length(endnamey)))
      end_sim=end_sim+')^(1/('+firstpart+')'
   end
end
end_sim=start_sim+end_sim+end_simnew
 
endfunction
