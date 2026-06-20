function [tsout]=vec2ts(vector,boun)
 
// PURPOSE: transform into a vector into a ts according to the
// bounds given in vector boun
// ------------------------------------------------------------
// INPUT:
// * vector = a (1xn) or (nx1) vector
// * boun = a (1xn) or (nx1) string vector of bounds
// ------------------------------------------------------------
// OUTPUT:
// * tsout = the corresponding timeseries
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
boun_num=date2num_m(boun)
vector=vec2col(vector)
 
beg_span=1
end_span=boun_num(2)-boun_num(1)+1
seri = vector(1:end_span)
for i=2:size(boun,1)/2
   beg_span=end_span+1
   end_span=beg_span+boun_num(i*2)-boun_num(i*2-1)
// fill the holes in the series with na vales
   seri=[seri ; %nan*ones(boun_num(i*2-1)-boun_num(i*2-2)-1,1)...
      ; vector(beg_span:end_span)]
end
tsout=reshape(seri,boun(1))
 
endfunction
