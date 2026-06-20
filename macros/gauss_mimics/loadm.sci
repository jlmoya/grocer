function loadm(varargin)
 
// PURPOSE: mimics gauss function loadm:
// ------------------------------------------------------------
// INPUT:
// * x = a (N x k) matrix
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x K) matrix, x lagged 1 period
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
global list_sysstate;
 
nargin = length(varargin)
 
arg1=varargin(1)
arg1_compact=strsubst(arg1,' ','')
if part(arg1_compact,1:5) == 'path=' then
// change the default path for the files to load
   indeq=strindex(arg1,'=')
   arg1=part(arg1,indeq(1)+1:length(arg1))
   indblank=strindex(arg1,' ')
   if isempty(indblank) then
      list_sysstate(5)=arg1
      arg1=emptystr()
   else
      list_sysstate(5)=part(arg1,1:indblank(1)-1)
      arg1=stripblanks(part(arg1,indblank(1)+1:length(arg1)))
   end
end
 
if isempty(arg1) then
   // nothing to laod in arg # 1
   varargin(1)=null()
   nargin=nargin-1
end
 
if nargin ~= 0 then
   path=stripblanks(list_sysstate(5))
   namemat=emptystr(nargin,1)
   mat=list()
   for i=1:nargin
      argi=varargin(i)
      indeq=strindex(argi,'=')
      if isempty(indeq) then
         // name of the matrix is the name of the file
         namemat(i)=stripblanks(argi)
         mat($+1)=gauss_loadfile(path+argi)
 
      else
         db=stripblanks(part(argi,indeq(1)+1:length(argi)))
         ind_slash=strindex(db,'/')
         if isempty(ind_slash) then
            mati=gauss_loadfile(db)
         else
            mati=gauss_loadfile(path+db)
         end
         ind_leftbrack=strindex(argi,'[')
         ind_rightbrack=strindex(argi,']')
 
         if isempty(ind_leftbrack) then
            namemat(i)=stripblanks(part(argi,1:indeq(1)-1))
            mat($+1)=mati
         else
            namemat(i)=stripblanks(part(argi,1:ind_leftbrack(1)-1))
            execstr('dim='+part(argi,ind_leftbrack:ind_rightbrack))
            mat($+1)=reshape_gauss(mati,dim(1),dim(2))
         end
      end
   end
 
   execstr('['+strcat(namemat,',')+']=resume('+joinstr('mat(',string(1:nargin),'),')+'))')
 
end
 
 
endfunction
 
