function statk=gauss2sci_stringfunc(statk)
 
// PURPOSE: in a gauss translation, deal with the function
// working on strings
// ------------------------------------------------------------
// INPUT:
// * statk = a gauss statement
// ------------------------------------------------------------
// OUTPUT:
// * statk = the transformed gauss statement
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
before_f=[' ' ; ';' ; '=' ; '+' ; '-' ; '*' ; '/' ; '~' ; '|' ; ...
'('; '[';'^';'>';'<';'^']
after_f=[' ' ; '(' ;'[' ]
 
//statk=keep_arg(statk,'intrsct',1:2,before_f,after_f)
 
statk=strsubst_trueobj(statk,'strlen','length',before_f,after_f,%t)
statk=strsubst_trueobj(statk,'vals','ascii',before_f,after_f,%t)
 
 
[true_cvtos,ind_cvtos_def,statk]=findobject(statk,'cvtos',before_f,after_f,%t)
 
for i=size(ind_cvtos_def,1):-1:1
   ind_cvtos_i=ind_cvtos_def(i)
   statk_end=part(statk,ind_cvtos_i:length(statk))
   [start_cvtos,end_cvtos]=delineate(statk_end,'(',')')
   statk=part(statk,1:ind_cvtos_i-1)+'strcat'+...
         part(statk,ind_cvtos_i-1+[start_cvtos:end_cvtos-1])+','''')'
end
 
[true_lower,ind_lower_def,statk]=findobject(statk,'lower',before_f,after_f,%t)
 
for i=size(ind_lower_def,1):-1:1
   ind_lower_i=ind_lower_def(i)
   statk_end=part(statk,ind_lower_i:length(statk))
   [start_lower,end_lower]=delineate(statk_end,'(',')')
   statk=part(statk,1:ind_lower_i-1)+'convstr(string'+...
         part(statk,ind_lower_i-1+[start_lower:end_lower])+...
         part(statk_end,end_lower+1:length(statk_end))
end
 
[true_upper,ind_upper_def,statk]=findobject(statk,'upper',before_f,after_f,%t)
 
for i=size(ind_upper_def,1):-1:1
   ind_upper_i=ind_upper_def(i)
   statk_end=part(statk,ind_upper_i:length(statk))
   [start_upper,end_upper]=delineate(statk_end,'(',')')
   statk=part(statk,1:ind_upper_i-1)+'convstr(string'+...
         part(statk,ind_upper_i-1+[start_upper:end_upper])+',''u'')'+...
         part(statk_end,end_upper+1:length(statk_end))
 
end
 
[true_strsect,ind_strsect_def,statk]=findobject(statk,'strsect',before_f,after_f,%t)
 
for i=size(ind_strsect_def,1):-1:1
   ind_strsect_i=ind_strsect_def(i)
   statk_end=part(statk,ind_strsect_i:length(statk))
   [start_strsect,end_strsect]=delineate(statk_end,'(',')')
    list_arg=extract_arg(part(statk_end,start_strsect+1:end_strsect-1),...
   ',',['(';'['],[')';']'],''"')'
   statk=part(statk,1:ind_strsect_i-1)+'part('+list_arg(1)+','+...
         list_arg(2)+'+[0:'+list_arg(3)+'-1]'+...
         part(statk_end,end_strsect:length(statk_end))
end
 
 
 
endfunction
