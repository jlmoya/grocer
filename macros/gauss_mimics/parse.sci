function tok = parse(str,delim)
 
// PURPOSE: mimic gauss function parse: parses a string,
// returning a character vector of tokens
// ------------------------------------------------------------
// INPUT:
// * str = string consisting of a series of tokens and/or
//   delimiters
// * delim = (N x K) character matrix of delimiters that might
//   be found in str
// ------------------------------------------------------------
// OUTPUT:
// * tok = (M x k) character vector consisting of the tokens
//   contained in str. All tokens are returned; any delimiters
//   found in str are ignored
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
ind_delim=[]
for i=1:size(delim,'*')
   ind_delim = [ind_delim strindex(str,delim(i))]
end
ind_delim=gsort(ind_delim,'g','i')
 
if ind_delim(1) ~= 1 then
  ind_delim=[0 ind_delim]
end
if ind_delim($) ~= length(str) then
  ind_delim=[ind_delim length(str)+1]
end
 
ntok=size(ind_delim,2)
for i=ntok:-1:2
   if ind_delim(i) == ind_delim(i-1)+1 then
      str=part(str,1:ind_delim(i)-1)+part(str,ind_delim(i)+1:length(str))
      ind_delim=[ind_delim(1:i-1) ind_delim(i+1:$)-1]
   end
end
 
ntok=size(ind_delim,2)
tok=emptystr(ntok,1)
for i=1:ntok-1
   tok(i)=part(str,ind_delim(i)+1:ind_delim(i+1)-1)
end
 
endfunction
