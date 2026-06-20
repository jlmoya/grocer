function []=logt_d()
 
// PURPOSE: demo of logistic distribution functions
//          prints mean and variance of 1000 draws
//          plots pdf,cdf,inverse
//
 
 
n = 1000;
//
 
tst = logt_rnd(n,1);
 
// mean should equal 0
write(%io(2),'mean should = '+string(0),'(a)');
 
write(%io(2),'mean of draws = '+string(mean(tst)),'(a)');
//
//
tst = unif_rnd(n,-5,5);
 
tsort=gsort(tst,'g','i')
//
pdf = logt_pdf(tsort);
mtlb_plot(tsort,pdf);
xtitle('logistic pdf over -5 to 5',' ',' ');
halt();
//
cdf = logt_cdf(tsort);
mtlb_plot(tsort,cdf);
xtitle('logistic cdf over -5 to 5',' ',' ');
halt();
//
tst = rand(n,1,'u');
tsort=gsort(tst,'g','i')
//
x = logt_inv(tsort);
mtlb_plot(tsort,x);
xtitle('logistic quantiles',' ',' ');
//
endfunction
