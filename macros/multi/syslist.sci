function [grocer_lx,grocer_listcoef,grocer_ncoefeqs,grocer_xx,grocer_namexos,grocer_boundsvarb]=syslist(grocer_l,coef,grocer_boundsvarb)
 
// PURPOSE: explode a list of equations into the lists of
// variables, coefficients, their index in each equation,
// value of endogenous variables, name of exogenous
// variables and, if necessary, updates the bounds
// ------------------------------------------------------------
// INPUT:
// * grocer_l = a list of k equations
// * coef = a (mx1) vector of coefficients names
// * grocer_boundsvarb = a vector of bounds or []
// ------------------------------------------------------------
// OUTPUT:
// * grocer_lx = the list of all endogenous variables
// * grocer_listcoef = the list of coefficients
// * grocer_ncoefeqs = the list pf sizes of coefficients for
//   each equation
// * grocer_xx = matrix of exogenous varaibles
// * grocer_namexos = the vector of their names
// * grocer_boundsvarb = the vector of bounds
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2021
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_neqs=length(grocer_l)
// create a list with the endogenous and exogenous variables
// and the list of coefficients for each equation
 
// first the endogneous variables
grocer_chx='grocer_lx=list('
for grocer_i=1:grocer_neqs
   grocer_l(grocer_i)=strsubst(grocer_l(grocer_i),' ','')
   grocer_chx=grocer_chx+part(grocer_l(grocer_i),1:strindex(grocer_l(grocer_i),'=')-1)+','
end
grocer_chx=part(grocer_chx,1:length(grocer_chx)-1)
grocer_listcoef=list()
grocer_ncoefeqs=zeros(grocer_neqs,1)
 
// next the exogenous variables
for grocer_i=1:grocer_neqs
   grocer_ch='grocer_ncoef'+string(grocer_i)+'=[]'
   execstr(grocer_ch)
   grocer_l(grocer_i)=part(grocer_l(grocer_i),strindex(grocer_l(grocer_i),'='):...
                   length(grocer_l(grocer_i)))
   for grocer_j=1:grocer_ncoef
      if strindex(grocer_l(grocer_i),coef(grocer_j)) == ...
      length(grocer_l(grocer_i))-length(coef(grocer_j))+1 then
         stri=strindex(grocer_l(grocer_i),coef(grocer_j))
      else
         stri=strindex(grocer_l(grocer_i),coef(grocer_j)+'*')+...
           strindex(grocer_l(grocer_i),coef(grocer_j)+'+')+...
           strindex(grocer_l(grocer_i),coef(grocer_j)+'-')
      end
      if size(stri,1) ~= 0 then
         grocer_ch='grocer_ncoef'+string(grocer_i)+'=[grocer_ncoef'+string(grocer_i)+';'+string(grocer_j)+']'
         execstr(grocer_ch)
         if part(grocer_l(grocer_i),stri+length(coef(grocer_j))) == '*' then
            grocer_l(grocer_i)=strsubst(grocer_l(grocer_i),'=+'+coef(grocer_j)+'*',',')
            grocer_l(grocer_i)=strsubst(grocer_l(grocer_i),'=-'+coef(grocer_j)+'*',',')
            grocer_l(grocer_i)=strsubst(grocer_l(grocer_i),'+'+coef(grocer_j)+'*',',')
            grocer_l(grocer_i)=strsubst(grocer_l(grocer_i),'-'+coef(grocer_j)+'*',',')
            grocer_l(grocer_i)=strsubst(grocer_l(grocer_i),'='+coef(grocer_j)+'*',',')
         else
            grocer_l(grocer_i)=strsubst(grocer_l(grocer_i),'+'+coef(grocer_j),',un')
            grocer_l(grocer_i)=strsubst(grocer_l(grocer_i),'-'+coef(grocer_j),',-un')
         end
      end
   end
   grocer_chx=grocer_chx+grocer_l(grocer_i)
   execstr('grocer_listcoef($+1)='+'grocer_ncoef'+string(grocer_i))
   grocer_ncoefeqs(grocer_i)=size(grocer_listcoef($),1)
end
grocer_chx=grocer_chx+')'
execstr(grocer_chx)
 
[grocer_xx,grocer_namexos,grocer_prests,grocer_boundsvarb]=explone(grocer_lx,'exogenous',grocer_boundsvarb)
endfunction
