function prtdma_bestmodel(res,dates,out)
 
// PURPOSE: give the variables of the best model at the user
// given dates
// ------------------------------------------------------------
// INPUT:
// * res = the results typed tlist from a DMA estimation
// * dates =
//  - a string vector, the dates where to display the
//   bet tmodel,
//  -  or a integrer vector if the DMA was applied to vectors
//   and not to ts
// * out = the symbolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are displayed on the chosen file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin < 3 then
   out=%io(2)
end
 
// retrieve useful fields from the results tlist
best_model=res('best model')
comb=res('combinations')
namex=[res('fixed namex') ; res('variable namex')]
ndates=size(dates,'*')
models=emptystr(ndates,1)
 
select typeof(dates)
 
case 'string' then
   mat2prt=dates+':'
   if and(res(1) ~= 'bounds') then
      error('you cannnot enter dates when your dma estimation has not been made with ts')
   end
   boun=res('bounds')
   dnum0=date2num(boun(1))
   ind_dates=date2num_m(dates)-dnum0+1
end
 
best_model_indvars=comb(best_model(ind_dates),:)
 
for j=1:ndates
   models(j)=strcat(namex(find(best_model_indvars(j,:) == 1)),'; ')
end
write(out,'variables of the best model')
write(out,'---------------------------')
write(out,' ')
mat2prt=[mat2prt models]
printmat(mat2prt,out)
printsep(out)
 
endfunction
