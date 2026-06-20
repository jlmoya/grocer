function [ind_equal,ind_doubleq,ind_diff,ind_supeq,ind_infeq]=gauss2sci_find_equal(statk,ind_statk,ind_length,ind_equal,ind_doubleq,ind_diff,ind_supeq,ind_infeq)
 
// PURPOSE: in a gauss translation, find the indexes of true
// '=' and add them to already found indexes
// ------------------------------------------------------------
// INPUT:
// * statk = a gauss statement component
// * ind_statk = the index of this gauss statement component
// * ind_length = a (1 x N) vector of integers, with 0 in the
//   first place, then the position where the parts of the
//   statement end
// * ind_equal = a (4 x N) matrix, gathering the information
//   about the positions of the keyword '='
// * ind_doubleq = a (4 x N) matrix, gathering the information
//   about the positions of the keyword '=='
// * ind_diff = a (4 x N) matrix, gathering the information
//   about the positions of the keyword '~='
// * ind_supeq = a (4 x N) matrix, gathering the information
//   about the positions of the keyword '>='
// * ind_infeq = a (4 x N) matrix, gathering the information
//   about the positions of the keyword '<='
// ------------------------------------------------------------
// OUTPUT:
// * ind_equal = the original matrix extended with the
//   equals found in the statement component
// * ind_doubleq = the original matrix extended with the
//   '==' found in the statement component
// * ind_diff = the original matrix extended with the
//   '~=' found in the statement component
// * ind_supeq = the original matrix extended with the
//   '>=' found in the statement component
// * ind_infeq = the original matrix extended with the
//   '<=' found in the statement component
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_doubleq_i=strindex(statk,'==')
ind_diff_i=strindex(statk,'~=')
ind_supeq_i=strindex(statk,'>=')
ind_infeq_i=strindex(statk,'<=')
ind_equal_i=strindex(statk,'=')
 
for j=size(ind_equal_i,2):-1:1
   ind_equal_i_j=ind_equal_i(j)
   if or([ind_doubleq_i ind_doubleq_i+1 ind_diff_i+1  ...
     ind_supeq_i+1 ind_infeq_i+1] == ind_equal_i_j) then
      ind_equal_i(j)=[]
   end
end
 
if ~isempty(ind_doubleq_i) then
   ind_doubleq=[ind_doubleq [ind_doubleq_i+ind_length(i) ; ...
                i*ones(1,size(ind_doubleq_i,2)) ; ...
                ind_doubleq_i+ind_length(i)+1 ; ...
                55*ones(1,size(ind_doubleq_i,2)) ]]
end
 
if ~isempty(ind_diff_i) then
   ind_diff=[ind_diff [ind_diff_i+ind_length(i) ;...
            i*ones(1,size(ind_diff_i,2)) ; ...
            ind_diff_i+ind_length(i)+1 ; ...
            55*ones(1,size(ind_diff_i,2)) ]]
end
 
if ~isempty(ind_supeq_i) then
   ind_supeq=[ind_supeq [ind_supeq_i+ind_length(i) ; ...
              i*ones(1,size(ind_supeq_i,2)) ; ...
              ind_supeq_i+ind_length(i)+1 ; ...
              55*ones(1,size(ind_supeq_i,2)) ]]
end
 
if ~isempty(ind_infeq_i) then
   ind_infeq=[ind_infeq [ind_infeq_i+ind_length(i) ; ...
            i*ones(1,size(ind_infeq_i,2)) ; ...
            ind_infeq_i+ind_length(i)+1 ; ...
            55*ones(1,size(ind_infeq_i,2)) ]]
end
 
if ~isempty(ind_equal_i) then
   ind_equal=[ind_equal [ind_equal_i+ind_length(i) ; ...
             i*ones(1,size(ind_equal_i,2)) ; ...
             ind_equal_i+ind_length(i)+1 ;
             10*ones(1,size(ind_equal_i,2)) ]]
end
 
endfunction
