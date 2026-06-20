function [statk,op,ind_length]=gauss2sci_rep_statistics(statk)
 
// PURPOSE: transform Gauss statistical functions into their
// Scilab counterpart
// ------------------------------------------------------------
// INPUT:
// * txt = a string
// ------------------------------------------------------------
// OUTPUT:
// * txt= the transformed string
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
// replace functions
 
[statk,op,ind_length]=gauss2sci_strsub_trueobj(statk,'moment','moment_gauss',...
[' ';';';'+';'-';'*';'/';'=';'('],[' ';'('],%t,op,ind_nonempty,ind_length,elem)
 
endfunction
 
