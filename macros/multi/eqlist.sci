function [grocer_namey,grocer_ncoefeqi,grocer_lexo]=eqlist(grocer_eq,grocer_coef)
 
// PURPOSE: recovers from an equation the name of the
// endogenous variable, the indexes of the coefficients (in a
// vector) and the names of the exogenous variables (also in a
// vector)
// ------------------------------------------------------------
// INPUT:
// * grocer_eq = a string of the form :
//   'varendo=coefi*varex1+...+coefj*varexk' with *varexi
//   possibly lacking
// * grocer_coef = a string vector of the form
//   grocer_coef=['coef1';...;'coefn']
// ------------------------------------------------------------
// OUTPUT:
// * grocer_namey = the name of the rhs variable
// * grocer_ncoefeqi = a (nx1) vector of the indexes of coefi,
//   ...,coefj in grocer_coef
// * grocer_lexo = a (nx1) vector of names of the exogenous
//   variables
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_eq=strsubst(grocer_eq,' ','')
// the name of the endogenous variable
grocer_namey=part(grocer_eq,1:strindex(grocer_eq,'=')-1)
grocer_eq=part(grocer_eq,strindex(grocer_eq,'='):...
length(grocer_eq))
grocer_coef=vec2col(grocer_coef)
grocer_ncoef=size(grocer_coef,1)
grocer_ncoefeqi=[]
 
// next the exogenous variables
for grocer_j=1:grocer_ncoef
 
   if strindex(grocer_eq,grocer_coef(grocer_j)) == ...
   length(grocer_eq)-length(grocer_coef(grocer_j))+1 then
// the equation ends with the coeff
      stri=strindex(grocer_eq,grocer_coef(grocer_j))
   else
// the coeff must be followed by +,- or *; else it is a
// variable which begins with the name of a coeff...
      stri=[strindex(grocer_eq,grocer_coef(grocer_j)+'*') ;...
      strindex(grocer_eq,grocer_coef(grocer_j)+'+');...
      strindex(grocer_eq,grocer_coef(grocer_j)+'-')]
   end
 
   if size(stri,1) ~= 0 then
// the coeff is in the equation
      grocer_ncoefeqi=[grocer_ncoefeqi ; grocer_j]
      if part(grocer_eq,stri+length(grocer_coef(grocer_j))) == '*' then
         grocer_eq=strsubst(grocer_eq,'=+'+grocer_coef(grocer_j)+'*','[''')
         grocer_eq=strsubst(grocer_eq,'=-'+grocer_coef(grocer_j)+'*','[''-')
         grocer_eq=strsubst(grocer_eq,'+'+grocer_coef(grocer_j)+'*',''';''')
         grocer_eq=strsubst(grocer_eq,'-'+grocer_coef(grocer_j)+'*',''';''-')
         grocer_eq=strsubst(grocer_eq,'='+grocer_coef(grocer_j)+'*','[''')
      else
         grocer_charpost=part(grocer_eq,stri+length(grocer_coef(grocer_j)))
         if grocer_charpost == '+' | grocer_charpost == '-' then
            grocer_eq=strsubst(grocer_eq,'=+'+grocer_coef(grocer_j)+grocer_charpost,'[''const'+grocer_charpost)
            grocer_eq=strsubst(grocer_eq,'=-'+grocer_coef(grocer_j)+grocer_charpost,'[''-const'+grocer_charpost)
            grocer_eq=strsubst(grocer_eq,'+'+grocer_coef(grocer_j)+grocer_charpost,'''const'';'''+grocer_charpost)
            grocer_eq=strsubst(grocer_eq,'-'+grocer_coef(grocer_j)+grocer_charpost,'''-const'';'''+grocer_charpost)
            grocer_eq=strsubst(grocer_eq,'='+grocer_coef(grocer_j)+grocer_charpost,'[''const'+grocer_charpost)
         else
            grocer_eq=strsubst(grocer_eq,'=+'+grocer_coef(grocer_j),'[''un')
            grocer_eq=strsubst(grocer_eq,'=-'+grocer_coef(grocer_j),'[''-un')
            grocer_eq=strsubst(grocer_eq,'+'+grocer_coef(grocer_j),'''un'';''')
            grocer_eq=strsubst(grocer_eq,'-'+grocer_coef(grocer_j),'''-un'';''')
            grocer_eq=strsubst(grocer_eq,'='+grocer_coef(grocer_j),'[''un')
         end
      end
   end
end
grocer_eq=grocer_eq+''']'
execstr('grocer_lexo='+grocer_eq)
 
endfunction
