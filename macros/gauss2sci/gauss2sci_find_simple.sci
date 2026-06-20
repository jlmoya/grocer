function ind_keywds=gauss2sci_find_simple(statk,ind_statk,ind_length,keywd,ind_keywds,preced)
 
// PURPOSE: in a gauss translation, find the indexes of a
// keyword and add them to already found indexes
// ------------------------------------------------------------
// INPUT:
// * statk = a gauss statement component
// * ind_statk = the index of this gauss statement component
// * ind_length = a (1 x N) vector of integers, with 0 in the
//   first place, then the position where the parts of the
//   statement end
// * keywds = a vector of keywords to search
// * ind_keywds =  a (4 x N) matrix, the first line indicates
//   the indexes of the keyword in a statement, the second
//   one the index of the component where the parenthesis has
//   been found, the third line: the position of the operator
//   end, the fourth line: the precedence of the operator, as
//     indicated in the table of gauss manual (chapter 11-23
//     for gauss 10 version)
// * preced = the precedence of the operator, as indicated
//     in the table of gauss manual
// ------------------------------------------------------------
// OUTPUT:
// * ind_keywds = the original matrix extended with the
//   keywords found in the statement component
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
ind_obj=strindex(statk,keywd)
 
if ~isempty(ind_obj) then
   ind_keywds=[ind_keywds [ind_obj+ind_length(ind_statk); ...
              ind_statk*ones(1,size(ind_obj,2)) ; ...
              ind_obj+ind_length(ind_statk)+length(keywd);...
              preced*ones(1,size(ind_obj,2))]]
end
 
endfunction
 
