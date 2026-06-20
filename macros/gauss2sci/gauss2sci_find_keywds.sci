function ind_keywds=gauss2sci_find_keywds(statk,ind_statk,ind_length,keywds,ind_keywds,beforep,afterp,preced)
 
// PURPOSE: in a gauss translation, find the indexes of
// keywords and add them to alreadu found indexes
// ------------------------------------------------------------
// INPUT:
// * statk = a gauss statement component
// * ind_statk = the index of this gauss statement component
// * ind_length = a (1 x N) vector of integers, with 0 in the
//   first place, then the position where the parts of the
//   statement end
// * keywds = keywords to search
// * ind_keywds =  a (2 x N) matrix, the first line indicates
//   the indexes of the keyword in a statememnt, the second
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
 
 
for j=1:size(keywds,'*')
   ind_keywds=gauss2sci_find_keywd(statk,ind_statk,ind_length,keywds(j),ind_keywds,beforep,afterp,preced)
end
 
[junk,ind]=gsort(ind_keywds(1,:),'g','i')
ind_keywds=ind_keywds(:,ind)
 
endfunction
 
