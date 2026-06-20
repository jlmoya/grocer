function gauss2sci_proc(textf,dirout,commentsf,comment_startf,comment_endf)
 
// PURPOSE: replace the Gauss definition of the function
// with its Scilab equivalent and store the result in a .sci
// file having the name of the function
// ------------------------------------------------------------
// INPUT:
// * textf = the text of a gauss function
// * dirout = the name of the directory to save the Scilab
//   resulting function
// * comments_startf = a (N x 2) matrix containing the indexes
//   of the line and column where a comment start
// * comments_endf = a (N x 1) matrix containing the indexes of
//   the line and column where a comment start
// ------------------------------------------------------------
// OUTPUT:
// * NOTHING: the result is stored in a .sci file
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
// make the transformations to obtain the definition of a Scilab function
 
mat2prt=[ ' ' ; 'starting to deal with the block:' ;'--------------------------------' ; ...
' ' ; textf(1) ; '...' ; textf($) ; '--------------------------------' ; ' ']
printmat(mat2prt,%io(2))
 
[textf,statements,type_statements,state_start,state_end]=gauss2sci_statements(textf,comment_startf,comment_endf)
 
[statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end]=...
gauss2sci_rep_all(statements,type_statements,commentsf,comment_startf,comment_endf,state_start,state_end)
 
[statements,namefunc,state_start,state_end,commentsf]=gauss2sci_def_func(statements,state_start,state_end,commentsf)
 
textf=gauss2sci_rebuild(statements,state_start,commentsf)
textf=strsubst(textf,'gauss2sci_threedots','...')
 
fileout=strsubst(dirout+'\'+namefunc+'.sci','\\','\')
 
[fd,err]=mopen(fileout,'w')
mputl(textf,fd)
mclose(fd)
 
endfunction
