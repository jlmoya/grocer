function [r]=cadf_d()
 
global GROCERDIR;
 
// an example for cadf; note that the results are not exactly
// the same as in James Le Sage book; this is due to the use
// of the function inv by Le Sage, instead of the [q,r]
// decomposition. It is especially true for the adf tests,
// because there is a great amont of multicollinearity
// (see the cond indexes), but it also the case for the cadf
// test (where is the multicollinearity at the first stage
// see it by executing "r=cadf_d();" and then
// "prtuniv(r('cointrel'))"
 
load(GROCERDIR+'/data/datajpl.dat')
write(%io(2),' ')
write(%io(2),'--------------------------------------------------')
write(%io(2),'first test if the variable illinos has a unit root')
write(%io(2),'--------------------------------------------------')
write(%io(2),' ')
adf('illinos',0,6)
 
write(%io(2),' ')
write(%io(2),'-------------------------------------------------')
write(%io(2),'then test if the variable indiana has a unit root')
write(%io(2),'-------------------------------------------------')
write(%io(2),' ')
adf('indiana',0,6)
 
write(%io(2),' ')
write(%io(2),'-----------------------------------------------------------------')
write(%io(2),'lastly test if the variables illinos and indiana are cointegrated')
write(%io(2),'-----------------------------------------------------------------')
write(%io(2),' ')
r=cadf(0,6,'illinos','indiana')
 
endfunction
