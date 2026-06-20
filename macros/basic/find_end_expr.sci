function [strout,ind_strout]=find_end_expr(str,ind_leftpar)
 
// PURPOSE: finds the end of an expression starting with a left
// parenthesis
// ------------------------------------------------------------
// INPUT:
// * str = a string
// * ind_leftpar = a (1 x n) vector of indexes of the left
//   parenthesis
// ------------------------------------------------------------
// OUTPUT:
// * strout = the expression
// * ind_strout =  a (2 x 1) vector: the starting and ending
//   indexes of the expression
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
ind_leftpar=[ind_leftpar length(str)+1]
ind_rightpar=strindex(str,')')
closing_right=ind_rightpar(find((ind_leftpar(2:$)-ind_rightpar) > 0))
end_right=closing_right(1)
strout=part(str,ind_leftpar(1)+1:end_right-1)
ind_strout=[ind_leftpar(1)+1 ; end_right-1]
 
endfunction
 
