function [v,blockstate_start,blockstate_end]=gauss2sci_blockstates(v,comments_start,comments_end)
 
// PURPOSE: delineates blocks of statements (that is a sequence
// of statements without any line or piece of line of comment)
// ------------------------------------------------------------
// INPUT:
// * v = a (N x 1) string vector
// * comments_start = a (k x 2) real matrix reporting the
//   lines (first column) and column (second column) where a
//   block of comments starts
// * comments_end = a (k x 2) real matrix reporting the
//   lines (first column) and column (second column) where a
//   block of comments ends
// ------------------------------------------------------------
// OUTPUT:
// * v = the string vector transformed such as the statement
//   that cover several lines are gathered on a lone line; each
//   original line is separated by the string '...' which
//   indicates in Scilab that the statement continues on the
//   next line
// * blockstate_start = a (k x 2) real matrix reporting the
//   lines (first column) and column (second column) where a
//   block of statements starts
// * blockstate_end = a (k x 2) real matrix reporting the
//   lines (first column) and column (second column) where a
//   block of statements ends
// ------------------------------------------------------------
// Copyright: Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
nlines=size(v,1)
blockstate_start=[]
blockstate_end=[]
 
if nlines ~= 0 then
   if isempty(comments_start) then
// deal the special case when there is no comment inside the function
      blockstate_start=[1 1]
      blockstate_end=[nlines length(textf(nlines))]
 
   else
 
      blockstate_start=[]
      blockstate_end=[]
 
      if comments_start(1,1) ~= 1 | comments_start(1,2) ~=1 then
      // the file begins by a statement and not a comment
         blockstate_start=[1 1]
         if comments_start(1,2) == 1 then
            blockstate_end=[blockstate_end ; comments_start(1,1)-1 length(v(comments_start(1,1)-1))]
         else
            blockstate_end=[blockstate_end ; comments_start(1,1) comments_start(1,2)-1]
         end
      end
 
      for i=2:size(comments_start,1)
         blockstate_start=[blockstate_start ; comments_end(i-1)+1 1]
         if comments_start(i,2) == 1 then
            blockstate_end=[blockstate_end ; comments_start(i,1)-1 length(v(comments_start(i,1)-1))]
         else
            blockstate_end=[blockstate_end ; comments_start(i,1) comments_start(i,2)-1]
         end
      end
 
      if comments_end($) ~= nlines then
         blockstate_start=[blockstate_start ; comments_end($,1)+1 1]
         blockstate_end=[blockstate_end ; nlines length(v(nlines))]
      end
   end
end
 
for j=1:size(blockstate_start,1)
   for k=blockstate_start(j,1):blockstate_end(j,1)-1
      testline=strsubst(v(k),' ','')
      testline=strsubst(testline,ascii(9),'')
      kn=k
      while isempty(testline) then
         kn=kn-1
         if kn==1 | kn <= blockstate_start(j,1) then
            testline=';'
         else
            testline=strsubst(v(kn),' ','')
            testline=strsubst(testline,ascii(9),'')
         end
      end
      if part(testline,length(testline)) ~= ';' then
         v(k)=v(k)+' ... '
      end
   end
   ind_end=blockstate_end(j,1)
end
 
endfunction
 
