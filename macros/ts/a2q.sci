function tso=a2q(tsi)
    
f0=tsi('freq')
ser0=tsi('series')
dat0=tsi('dates')
tso=tsi
tso('freq')=4
tso('dates')=[dat0(1)*4+1:dat0($)*4+4]'
tso('series')=ser0 .*. ones(4,1)

endfunction
