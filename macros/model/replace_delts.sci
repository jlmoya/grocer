function expression=replace_delts(expression)
    
    
ind_delts=find_delts(expression,'delts')    
for j=size(ind_delts,2):-1:1
   endeq=part(expression,ind_delts(j)+5:length(expression))
   comma=[strindex(endeq,',') length(endeq)] // I add length(endeq) to avoid comma to be empty
   [leftpar,rightpar,fuspar]=sci_find_parenth_mod(endeq)
      
   strlag=stripblanks(part(endeq,leftpar(1)+1:comma(1)-1))
   closingpar=find(fuspar(4,:) == 0)
   endexpr=fuspar(1,closingpar(1))

   if ~isnum(strlag) then
      strlag='1,'
      expr=part(endeq,2:endexpr-1)
   else
      strlag=strlag+','
      expr=part(endeq,comma(1)+1:endexpr-1)
   end

   start_exp=stripblanks(part(expression,1:ind_delts(j)-1))

   if isempty(start_exp) then
      expression=expr+'-'+'lagts('+strlag+expr+...
              ')'+part(endeq,endexpr+1:length(endeq))
   elseif or(part(start_exp,length(start_exp)) == ['+' ; '(' ])
      expression=start_exp+expr+'-'+'lagts('+strlag+expr+...
              ')'+part(endeq,endexpr+1:length(endeq))
   else
      expression=start_exp+'('+expr+'-'+'lagts('+strlag+expr+...
              '))'+part(endeq,endexpr+1:length(endeq))
   end

end

endfunction
