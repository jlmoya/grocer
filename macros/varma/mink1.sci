function [result]=mink1()
// Bivariate modelling of the mink-muskrat series
// Model (5.8) of Jenkins and Alavi (1981) pag. 37
// The data is already in logs

global GROCERDIR ;
 
e4init();
load(GROCERDIR+'/data/varma_d.dat');
 
z1 = transdif(mink(:,3),1,1);
 
z2 = mink(:,2)-mean(mink(:,2));
z = [z1,z2(2:62)];
 
muskrat=z1
mink=z2(2:62)
//
// Define the parameter matrices and generate
// the THD representation
phi1 = ['0','=0';'=0','0'];
phi2 = ['0','=0';'=0','0'];
phi3 = ['0','=0';'=0','=0'];
phi4 = ['0','=0';'=0','=0'];
theta = [0,0;0,0];
sigma = [0,0;0,0];
//
 
bounds()
result = varma(['muskrat' 'mink'],[phi1,phi2,phi3,phi4],[],theta,[],sigma,1);
 
endfunction
 
