function mat2latex_d()
 
// PURPOSE: Creates a LaTex table and store it
// demo proposed by Emmaunel Michaux
 
n=5
k=3
mat=rand(n,k)
 
// defines properties of the table
caption='My beautiful LaTex table (\%)'
digits=2
rowtit='r'+string(1:n)
coltit='c'+string(1:k)
align="c"
float='!ht'
path='SCI\macros\grocer\db\mlatex.tex'
 
mlatex=mat2latex(mat,'caption=caption','rowtit=rowtit',...
            'coltit=coltit','align=align','digits=2','path=path');
 
disp('The resulting file is located in+ '+path)
 
endfunction
 
