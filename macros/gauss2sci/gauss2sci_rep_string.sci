function [statement,type_statement]=gauss2sci_rep_string(statement,type_statement,elem,op,ind_length)
 
// PURPOSE: transform Gauss statistical functions into their
// Scilab counterpart
// ------------------------------------------------------------
// INPUT:
// * txt = a string
// ------------------------------------------------------------
// OUTPUT:
// * txt= the transformed string
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
before_f=[' ' ; ';' ; '=' ; '+' ; '-' ; '*' ; '/' ; '~' ; '|' ; ...
'('; '[';'^';'>';'<';'^']
after_f=[' ' ; '(' ;'[' ]
 
statk=statement(elem)
 
statk=strsubst_trueobj(statk,'vals','ascii',[' ';';';'+';'-';'/';'='],[' ';'('],%t,%t)
statk=strsubst_trueobj(statk,'strtof','evstr',[' ';';';'+';'-';'/';'='],[' ';'('],%t,%t)
 
// replace functions
[true_cvtos,ind_cvtos_def,statk]=findobject(convstr(statk),'cvtos',before_f,after_f,%f)
for i=size(ind_cvtos_def,1):-1:1
 
   ind_cvtos_i=ind_cvtos_def(i)
   ind_fuspar=op('fuspar')
   ind_fuspar_sup=ind_fuspar(:,ind_fuspar(1,:)>ind_cvtos_i+ind_length(elem))
   ind_fuspar_eq1=ind_fuspar_sup(:,ind_fuspar_sup(4,:)==(ind_fuspar_sup(4,1)-1))
   indstat_end=ind_fuspar_eq1(2,1)
   stat1=part(statement(indstat_end),1:ind_fuspar_eq1(1,1)-1-ind_length(indstat_end))
   stat2=part(statement(indstat_end),[ind_fuspar_eq1(1,1):ind_length(indstat_end+1)]-ind_length(indstat_end))
   statement=[statement(1:indstat_end-1) stat1+',' '""""' stat2 statement(indstat_end+1:$)]
   type_statement=[type_statement(1:indstat_end) 'string' 'nostring' type_statement(indstat_end+1:$)]
 
end
 
[true_lower,ind_lower_def,statk]=findobject(convstr(statk),'lower',before_f,after_f,%f)
for i=size(ind_lower_def,1):-1:1
 
   ind_lower_i=ind_lower_def(i)
   ind_fuspar=op('fuspar')
   ind_fuspar_sup=ind_fuspar(:,ind_fuspar(1,:)>ind_lower_i+ind_length(elem))
   ind_fuspar_eq1=ind_fuspar_sup(:,ind_fuspar_sup(4,:)==(ind_fuspar_sup(4,1)-1))
   indstat_end=ind_fuspar_eq1(2,1)
   statement(indstat_end)=part(statement(indstat_end),1:ind_fuspar_eq1(1,1)-1-ind_length(indstat_end))+...
                          ')'+part(statement(indstat_end),[ind_fuspar_eq1(1,1):ind_length(indstat_end+1)]-ind_length(indstat_end))
   ind_start=ind_fuspar(:,1)
   statement(ind_start(2))=part(statement(ind_start(2)),1:ind_lower_i-1-ind_length(ind_start(2)))+...
                         'convstr(string('+part(statement(ind_start(2)),...
                         [ind_start(1)+1-ind_length(ind_start(2)):ind_length(ind_start(2)+1)-ind_length(ind_start(2))])
 
end
 
[true_upper,ind_upper_def,statk]=findobject(convstr(statk),'upper',before_f,after_f,%f)
for i=size(ind_upper_def,1):-1:1
 
   ind_upper_i=ind_upper_def(i)
   ind_fuspar=op('fuspar')
   ind_fuspar_sup=ind_fuspar(:,ind_fuspar(1,:)>ind_upper_i+ind_length(elem))
   ind_fuspar_eq1=ind_fuspar_sup(:,ind_fuspar_sup(4,:)==(ind_fuspar_sup(4,1)-1))
   indstat_end=ind_fuspar_eq1(2,1)
   stat1=part(statement(indstat_end),1:ind_fuspar_eq1(1,1)-1-ind_length(indstat_end))
   stat2=part(statement(indstat_end),[ind_fuspar_eq1(1,1):ind_length(indstat_end+1)]-ind_length(indstat_end))
   statement=[statement(1:indstat_end-1) stat1+'),' '""u""' stat2 statement(indstat_end+1:$)]
   ind_start=ind_fuspar(:,1)
   statement(ind_start(2))=part(statement(ind_start(2)),1:ind_upper_i-1-ind_length(ind_start(2)))+...
                         'convstr(string('+part(statement(ind_start(2)),...
                         [ind_start(1)+1-ind_length(ind_start(2)):ind_length(ind_start(2)+1)-ind_length(ind_start(2))])
   type_statement=[type_statement(1:indstat_end) 'string' 'nostring' type_statement(indstat_end+1:$)]
 
end
 
 
endfunction
 
