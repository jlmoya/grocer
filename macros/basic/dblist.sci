function grocer_listvar=dblist(grocer_filein,varargin)
 
// PURPOSE: gives the content of a database (simple but not
// elegant and, I presume, not efficient)
// ------------------------------------------------------------
// INPUT:
// * grocer_filein = name of the database
// * varargin = optional arguments hich can be:
//   - 'matlab' if the database is a grocer_matlab one (must be the
//   first variable argument
//   -
// ------------------------------------------------------------
// OUTPUT:
// * l = column vector containing the names of variables in the
// database
// ------------------------------------------------------------
// NOTES: this is an awful way to determine the content of a
// database, but it works and doing more efficient and elegant
// would imply for me too big an investment in scilab code...
// Obviously, if you have better at hand, I take it!
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2019
// http://grocer.toolbox.free.fr/grocer.html
 
 
// set default options
[grocer_nargout,grocer_nargin]=argn(0)
grocer_matlab=%f
grocer_short=%f
// read optional arguments
for grocer_i=grocer_nargin-1:-1:1
   if varargin(grocer_i) == 'grocer_matlab' then
      grocer_matlab=%t
      varargin(grocer_i)=null()
      grocer_nargin=grocer_nargin-1
   elseif varargin(grocer_i) == 'short' then
      grocer_short=%t
      grocer_nargin=grocer_nargin-1
      varargin(grocer_i)=null()
   end
end
 
grocer_l=who('local')
 
if grocer_matlab then
   loadmatfile(grocer_filein)
else
   load(grocer_filein)
end
 
if exists('grocer_content','local') then
   grocer_listvar=grocer_content
 
else
 
   grocer_listvar=who('local')
   for grocer_i=size(grocer_listvar,'*'):-1:1
      if ~exists(grocer_listvar(grocer_i),'local') then
         grocer_listvar(grocer_i)=[]
      end
    end
   grocer_listvar(grocer_listvar == 'grocer_l')=[]
   grocer_listvar(grocer_listvar == 'grocer_i')=[]
   grocer_listvar(grocer_listvar == 'grocer_nargin')=[]
   grocer_listvar(grocer_listvar == 'grocer_nargout')=[]
   grocer_listvar(grocer_listvar == 'nargin')=[]
   grocer_listvar(grocer_listvar == 'nargout')=[]
   grocer_listvar(grocer_listvar == 'grocer_filein')=[]
   grocer_listvar(grocer_listvar == 'grocer_fileout')=[]
   grocer_listvar(grocer_listvar == 'varargin')=[]
   grocer_listvar(grocer_listvar == 'grocer_matlab')=[]
   grocer_listvar(grocer_listvar == 'grocer_short')=[]
   grocer_listvar(grocer_listvar == '%_sodload')=[]
   grocer_listvar(grocer_listvar == 'ans')=[]
   grocer_listvarn=unique(grocer_listvar)
   ndata=size(grocer_listvarn,'*')
   grocer_listvar=grocer_listvar(1:ndata)
 
end
 
if grocer_listvar(1,1) == 'VARIABLES' then
   start=3
   if grocer_short then
      deb=1
   else
      deb=3
   end
else
   start=1
   deb=1
end
 
index=[]
 
if grocer_nargin > 1 then
   for i=1:length(varargin)
      [selected,index_i]=select_mask(grocer_listvar(start:$,1),varargin(i))
      index=[index ; index_i ]
   end
   index=unique(index)+start-1
else
   index=[start:size(grocer_listvar,1)]'
end
grocer_listvar=grocer_listvar([[1:deb-1]' ; index],:)
 
endfunction
 
