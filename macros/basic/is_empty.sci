function answ=is_empty(m)
 
// Copyright INRIA . 1998  1
// Eric dubois 2006 for the tlist adaptation
select typeof(m)
 
case 'string'
   answ =  max(length(m)) == 0;

case 'ts' 
   answ=size(m('series'),'*')==0
 
case 'tsmat' 
   answ=size(m('series'),'*')==0
  
case 'list' 
   answ = %t;
   for i=1:size(m),
      answ=(answ & is_empty(m(i)));
   end;
 
case 'void' 
   answ = %t;
    
else

   answ = (size(m,'*')==0)
end;
 
endfunction
