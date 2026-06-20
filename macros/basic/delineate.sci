function [start_obj,end_obj]=delineate(str,start_char,end_char)
 
// PURPOSE: in a string, finds the first opening character (for
// instance a '(') and the corresponding closing character (for
// instance a ')')
// ------------------------------------------------------------
// INPUT:
// * str = a string
// * start_char = the opening character
// * start_char = the closing character
// ------------------------------------------------------------
// OUTPUT:
// * start_obj = the index of the first opening character
// * end_obj = the index of the corresponding closing character
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_start=strindex(str,start_char)
start_obj=ind_start(1)
nstart=size(ind_start,2)
ind_start=[ind_start ; ones(1,nstart)]
 
ind_end=strindex(str,end_char)
nend=size(ind_end,2)
ind_end=[ind_end ; -ones(1,nend)]
 
ind_fus=[ind_start , ind_end]
[junk,indord]=gsort(ind_fus(1,:),'g','i')
ind_fusord=ind_fus(:,indord)
ind_fusord_zero=find(cumsum(ind_fusord(2,:)) == 0)
 
end_obj=ind_fusord(1,ind_fusord_zero(1))
 
 
endfunction
