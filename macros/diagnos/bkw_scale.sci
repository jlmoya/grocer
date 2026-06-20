function [condindex]=bkw_scale(varargin)
 
// PURPOSE: computes and prints BKW colinearity
// variance-decomposition proportions matrix
// ------------------------------------------------------------
// INPUT:
// varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . the string 'dropna' if the user wants to delete NAs
//     (this option should be used when dealing with daily and weekly TS)
// ------------------------------------------------------------
// OUTPUT:
// condindex = the condition number
// ------------------------------------------------------------
// PRINTS:
// the variance-decomposition proportions matrix
// ------------------------------------------------------------
// REFERENCES: Belsley, Kuh, Welsch, 1980 Regression Diagnostics
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
grocer_dropna=%f
grocer_prt=%t
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
   end
end
 
// explode the list of the arguments into the corresponding
// variables and their names
[x,namexos]=explone(varargin,[],'exogenous',%t,grocer_dropna)
[nobs,nx]=size(x)
 
// test presence of a constant
nc = find(sum(x,1)==nobs)
if nc > 0 then
	if nc == 1 then
		x =x(:,2:nx)
	elseif nc > 1
		x =[x(:,1:nc-1) x(:,nc+1:nx)]
	end
	// scale x data
	stx = ((nobs-1)^0.5)*st_dev(x,1)
	stx = matmul(ones(nobs,nx-1),stx)
	x = [x./stx ones(nobs,1)]
 
else
	stx = ((nobs-1)^0.5)*st_dev(x,1)
	stx = matmul(ones(nobs,nx),stx)
	// scale x data
	x = x./stx
end
 
[u,d,v] = svd(x,'e');
 
lamda = diag(d(1:nx,1:nx));
lamda2 = lamda .* lamda;
v = v .* v;
 
phi = zeros(nx,nx);
for i = 1:nx
  phi(i,:) = v(i,:) ./ lamda2';
end
 
 
pi = ones(nx,nx);
for i = 1:nx
  phik = sum(phi(i,:))
  pi(i,:) = phi(i,:)/phik;
end
 
// BUG fix suggested by
// John P. Burkett <burkett@uriacc.uri.edu
lmax = lamda(1);
lmaxvec = lmax*ones(nx,1);
lout = lmaxvec ./ lamda;
 
if grocer_prt then
  write(%io(2),' Belsley, Kuh, Welsch Variance-decomposition (in %)','(a)');
  write(%io(2),' ','(a)')
 
  mat2print=['K(x)']
  for i=1:nx
     mat2print = [mat2print string(round(lout(i)))]
  end
 
  for i=1:nx
     row2print = [namexos(i)]
     for j=1:nx
       row2print = [row2print string(round(pi(i,j)*100))]
     end
     mat2print = [mat2print ; row2print]
  end
 
  printmat(mat2print,%io(2))
end
condindex=round(lout(nx))
 
endfunction
