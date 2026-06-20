function str=ftocv(x,field,prec)
 
// PURPOSE: mimics gauss function ftocv: Converts a matrix
// containing floating point numbers into a matrix containing
// the decimal character representation of each element
// ------------------------------------------------------------
// INPUT:
// * x =  a numerical vector
// * field = scalar, minimum field width
// * prec = scalar, the numbers created will have prec places after the
//   decimal point
// ------------------------------------------------------------
// OUTPUT:
// * str = (N x K) matrix containing the decimal character
//   equivalent of the corresponding elements in x in the
//   format defined by field and prec
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
// very likely not efficient...
 
str=string(x)
for j=1:size(x,'*')
   str_j=str(j)
   ind_point=strindex(str_j,'.')
   if ~isempty(ind_point) then
      if prec == 0 then
         str_j=part(str_j,1:ind_point-1)
      else
         str_j=part(str_j,1:ind_point+prec)
      end
   end
   nzeros=field-length(str_j)
   if nzeros > 0 then
      str(j)=strcat(emptystr(nzeros,1)+'0','')+str_j
   end
end
 
endfunction
 
