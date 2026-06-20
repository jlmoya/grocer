function [y] = ppnd(p)

// PURPOSE: determines quantiles of the cumulative standard normal
// ------------------------------------------------------------
// USAGE: called by nmin.m and raftery.m
// where: s = probability associated with r
// ------------------------------------------------------------
// NOTES: based on algorithm AS 241 Applied Statistics (1988)
//        Volume 37, no. 3, pp. 477-484
// ------------------------------------------------------------
// REFERENCES: Geweke (1992), `Evaluating the accuracy of sampling-based
// approaches to the calculation of posterior moments'', in J.O. Berger,
// J.M. Bernardo, A.P. Dawid, and A.F.M. Smith (eds.) Proceedings of
// the Fourth Valencia International Meeting on Bayesian Statistics,
// pp. 169-194, Oxford University Press
// Also: `Using simulation methods for Bayesian econometric models: 
// Inference, development and communication'', at: www.econ.umn.edu/~bacc
// -----------------------------------------------------------------

// written by:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu

// NOTE: this code draws heavily on MATLAB programs written by
// Siddartha Chib available at: www.econ.umn.edu/~bacc
// I have repackaged it to make it easier to use.


split1 = 0.425;
split2 = 5;
const1 = 0.180625;
const2 = 1.6;
a0 = 3.3871327179;
a1 = 50.434271938;
a2 = 159.29113202;
a3 = 59.10937472;
b1 = 17.895169469;
b2 = 78.757757664;
b3 = 67.1875636;
c0 = 1.4234372777;
c1 = 2.75681539;
c2 = 1.3067284816;
c3 = 0.17023821103;
d1 = 0.7370016425;
d2 = 0.12021132975;
e0 = 6.657905115;
e1 = 3.081226386;
e2 = 0.42868294337;
e3 = 0.017337203997;
f1 = 0.24197894225;
f2 = 0.012258202635;
q = p-0.5;

if abs(q) <= split1 then
   r = const1-q*q;
   y = q * (((a3*r+a2)*r+a1)*r+a0)/(((b3*r+b2)*r+b1)*r+1.0);
   return;
elseif q < 0 then
   r = p;
else
   r = 1-p
end;// end of if

if r <= 0 then
   y = 0;

else
   r = sqrt(-log(r));

   if r <= split2 then
      r = r - const2;
      y = (((c3*r+c2)*r+c1)*r+c0)/((d2*r+d1)*r+1);
   else
      r = r - split2;
      y = (((e3*r+e2)*r+e1)*r+e0)/((f2*r+f1)*r+1.0);
   end;// end of if; 

   if q < 0 then
      y = -y;
   end;// end of if
end

endfunction
