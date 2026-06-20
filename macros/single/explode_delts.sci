function [sout]=explode_delts(sinp)
 
// PURPOSE: replace 'delts(x)' or 'delts(n,x)' with 'x-lagts(x)'
//  or 'x-lagts(n,x))'
// ------------------------------------------------------------
// INPUT:
// * sinp = a string containing 'delts'
// ------------------------------------------------------------
// OUTPUT:
// * sout = the original string where delts is replaced by the
//   its equivalent with lagts
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
ind_delts=strindex(sinp,'delts(')
ind_left=[strindex(sinp,'(') length(s)+1]
ind_right=strindex(sinp,')')
sout=emptystr()
ind_dealt=0
for i=1:size(ind_delts,2)
   // deal the i-th delts found
   ind_delts_i=ind_delts(i)
   // add the part between the last delts and this one
   sout=sout+part(s,ind_dealt+1:ind_delts_i-1)
   // find the left and right parentheses after delts
   ind_leftb=ind_left
   ind_leftb=ind_left(ind_left > ind_delts_i)
   ind_rightb=ind_right
   // a closing right parenthesis at place k has an index lower the
   // the index of the left k+1 parenthesis
   ind_rightb=ind_right(ind_right > ind_delts_i)
   end_right=find((ind_leftb(2:$)-ind_rightb) > 0)
   ind_dealt=ind_rightb(end_right(1))
   str_delts=part(sinp,ind_delts_i:ind_dealt)
   // now replace delts with x-lagts(x); the difficulty stems from
   // the differing calls to delts: delts(x) or delts(n,x)
   // hence the trick: if ther is a n then it is followed by a comma
   // and this must be a regular expression (same # of left and right
   // parentheses)
   ind_comma=strindex(str_delts,',')
   if isempty(ind_comma) then
      x=part(str_delts,7:length(str_delts)-1)
      sout=sout+'(x'+'-lagts('+x+'))'
   else
      ind_leftb=strindex(str_delts,'(')
      // remove the left parentesis relative to delts itself
      ind_leftb(1)=[]
      ind_rightb=strindex(str_delts,')')
      cont=%T
      ind_comma_i=0
 
      while cont & (ind_comma_i < size(ind_comma,2))
         ind_comma_i=ind_comma_i+1
         ind_comma_d=ind_comma(ind_comma_i)
         nb_left=size(find(ind_leftb < ind_comma_d),2)
         nb_right=size(find(ind_rightb < ind_comma_d),2)
         if nb_left == nb_right then
            cont=%f
            n=part(str_delts,7:ind_comma_d)
            x=part(str_delts,ind_comma_d+1:length(str_delts)-1)
            sout=sout+'('+x+'-lagts('+n+x+'))'
         end
      end
 
      if  cont then
      // there are commas, but they do not betray a differentation in delts
         x=part(str_delts,7:length(str_delts)-1)
         sout=sout+'(x'+'-lagts('+x+'))'
      end
   end
 
end
 
endfunction
