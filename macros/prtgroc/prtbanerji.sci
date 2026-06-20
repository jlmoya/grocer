function prtbanerji(res,out)
 
// PURPOSE: prints the results of Randomization test
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following function:
//	banerji()
// ---------------------------------------------------
// Copyright E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
lead = res('lead')
extra = res('dates_extra')
nextra = size(extra,1)
pextra =res('PT_extra')
 
write(out,' ')
write(out,'	Banerji test of leading profile')
write(out,'H0 : no k-periods leading of competing series')
write(out,' ')
write(out,'# of extra-cycle in the reference series detected: '+string(nextra))
if nextra ~= 0 then
	write(out,'Dates are:')
end
mat2print = []
tmp = [' ' ; ' ']
for i = 1:nextra
	concat = [pextra(i,:);string(extra(i,:))]
	mat2print = [mat2print,tmp,concat]
  printmat(mat2print,out)
end
write(out,' ')
 
slead = ['k<1']
if lead > 0 then
	for i =1:lead
		execstr('slead = [slead;''k<'+string(i+1)+''']')
	end
end
 
mat2print = ['H0','sum','rejection prob.']
mat2print = [mat2print;slead,string(res('sum_ini')),string(res('signi'))]
 
printmat(mat2print,out)
printsep(out)
 
endfunction
