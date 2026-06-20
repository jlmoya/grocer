function prtfac_pca(res,out)
 
// PURPOSE: prints the results of a dynamic factor analyis
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the specified file
// ---------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
snum = res('snum')
pnum = res('pnum')
namex=res('namex')
 
write(out,' ')
mat2print=['   ' 'Static factor analysis results']
if res('stan') == 'stan' then
   mat2print=[mat2print ; '   ' '   on standardized variables']
end
mat2print=[mat2print ; '   ' '-------------------------------']
printmat(mat2print,out)
 
write(out,' ')
write(out,'with the following variables:')
for i=1:size(namex,'*')
   write(out,namex(i))
end
write(out,' ')
 
if res('prests') then
   ch='estimation period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
 
num = ''
for i = 1:size(snum,2)
   num = joinstr(num,string(snum(i))+' ','+');
end
write(out,'number of selected factors: '+num)
if res('bai_ng') == 'no' then
  write(out,'factor selection done by: user')
else
  write(out,'factor selection done by: '+res('bai_ng')+' criteria')
end
write(out,'number of factors for printing results: '+string(pnum))
write(out,' ')
 
F = []
for i = 1:pnum
	execstr('F = [F;''factor '+string(i)+''']')
end
mat2print = [F,string(res('propor')),string(cumsum(res('propor')))]
mat2print = ['','Prop. variance','Cumulative';mat2print]
printmat(mat2print,out)
 
write(out,' ')
write(out,' correlations between variables & factors')
 
if pnum < 10 then
	F = ['';F]'
 
	mat2print = [res('namex'),string(res('corr_x_f'))]
	mat2print = [F;mat2print]
	printmat(mat2print,out)
 
elseif (pnum >= 10 & pnum < 20) then
	F1 = ['';F(1:9)]'
	F2 = ['';F(10:pnum)]'
 
	mat2print = [res('namex'),string(res('corr_x_f')(:,1:9))]
	mat2print = [F1;mat2print]
	printmat(mat2print,out)
	write(out,' ')
	mat2print = [res('namex'),string(res('corr_x_f')(:,10:pnum))]
	mat2print = [F2;mat2print]
	printmat(mat2print,out)
	
elseif (pnum >= 20) then
	F1 = ['';F(1:9)]'
	F2 = ['';F(10:19)]'
	F3 = ['';F(20:pnum)]'
 
	mat2print = [res('namex'),string(res('corr_x_f')(:,1:9))]
	mat2print = [F1;mat2print]
	printmat(mat2print,out)
	write(out,' ')
 
	mat2print = [res('namex'),string(res('corr_x_f')(:,11:19))]
	mat2print = [F2;mat2print]
	printmat(mat2print,out)
	write(out,' ')
 
	mat2print = [res('namex'),string(res('corr_x_f')(:,20:pnum))]
	mat2print = [F3;mat2print]
	printmat(mat2print,out)	
end	
printsep(out)
 
endfunction
 
 
