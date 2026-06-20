function sa = strsplit_gauss(sv)
 
// PURPOSE: mimic gauss function strsplit: splits an (N x 1)
// string vector into an N×K string array of the individual
// tokens
// ------------------------------------------------------------
// INPUT:
// * sv = (N x 1) string array
// ------------------------------------------------------------
// OUTPUT:
// * sa = (N x K) string array
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
sa=[]
for i=1:size(sv,'*')
   str=sv(i)
   indq1=strindex(str,'''')
   indq2=strindex(str,''"')
   indleftpar=strindex(str,'(')
   indrightpar=strindex(str,'(')
 
   indsep=strindex(str,ascii(32))
   indsep=[indsep strindex(str,ascii(9))]
   indsep=[indsep strindex(str,ascii(44))]
   indsep=[indsep strindex(str,ascii(10))]
   indsep=[indsep strindex(str,ascii(13))]
 
   for j=1:size(indq1,2)/2
      indsep(indsep > indq1(j*2-1) & indsep < indq1(j*2))=[]
   end
 
   for j=1:size(indq2,2)/2
      indsep(indsep > indq2(j*2-1) & indsep < indq2(j*2))=[]
   end
 
   for j=1:size(indleftpar,2)
      indsep(indsep > indlefpar(j) & indsep < indrightpar(j))=[]
   end
 
   indsep=gsort(indsep,'g','i')
   indsep=[0 indsep length(str)+1]
 
   nstr=size(indsep,2)
   for j=nstr-1:-1:1
      if indsep(j)+1 ==indsep(j+1) then
        indsep(j+1)=[]
      end
   end
   nstr=size(indsep,2)-1
 
   sai=emptystr(1,nstr)
   for j=1:nstr
      sai(j)=part(str,indsep(j)+1:indsep(j+1)-1)
   end
 
   sai=strsubst(sai,ascii(32),'')
   sai=strsubst(sai,ascii(9),'')
   sai=strsubst(sai,ascii(44),'')
   sai=strsubst(sai,ascii(10),'')
   sai=strsubst(sai,ascii(13),'')
   sa=[sa ; sai]
 
end
 
endfunction
