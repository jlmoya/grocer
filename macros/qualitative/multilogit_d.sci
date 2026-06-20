function results=multilogit_d()
 
 
 
// specify the size of the demo
nobs = 1000;// number of observations
nvar = 15;// number of covariates
numcat = 5;// number of categories
 
// specify the parameter vector
// note the bet vector associated with category 0 is normalized to zero
bet = [zeros(nvar,1),ones(nvar,numcat-1)];
 
// specify the covariates: x must include a column of ones if there
// is a constant term
xmat = rand(nobs,nvar-1,"normal");
x = [ones(nobs,1),xmat];
 
// generate the response variable y
xbet = x*bet;
e = 0.1*rand(nobs,numcat,"normal");
xb = xbet+e;
exp_xb = exp(xb);
sum_exp_xb = sum(exp_xb,'c');
P=exp_xb ./ (sum_exp_xb .*. ones(1,numcat))
cum_P = cumsum(P,"c");
u = rand(nobs,1);
yt = ones(nobs,1)*99;
for i = 1:nobs
  for j = 1:numcat
    if bool2s(u(i,1)<=cum_P(i,j))&bool2s(yt(i,1)==99) then
      yt(i,1) = j;
    end;
  end;
end;
y = yt-ones(nobs,1);// y takes values in (0,1,2,...,numcat-1).entries
 
//---- CALL MULTILOGIT.M AND PRINT RESULTS ----%
 
// call multilogit using default starting values, convergence criterion, and
// maximum iterations
results = multilogit('y','x');
 
endfunction
