function printfm(x,mask,fmt)
 
// PURPOSE: mimic Gauss function printfm: Prints a matrix using
// a different format for each column of the matrix
// ------------------------------------------------------------
// INPUT:
// * x = a (N x K) matrix which is to be printed and which may
//   contain both character and numeric data
// * mask = a (L x M) matrix, E x E conformable with x,
//   containing ones and zeros, which is used to specify
//    whetherthe particular row, column, or element is to be
//    printed as a character (0) or numeric (1) value
// * fmt = (K x 3) or (1 × 3) matrix where each row specifies
//   the format for the respective column of x
// ------------------------------------------------------------
// OUTPUT:
// NOTHING: results are printed on screen
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(x) == 'array' then
   [nrows,K]=size(x('value'))
else
   [nrows,K]=size(x)
end
 
fmt_str=fmt('text')
fmt_value=fmt('value')
f=stripblanks(fmt_str(:,1))
L=fmt_value(:,2)
ndec=fmt_value(:,3)
 
justif=emptystr(K,1)
paddle=zeros(K,1)
type_fmt=emptystr(K,1)
post_fmt=emptystr(K,1)
if size(mask,1) == 1 then
   mask=ones(nrows,1) .*. mask
end
 
for j=1:K
   f_j=f(j)
   if part(f_j,1) == '0' then
      paddle(j)=1
      f_j=stripblanks(part(f_j,2:length(f_j)))
   end
   [justif_j,type_fmt_j,post_fmt_j]=percent2fmt(f_j)
   justif(j)=justif_j
   type_fmt(j)=type_fmt_j
   post_fmt(j)=post_fmt_j
end
 
for i=1:nrows
   str=emptystr(1,nrows)
 
   for j=1:K
      x_i_j=x(i,j)
      L_j=L(j)
      ndec_j=ndec(j)
      post_fmt_j=post_fmt(j)
      justif_j=justif(j)
      type_fmt_j=type_fmt(j)
 
      if typeof(x_i_j) == 'constant' then
         if type_fmt(j) == 's' then
            error('invalid format for a number: s')
         end
         if mask(i,j) == 0 then
            if justif(j) == 'r' then
               str(j)=strcat(' '+emptystr(L-1,1))+'?'+post_fmt_j
            else
               str(j)='?'+strcat(' '+emptystr(L-1,1))+post_fmt_j
            end
         else
            str(j)=justify_g(num2fmt(x_i_j,type_fmt_j,ndec_j),1,justif_j)+post_fmt_j
         end
 
      elseif typeof(x_i_j) == 'string' then
         if type_fmt(j) == 's' then
            if mask(i,j) == 1 then
               error('invalid mask 0 for a string')
            end
            str(j)=justify_g(part(x_i_j,1:L_j),1,justif_j)+post_fmt_j
 
         elseif mask(i,j) == 0 then
            left_blanks=int((L_j-ndec_j)/2)
            rightbalnks=L_j-ndec_j-left_blanks
            str(j)=strcat(' '+emptysr(leftblanks,1))+part(x_i_j,1:ndec_j)+strcat(' '+emptysr(rightblanks,1))
 
         elseif mask(i,j) == 1 then
            str(j)=justify_g('+DEN',1,justif_j)
         end
      end
   end
 
   write(%io(2),strcat(str,' '))
 
end
 
endfunction
