function [coef]=findcoef(str,car)
 
// PURPOSE: in an equation where the coefficients are given
// by default (car1,...,carn) find the last coefficient in this
// equation and infer the names of the coefficients
// ------------------------------------------------------------
// INPUT:
// * str = the equation analyzed
// * car = the default car for the beginning of the
//   coefficients
// ------------------------------------------------------------
// OUTPUT:
// * coef = the names of the coefficients
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
speccar=['+' '(' '-' '*' '/' ')' '^']
ncoef=0
str=strsubst(str,' ','')
 
// find a maximum for the index of the last coefficient
for i=1:9
   ch='ncoef=ncoef+size(strindex(str,''''+car+string(i)+''''),2)'
   execstr(ch)
end
 
// starting from the maximum, find the last coefficient really
// present
emptycoef=%t
while emptycoef then
   ist=strindex(str,evstr(''''+car+string(ncoef)+''''))
   if size(ist,1) == 0 then
// coeff not found, go to the previous one
      ncoef=ncoef-1
   else
      for j=1:size(ist,1)
         if ist(j) == 1 then
            car1 = '('
         else
            car1 = part(str,ist(j)-1)
         end
         if ist(j)+length(car+string(ncoef)) == length(str)+1 then
            car2 ='('
         else
            car2 = part(str,ist(j)+length(car+string(ncoef)))
         end
         if or(speccar == car1) & or(speccar == car2) then
// the name of the coef must be preceded (if not at the start of the
// string (case ist(j) = 1)) and followed (if not at the end of the
// string (ist(j)+length(car+string(ncoef)) == length(str)+1)by one
// of the car precised in spceccar
            emptycoef=%f
         end
         ncoef=ncoef-1
      end
   end
end
coef=car+string([1:ncoef+1]')
 
endfunction
 
