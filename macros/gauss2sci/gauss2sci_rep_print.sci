function statement=gauss2sci_rep_print(statement,ind_length)
 
// PURPOSE: transform Gauss keywords or functions into their
// Scilab or Grocer equiavlent
// ------------------------------------------------------------
// INPUT:
// * txt = a string
// ------------------------------------------------------------
// OUTPUT:
// * txt= the transformed string
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
before_f=[' ']
after_f=[' ' ; '""'  ]
 
[true_print,ind_print_def,statk]=findobject(convstr(statement(1)),'print',before_f,after_f,%f)
if true_print then
   statement(1)=part(statement(1),1:ind_print_def(1)+4)+'('+part(statement(1),ind_print_def(1)+4:ind_length(2))
   statement($)=statement($)+')'
end
 
endfunction
 
