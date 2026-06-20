function matr=ndigits(mat,digits)
 
// PURPOSE: Rounds a matrix to the desired number of decimals
//      and converts it into string
// ------------------------------------------------------------
// INPUT:
// * mat = (n x k) matrix
// * digits= number of digits to display in each columns
// ------------------------------------------------------------
// OUPUT:
// * matr = a (n x k) Matrix rounded to desired number of decimals
// ------------------------------------------------------------
// Emmanuel Michaux 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[n,k]=size(mat)
matr=mat
if digits>0 then
  md=round(modulo(mat,1/10^(digits-1)).*10^digits).*10^(-digits)
  matr=md+(matr-modulo(matr,1/10^(digits-1)))
  matr=string(matr)
  // add 0 if necessary
  for i=1:n
    for j=1:k
      fp_ij=strindex(matr(i,j),'.')
      fm_ij=length(matr(i,j))
      if length(fp_ij)>0 then
        dec=part(matr(i,j),fp_ij+1:fm_ij)
        z0=strcat(repmat('0',1,digits-length(dec)))
        matr(i,j)=matr(i,j)+z0
      else
        matr(i,j)=matr(i,j)+'.'+strcat(repmat('0',1,digits))
      end
    end
  end
else
  matr=string(round(mat))
end
endfunction
