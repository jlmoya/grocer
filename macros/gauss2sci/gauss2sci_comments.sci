function [v,comments,comments_start,comments_end]=gauss2sci_comments(v)
 
// PURPOSE: delineate blocks of comments (that is sequences
// of lines without any command -or empty line...- between
// them)
// ------------------------------------------------------------
// INPUT:
// * v = a (N x 1) string vector containing gauss instructions
// ------------------------------------------------------------
// OUTPUT:
// * v = a (N x 1) string vector with the comments in Scilab
//   format
// * comments_start = a (k x 2) real matrix reporting the
//   lines (first column) and column (second column) where a
//   block of comments starts
// * comments_end = a (k x 2) real matrix reporting the
//   lines (first column) and column (second column) where a
//   block of comments ends
// ------------------------------------------------------------
// Copyright: Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
comments_start=[]
comments_end=[]
nlines=size(v,1)
endfile=%f
i=0
comment1=[]
comment2=[]
comment3=[]
comment4=[]
comment=[]
comments=emptystr(nlines,1)
 
while ~endfile then
 
   while i < nlines & isempty(comment) then
      // search the start of a comment
      i=i+1
      comment1=strindex(v(i),'/*')
      if ~isempty(comment1) then
         comment1=[comment1 ; 0*comment1+1]
      end
      comment2=strindex(v(i),'@')
      if ~isempty(comment2) then
         comment2=[comment2 ; 0*comment2+2]
      end
      comment3=strindex(v(i),'//')
      if ~isempty(comment3) then
         comment3=[comment3 ; 0*comment3+3]
      end
      comment=[comment1 comment2 comment3]
      comment4=strindex(v(i),':')
      if ~isempty(comment4) then
         vi_aux=stripblanks(v(i))
         if (part(vi_aux,length(vi_aux)) == ':' & isempty(strindex(v(i),'('))  ...
             & isempty(strindex(v(i),'['))) & isempty(comment) then
            comment=[comment [1 ; 4]]
         end
      end
   end
 
   if isempty(comment) then
      endfile=%t
 
   else
      [junk,ind]=gsort(comment(1,:),'g','i')
      comment=comment(:,ind)
      // determine what starts the comment
 
      select comment(2,1)
 
      case 1 then
    // the comment begins with '/*'
 
         comments_start=[comments_start ; i comment1(1,1) ]
         comments(i)='//'+part(v(i),comment1(1,1)+2:length(v(i)))
         v(i)=part(v(i),1:comment1(1,1)-1)+comments(i)
         vi=part(v(i),comment1(1,1)+2:length(v(i)))
         ind_endcomi=strindex(vi,'*/')
         start_comm=comment1(1,1)
 
         while i < nlines & isempty(ind_endcomi)
            i=i+1
            v(i)='//'+v(i)
            vi=v(i)
            comments(i)=vi
            ind_endcomi=strindex(vi,'*/')
            start_comm=1
         end
 
         if isempty(ind_endcomi) then
            error('comment opened by /* is not closed by */')
 
         else
            comments_end=[comments_end ; i ]
            if ~isempty(strsubst(part(vi,ind_endcomi(1)+2:length(vi)),' ','')) then
               nchars_transf=length(vi)-ind_endcomi(1)-1
               vi=part(v(i),1:length(v(i))-nchars_transf+1)
               v=[v(1:i-1);vi;part(v(i),ind_endcomi(1)+2:length(v(i)));v(i+1:$)]
               comments=[comments(1:i-1);vi;comments(i:$)]
               nlines=nlines+1
            else
               v(i)=strsubst(v(i),'*/','')
               comments(i)=part(v(i),start_comm:length(v(i)))
            end
            comment1=[]
         end
 
      case 2 then
      // the comment begins with '@'
         comments_start=[comments_start ; i comment2(1,1) ]
         vi='//'+part(v(i),comment2(1,1)+1:length(v(i)))
         v(i)=part(v(i),1:comment2(1,1)-1)+vi
         ind_arobasi=strindex(vi,'@')
 
         // now search the next '@': it should close the comment
         if ~isempty(ind_arobasi) then
         // the comment ends on the line it has begun
            comments_end=[comments_end ; i ]
            comments(i)=part(vi,1:ind_arobasi(1)-1)
            if ~isempty(strsubst(part(vi,ind_arobasi(1)+1:length(vi)),' ','')) then
               nchars_transf=length(vi)-ind_arobasi(1)
               v(i)=part(v(i),1:length(v(i))-nchars_transf-2)
               v=[v(1:i-1);v(i);part(vi,length(vi)-nchars_transf+1:length(vi));v(i+1:$)]
               nlines=nlines+1
            else
               nchars_suppr=length(vi)-ind_arobasi(1)
               v(i)=part(v(i),1:length(v(i))-nchars_suppr-2)
            end
            comment2=[]
 
         else
            comments(i)=vi
            i=i+1
            v(i)='//'+v(i)
            ind_arobasi=strindex(v(i),'@')
 
            while i < nlines & isempty(ind_arobasi)
               comments(i)=v(i)
               i=i+1
               v(i)='//'+v(i)
               ind_arobasi=strindex(v(i),'@')
            end
 
            if isempty(ind_arobasi) then
               error('comment opened by @ is not closed by @')
 
            else
               comments_end=[comments_end ; i ]
               if ~isempty(strsubst(part(v(i),ind_arobasi(1)+1:length(v(i))),' ','')) then
                  v=[v(1:i-1);part(v(i),1:ind_arobasi(1)-1);part(v(i),ind_arobasi(1)+1:length(v(i)));v(i+1:$)]
                  comments=[comments(1:i-1);v(i);emptystr();comments(i+1:$)]
                  nlines=nlines+1
               else
                  comments(i)=part(v(i),1:ind_arobasi(1)-1)
                  v(i)=part(v(i),1:ind_arobasi(1)-1)
               end
               comment2=[]
            end
         end
 
      case 3 then
      // comments starts with '//' as in Scilab
         comments_start=[comments_start ; i comment3(1,1)]
         comments_end=[comments_end ; i ]
         comments(i)=part(v(i),comment3(1,1):length(v(i)))
 
      case 4 then
      // this is a label, not a comment
         comments_start=[comments_start ; i 1]
         comments_end=[comments_end ; i+1 ]
         comments=[comments(1:i-1) ; '//warning: the following label has been put into comment: ' ; '//'+v(i) ;comments(i+1:$)]
         v=[v(1:i-1) ; ' ' ; '//'+v(i) ;v(i+1:$)]
         i=i+1
         nlines=nlines+1
      end
      comment=[]
   end
end
 
//now deal with contiguous comment blocks
i=2
while i <= size(comments_start,1) then
   if comments_start(i,2) == 1 & comments_end(i-1,1) == comments_start(i,1)-1 then
      comments_start(i,:) = []
      comments_end(i-1,:) = []
   elseif comments_end(i-1,1) == comments_start(i,1)-1 ....
       & isempty(strsubst(part(v(comments_start(i,1)),1:comments_start(i,2)),' ','')) then
      comments_start(i,:) = []
      comments_end(i-1,:) = []
   else
      i=i+1
   end
end
 
endfunction
