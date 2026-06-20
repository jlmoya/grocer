function so=fillwithzero(si,k,d)
  
so=si
select d
  
case 'l' then
  for i=1:size(si,'*')
     so(i)=strcat(string(zeros(k-length(si(i)),1)),'')+si(i)
   end
     
case 'r' then
  so=si+so
  
end

endfunction  
  