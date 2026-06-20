function statk=gauss2sci_rep_dist(statk)
 
// PURPOSE: transform Gauss distrbution functions into their
// Scilab or Grocer equivalent
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
 
[statk,op,ind_length]=gauss2sci_strsub_trueobj(statk,'cdfgam','cdfgam_gauss',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
[statk,op,ind_length]=gauss2sci_strsub_trueobj(statk,'pdfn','norm_pdf',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
[statk,op,ind_length]=gauss2sci_strsub_trueobj(statk,'lnfact(','gammln(1+',before_f,[],%t,op,ind_nonempty,ind_length,elem)
 
[true_rndseed,ind_rndseed,statk]=findobject(convstr(statk),'rndseed',before_f,after_f,%t)
if true_rndseed then
  seed=stripblanks(part(statk,ind_rndseed+7:length(statk)-1))
  statk='grand(''setsd'','+seed+');'
end
 
[true_rndn,ind_rndn_def,statk]=findobject(convstr(statk),'rndn',before_f,after_f,%t)
for i=size(ind_rndn_def,1):-1:1
   ind_rndn_i=ind_rndn_def(i)
   statk_end=part(statk,ind_rndn_i:length(statk))
   [start_rndn,end_rndn]=delineate(statk_end,'(',')')
   statk=part(statk,1:ind_rndn_i-1)+'grand'+part(statk_end,5:end_rndn-1)+...
        ',''nor'',0,1)'+part(statk_end,end_rndn+1:length(statk_end))
end
 
[true_rndu,ind_rndu_def,statk]=findobject(convstr(statk),'rndu',before_f,after_f,%t)
for i=size(ind_rndu_def,1):-1:1
   ind_rndu_i=ind_rndu_def(i)
   statk_end=part(statk,ind_rndu_i:length(statk))
   [start_rndu,end_rndu]=delineate(statk_end,'(',')')
   statk=part(statk,1:ind_rndu_i-1)+'grand'+part(statk_end,5:end_rndu-1)+...
        ',''unf'',0,1)'+part(statk_end,end_rndu+1:length(statk_end))
end
 
endfunction
 
