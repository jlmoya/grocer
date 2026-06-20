function gauss2sci_script(textf,dirout,name_sce,commentsf,comment_startf,comment_endf)
 
// PURPOSE: replace the Gauss definition of the function
// with its Scilab equivalent and store the result in a .sci
// file having the name of the function
// ------------------------------------------------------------
// INPUT:
// * textf = the text of a gauss function
// * dirout = the name of the directory to save the Scilab
//   resulting function
// * comment_startf = a (N x 2) matrix contaning the # of the
//   line and column where a comment start
// * comment_endf = a (N x 1) matrix contaning the # of the
//   line and column where a comment start
// ------------------------------------------------------------
// OUTPUT:
// * NOTHING: the result is stored in a .sci file
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
i=size(comment_startf,1)
while i > 1 then
   if comment_startf(i,2) ==1 & comment_startf(i,1) == comment_endf(i-1)+1 then
      comment_startf(i,:)=[]
      comment_endf(i-1)=[]
   else
      i=i-1
   end
end
 
[textf,statements,type_statements,state_start,state_end]=gauss2sci_statements(textf,comment_startf,comment_endf)
 
if ~isempty(textf) then
   [statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end]=...
   gauss2sci_rep_all(statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end)
 
   textf=gauss2sci_rebuild(statements,state_start,commentsf)
 
   fileout=strsubst(dirout+'\'+name_sce+'.sce','\\','\')
   fileout=strsubst(fileout','.src.sce','.sce')
 
   [fd,err]=mopen(fileout,'w')
   mputl(textf,fd)
   mclose(fd)
end
 
endfunction
