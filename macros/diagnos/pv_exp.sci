////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This file contains two Matlab procedures:
// PV_EXP and EXP_BETA

//     written by

// Bruce E. Hansen
// Department of Economics
// Social Science Building
// University of Wisconsin
// Madison, WI 53706-1393
// bhansen@ssc.wisc.edu
// http://www.ssc.wisc.edu/~bhansen/

// The format for the procedures are

// p = pv_exp(Tn,m,l);
// b = exp_beta(k);

// The documentation follows.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// PV_EXP

// Procedure to compute asymptotic p-values for Andrews-Ploberger
// Exp Test based on approximation used in my paper
// "Approximate Asymptotic P-Values for Structural Change Tests".

// Format:

// p = pv_exp(Tn,m,l);

// Inputs:
// Tn   =  Value of Exp Statistic
// m    =  Number of parameters tested for constancy
//         (degrees of freedom of conventional Chow test)
// l    =  Either the "lambda" or the "pi_0" of Andrews-Ploberger
//     Lambda lies between [1,infinity) and pi_0 between (0,1/2].
//     pi_0 is convenient when the test is constructed using symmetric
//     trimming, and Lambda is convenient when non-symmetric trimming is
//     used.

// Output:
// p    =  Asymptotic p-value of test statistic

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// EXP_BETA

// Procedure to return coefficients for computation of p-value function
// for the Exp test, given degrees of freedom.

// Format:

// beta = exp_beta(k);

// Input:
// k  = degrees of freedom (number of parameters tested for constancy)

// Output:
// beta = 25xg matrix.
//        Each row consists of coefficients for p-value function.
//        The rows correspond to pi_0 indexed from .49 to .01 (decreasing)
//        in steps of .02.  The number of columns, g, depends on k.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function p=pv_exp(tn,k,l);
if l<1
    tau=l;
else
    tau=1/(1+sqrt(l));
end;
if k==1
    m=4;
elseif k==2
    m=3;
elseif k==3
    m=3;
else
    m=2;
end;

global GROCERDIR
load(GROCERDIR+'\data\exp_beta.dat')
execstr('bet=beta_'+string(k));

x=bet(:,1:m)*(tn.^(0:m-1)');
x=x.*(x>0);
pp=1-cdfgam("PQ",x,0.5*bet(:,m+1),0.5*ones(x));

if tau==.5
    p=1-cdfgam("PQ",tn,0.5*k,0.5*ones(k))
elseif tau<=.01
    p=pp(25);
elseif tau>=.49
    p=((.5-tau)*pp(1)+(tau-.49)*(1-cdfgam("PQ",tn,0.5*k,0.5*ones(k))))*100;
else
    taua=(.5-tau+.01)*50;
    tau1=floor(taua);
    p=(tau1+1-taua)*pp(tau1)+(taua-tau1)*pp(tau1+1);
end;

endfunction
