function [lres,mres,tres]=theil_d()
// PURPOSE: An example using theil(),
// Theil-Golberger mixed estimation
//---------------------------------------------------
// USAGE: theil_d
//---------------------------------------------------
 
// generate a data set
 
 
 
bet = ones(5,1);
 
xmat = rand(100,4,'n');
exo = [ones(100,1),xmat];
evec = rand(100,1,'n');
 
endo = exo*bet+evec;
 
res = ols('endo','exo');
 
//nvar = res('nvar');
 
// set up prior
// prior means for the coefficients
rvec = [1; ;1;1;1;1];
 
rmat = eye(5,5);
bv = 10000;
 
// umat1 = loose prior
// umat2 = medium prior
// umat3 = tight prior
 
 
umat1 = eye(5,5)*bv;
// initialize prior variance as diffuse
 
for i = 1:5
  umat1(i,i) = 1;
  // overwrite diffuse priors with informative prior
end
 
 
umat2 = eye(5,5)*bv;
// initialize prior variance as diffuse
 
for i = 1:5
  umat2(i,i) = .1;
  // overwrite diffuse priors with informative prior
end
 
umat3 = eye(5,5)*bv;
// initialize prior variance as diffuse
 
for i = 1:5
  umat3(i,i) = .01;
  // overwrite diffuse priors with informative prior
end
 
 
lres = theil(rvec,rmat,umat1,'endo','exo')
 
mres = theil(rvec,rmat,umat2,'endo','exo')
 
tres = theil(rvec,rmat,umat3,'endo','exo')
 
 
 
endfunction
