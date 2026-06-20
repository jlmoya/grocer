function []=logn_d()
 
// PURPOSE: demo of log-normal distribution functions
//          prints mean and variance of 1000 draws
//          plots pdf,cdf,inverse
//
 
 
 
n = 1000;
a = 10;
b = 2;
 
tst = logn_rnd(a,b,n,1);
 
//
ltst = log(tst);
//
// mean should equal a
write(%io(2),'mean should = '+string(a),'(a)');
 
write(%io(2),'mean of draws = '+string(mean(ltst)),'(a)');
//
// variance should equal b
write(%io(2),'variance should = '+string(b*b),'(a)');
write(%io(2),'variance of draws = '+string(stdev(ltst)^2),'(a)');
//
//
 
tst = unif_rnd(n,.1,3);
tsort=gsort(tst,'g','i')
 
pdf = logn_pdf(tsort);
mtlb_plot(tsort,pdf);
xtitle('log-normal pdf with mean=1, var=1',' ',' ');
halt();
//
 
cdf = logn_cdf(tsort);
mtlb_plot(tsort,cdf);
xtitle('log-normal cdf with mean=1, var=1',' ',' ');
halt();
//
tst = rand(n,1,'u');
tsort=gsort(tst,'g','i')
//
 
x = logn_inv(tsort);
mtlb_plot(tsort,x);
xtitle('log-normal quantiles with mean=1, var=1',' ',' ');
//
endfunction
