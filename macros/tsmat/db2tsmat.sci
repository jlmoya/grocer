function tsmat=db2tsmat(db,varargin)
 
// PURPOSE: transform a database made of ts in a tsmat
// ------------------------------------------------------------
// INPUT:
// * db = the data base
// * varargin = options that can be:
//   - 'testna' if the users wants to test the na values in the
//     data (default: not tested)
//   - 'dropna' if the users wants to remove the periods when
//     one at least of the series contains na values (default:
//     kept)
//   - 'keepall' if the users wants to keep real vectors in the
//     database (their length must then be equal to the length
//     of the time period of the ts)
// ------------------------------------------------------------
// OUTPUT:
// * tsmat= a tlist of type tsmat
// ------------------------------------------------------------
// Copyright Eric Dubois 2008
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_keepall=%f
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if grocer_argi == 'keepall' then
         grocer_keepall=%t
         varargin(grocer_i)=null()
      end
   end
end
 
load(db)
listvar=dblist(db)
nvar=size(listvar,1)
if ~grocer_keepall then
   for i=nvar:-1:1
      if typeof(evstr(listvar(i))) == 'constant'  then
         listvar(i)=[]
      end
   end
end
 
grocer_boundsvar=[]
tsmat=ts2tsmat(listvar,varargin(:))
 
endfunction
 
