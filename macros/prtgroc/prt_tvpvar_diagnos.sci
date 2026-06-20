function prt_tvpvar_diagnos(res,out)
 
// PURPOSE: prints the results of tvp_var diagnostics for a
// peculiar type of coefficients
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list from a tvp_var diagnos call
// * out = the symbolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
mat2prt=[' ' 'median' 'mean' 'min' 'max' ;' '+emptystr(1,5) ;]
orders=res('auto order')
autocorr=res('autocorrelation')
for i=1:size(orders,'*')
   auto_i=autocorr(i)
   auto_i=auto_i(~isnan(auto_i))
   mat2prt=[mat2prt ; string(orders(i))+'-th order sample autocorrelation' ...
           string([median(auto_i) mean(auto_i) min(auto_i) max(auto_i)])]
end
 
resg=res('Geweke tests')
mat2prt=[mat2prt ; 'ineffeciency factors' string([resg('median tapered inefficiency factor') ...
resg('mean tapered inefficiency factor') resg('min tapered inefficiency factor') ...
resg('max tapered inefficiency factor')])]
 
resr=res('Raftery tests')
rl_runs=resr('# of draws for required accuracy')
rl_runs=rl_runs(~isnan(rl_runs))
mat2prt=[mat2prt ; 'RL runs' string([median(rl_runs) mean(rl_runs) min(rl_runs) max(rl_runs)])]
 
length_mat=max(sum(length(mat2prt),'c'))+4
titl='convergence diagnostics for tvp var coefficients '+res('object')
length_title=length(titl)
diff_length=length_mat-length_title
write(out,strcat(' '+emptystr(1,floor(diff_length/2)))+titl)
write(out,strcat(' '+emptystr(1,floor(diff_length/2)))+strcat('-'+emptystr(1,length_title)))
printmat(mat2prt,out)
printsep(out)
 
endfunction
