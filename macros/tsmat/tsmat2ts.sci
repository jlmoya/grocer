function tsmat2ts(grocer_tsmat,grocer_names,grocer_prefix,grocer_noprint)
 
// PURPOSE: transform a tsmat into n ts
// ------------------------------------------------------------
// INPUT:
// * tsmat = a tsmat object
// * grocer_names = a string, collecting the subset of variables
//   in the tsmat to transform into ts
// * grocer_prefix = a string, a prefix to add before the names
//   of the cretaed ts (optional; default = nothing)
// * grocer_noprint = a booelan, indicating wether to print the
//   names of the created series (optional ; default: %t)
// ------------------------------------------------------------
// OUTPUT:
// * the corresponding ts (created with the resume capability)
// ------------------------------------------------------------
// Copyright Eric Dubois 2008-2024
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_nargout,grocer_nargin]=argn(0)
if grocer_nargin == 4 then
   grocer_prt=%f
else
   grocer_prt=%t
end
if grocer_nargin < 3 then
   grocer_prefix=''
else
   grocer_prt=%t
end
grocer_s=grocer_tsmat('series')
grocer_nts=size(grocer_s,2)
 
if grocer_nargin < 2 then
   grocer_names=grocer_tsmat('names')
   grocer_nbnames=size(grocer_names,'*')
   grocer_indnames=1:grocer_nbnames
 
else
   grocer_names=stripblanks(grocer_names)
   grocer_nbnames=size(grocer_names,'*')
   grocer_tsmat_names=grocer_tsmat('names')
   grocer_indnames=zeros(1,grocer_nbnames)
   for grocer_i=1:grocer_nbnames
      grocer_ind_i=find(grocer_tsmat_names == grocer_names(grocer_i))
      if isempty(grocer_ind_i) then
         error('series '+string(grocer_names(grocer_i))+' not found in tsmat')
      end
      grocer_indnames(grocer_i)=grocer_ind_i
   end
 
end
 
grocer_names=grocer_prefix+strsubst(grocer_names,' ','_') 
if or(grocer_tsmat(1) == 'comments') then
   grocer_comm=grocer_tsmat('comments')
   for grocer_i=1:grocer_nbnames
      grocer_j=grocer_indnames(grocer_i)
      execstr(grocer_names(grocer_i)+'=tlist([''ts'';''freq'';''dates'';''series'';''comment''],grocer_tsmat(''freq''),grocer_tsmat(''dates''),grocer_s(:,grocer_j),grocer_comm(grocer_j))')
 
   end
 
else
   for grocer_i=1:grocer_nbnames
      grocer_j=grocer_indnames(grocer_i)
      execstr(grocer_names(grocer_i)+'=tlist([''ts'';''freq'';''dates'';''series''],grocer_tsmat(''freq''),grocer_tsmat(''dates''),grocer_s(:,grocer_j))')
 
   end
end
 
if grocer_prt then
   write(%io(2),'ts '+strcat(grocer_names,',')+' will be created','(a)')
end
execstr('['+grocer_names+']=resume('+strcat(grocer_names,',')+',grocer_names)')
 
endfunction
