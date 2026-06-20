function [rbb1,rbb2]=brybos_d();
 
global GROCERDIR;
 
// Performs Bry-Boschan datation of Pig-Iron serie
// Fig 1. (p. 27) in Mark. W. Watson (1993),
// "Business Cycle Durations and Postwar Stabilization of the U.S. Economy"
// American Economic Review, Vol. 84, n°1, pp. 24-46
 
load(GROCERDIR+'/data/pigiron.dat');
 
bounds()
lpigiron = log(pigiron);
rbb1 = brybos('lpigiron','proc=''bb''');										 // performs Bry-Boschan complete procedure
write(%io(2),'press any key to continue','(a)');
halt();
 
rbb2 = brybos('lpigiron','proc=''hp''','spenc=1'); // performs harding-pagan dating procedure
 
endfunction
