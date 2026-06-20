function txt=gauss2sci_rep_keyw(txt)
 
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
 
 
// transforms the '.' meaning a whole dimension in an array into ':'
// transforms '[' and ']' in any array
txt=strsubst_ignore_blanks(txt,'(.,','(:,')
txt=strsubst_ignore_blanks(txt,',.)',',:)')
txt=strsubst_ignore_blanks(txt,',.,',',:,)')
 
 
endfunction
 
