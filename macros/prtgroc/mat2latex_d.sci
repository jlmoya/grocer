function mat2latex_d()
 
// PURPOSE: Creates a LaTex table and store it
// demo proposed by Emmaunel Michaux
// http://grocer.toolbox.free.fr/grocer.html
 
n=5;
k=3;
mat=rand(n,k);
 
// defines properties of the table
caption='My beautiful LaTex table (\%)';
digits=[2,2,2];
rowtit='r'+string(1:n);
coltit='c'+string(1:k);
align=["l","c","c","c"];
float='!ht';
path='SCI\macros\grocer\db\mlatex.tex';
 
mlatex=mat2latex(mat,'caption=caption','rowtit=rowtit',...
            'coltit=coltit','align=align','digits=digits','path=path');
 
write(%io(2),'The resulting file is located in+ '+path,'(a)');
 
endfunction
 
