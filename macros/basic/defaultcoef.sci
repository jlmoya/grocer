function coef=defaultcoef(defaultname,speccarb,speccara,varargin)
 
// PURPOSE: determines the list of default coefs names in a set
// of equations
// ------------------------------------------------------------
// INPUT:
// * defaultname = a string (default prefix of the
//   coefficients)
// * speccarb = the characters that must be before a
//   coefficient to be sure that defaultname is not part of the
//   name of an other object
// * speccara = the characters that must be after a
//   coefficient to be sure that defaultname is not part of the
//   name of an other object
// * varargin = strings equal to the texts of the equations
// ------------------------------------------------------------
// OUTPUT:
// coef=a (nx1) vector of coefficients names
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
eq=varargin(1)
for i=2:length(varargin)
   eq=eq+','+varargin(i)
end
eq=strsubst(eq,' ','')
 
lengthname=length(defaultname)
 
ncoef=0
// fix an upper limit to the number of coeficients in the
// equation
for i=1:9
   ch='ncoef=ncoef+size(strindex(eq,defaultname+string(i)),2)'
   execstr(ch)
end
 
if ncoef == 0 then
   error('your equations do not contain the char '+defaultname')
end
 
notcoef=%t
while notcoef & ncoef >0 then
   indcoef=strindex(eq,defaultname+string(ncoef))
   if size(indcoef,2) ~= 0 then
      j=1
      while j <= size(indcoef,2) & notcoef then
// retrieve the char before the presumed coefficient
         if indcoef(j) == 1 then
            car1=speccarb(1)
         else
            car1=part(eq,indcoef(j)-1)
         end
// retrieve the char after the presumed coefficient
         if indcoef(j)+length(string(ncoef)) == length(eq) then
            car2=speccara(1)
         else
            car2=part(eq,indcoef(j)+lengthname+length(string(ncoef)))
         end
// see if the char before and after the presumed coefficient
// are in the list of allowed characters
         if or(speccarb==car1) & or(speccara == car2) then
            notcoef=%f
         end
         j=j+1
      end
      if notcoef then
// should go to the previous possible coefficient
         ncoef=ncoef-1
      end
   else
      ncoef=ncoef-1
   end
end
if ncoef == 0 then
   error('your equation(s) do(es) not contain a numbered coefficient '+defaultname')
end
coef=defaultname+string([1:ncoef]')
 
endfunction
 
