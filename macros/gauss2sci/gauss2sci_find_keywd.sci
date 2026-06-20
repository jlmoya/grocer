function ind_keywd=gauss2sci_find_keywd(statk,ind_statk,ind_length,keywd,ind_keywd,beforep,afterp,preced)
 
// PURPOSE: in a gauss translation, find the indexes of a
// keyword and add them to already found indexes
// ------------------------------------------------------------
// INPUT:
// * statk = a gauss statement component
// * ind_statk = the index of this gauss statement component
// * ind_length = a (1 x N) vector of integers, with 0 in the
//   first place, then the position where the parts of the
//   statement end
// * keywds = the keyword to search
// * ind_keywds =  a (2 x N) matrix, the first line indicates
//   the indexes of the keyword in a statement, the second
//   one the index of the component where the parenthesis has
//   been found
// * beforep = a string vector: what character must be found
//   before the keyword
// * afterp = a string vector: what character must be found
//   after the keyword
// * preced = the precedence of the operator, as indicated
//     in the table of gauss manual
// ------------------------------------------------------------
// OUTPUT:
// * ind_keywds = the original matrix extended with the
//   keywords found in the statement component
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[true_obj,ind_obj]=findobject(statk,keywd,beforep,afterp,%f)
if ~isempty(ind_obj) then
   ind_keywd=[ind_keywd [ind_obj+ind_length(ind_statk); ...
              ind_statk*ones(1,size(ind_obj,2)) ; ...
              ind_obj+ind_length(ind_statk)+length(keywd) ; ...
              preced*ones(1,size(ind_obj,2)) ]]
end
 
endfunction
 
