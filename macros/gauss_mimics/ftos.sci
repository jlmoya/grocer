function y=ftos(x,fmat,field,prec)
 
// PURPOSE: mimic gauss function ftos: converts a scalar into
// a string containing the decimal character representation of
// that number
// ------------------------------------------------------------
// INPUT:
// * x =  a numerical vector
// * fmat = string, the format string to control the conversion
// * field = scalar or (2 x 1) vector,, minimum field width
// * prec = scalar, the numbers created will have prec places
//   after the decimal point
// ------------------------------------------------------------
// OUTPUT:
// * y = string containing the decimal character equivalent of
//   x in the format specified
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
 
fmatv=emptystr(5,1)
ind_percent=strindex(fmat,'%')
fmatv(1)=part(fmat,1:ind_percent(1)-1)
 
after_percent=stripblanks(part(fmat,ind_percent(1)+1:length(fmat)))
[justified,fmat_number,after_percent]=percent2fmt(after_percent)
 
fmatv(2)=justify_g(num2fmt(real(x),fmat_number,prec(1)),field(1),justified)
 
if imag(x) ~= 0 then
   if size(ind_percent,2) == 1 then
      if sign(imag(x)) == -1 then
         fmatv(3)=' '
      else
         fmatv(3)=' + '
      end
      fmatv(4)=justify_g(num2fmt(imag(x),fmat_number,prec(1)),field(1),justified)+'i'
 
   else
      ind_percent2=strindex(after_percent,'%')
      fmatv(3)=part(after_percent,1:ind_percent2(1)-1)
      after_percent=stripblanks(part(fmat,ind_percent(2)+1:length(fmat)))
      [justified,fmat_number,after_percent]=percent2fmt(after_percent)
 
      if size(prec,'*') == 2 then
         prec(1)=prec(2)
      end
      if size(field,'*') == 2 then
         field(1)=field(2)
      end
 
      fmatv(4)=justify_g(num2fmt(imag(x),fmat_number,prec(1)),field(1),justified)
 
 
   end
   fmatv(5)=after_percent
 
end
y=strcat(fmatv)
 
endfunction
 
