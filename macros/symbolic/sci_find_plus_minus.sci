function ind_keywds=sci_find_plus_minus(txt,keywd,preced)
 
// PURPOSE: in a text, find the indexes of the plus or minus
// operator, without retaining the ones correspodingd to
// exponents in numbers
// ------------------------------------------------------------
// INPUT:
// * txt = a gauss statement component
// * keywd = '+' or '-'
// * preced = the precedence of the operator
// ------------------------------------------------------------
// OUTPUT:
// * ind_keywds = the original matrix extended with the
//   keywords found in the statement component
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
ind_keywds=strindex(txt,keywd)
for i=size(ind_keywds,2):-1:1
   ind_keywds_i=ind_keywds(i)
   txt_before=stripblanks(part(txt,1:ind_keywds_i-1))
   txt_before_last=part(txt_before,length(txt_before))
   if or(txt_before_last == ['e' 'd']) then
      txt_before=stripblanks(part(txt_before,1:length(txt_before)-1))
      txt_after=stripblanks(part(txt,ind_keywds_i+1:length(txt)))
      if isnum(part(txt_before,length(txt_before))) & isnum(part(txt_after,1)) then
      // the sign belongs to a numerical exponentation: remove it from the list
         ind_keywds(i)=[]
      end
   end
end
 
ind_keywds=[ind_keywds ; length(keywd)*ind_keywds./ind_keywds ; preced*ind_keywds./ind_keywds]
 
endfunction
 
