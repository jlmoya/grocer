function []=hypg_d()
 
// PURPOSE: demo of Hypergeometric distribution functions
//          prints mean and variance of 1000 draws
//          plots pdf,cdf,inverse
//
// ------------------------------------------------------------
 
 
 
nobs = 1000;
n = 10;
K = 10;
N = 50;
//
timer();
 
tst = hypg_rnd(nobs,n,K,N);
// mean should equal (n/N)*K
write(%io(2),'mean should   = '+string(n/N*K),'(a)');
write(%io(2),'mean of draws = ',string(mean(tst)),'(a)');
//
hmean = n/N*K;
//
// variance should equal ((nK)/N^2*(N-1))*(N-K)*(N-n)
term1 = n*K;
term2 = N*N*(N-1);
term3 = (N-K)*(N-n);
//
write(%io(2),'variance should = '+string(term1/term2*term3),'(a)');
write(%io(2),'variance of draws = '+string(stdev(tst)^2),'(a)');
//
 
tsort=gsort(tst,'g','i')
 
pdf = hypg_pdf(tsort,n,K,N);
//
mtlb_plot(tsort,pdf);
xtitle('hyperg pdf, mean='+string(hmean),' ',' ');
halt();
//
 
cdf = hypg_cdf(tsort,n,K,N);
mtlb_plot(tsort,cdf);
xtitle('hyperg cdf,  mean='+string(hmean),' ',' ');
halt();
//
tst = rand(n,1,'u');
tsort = gsort(tst,'g','i');
//
 
x = hypg_inv(tsort,n,K,N);
mtlb_plot(tsort,x);
xtitle('hyperg quantiles, mean='+string(hmean),' ',' ');
//
//
//
endfunction
