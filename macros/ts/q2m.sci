function tso=q2m(tsi)
    
f0=tsi('freq')
ser0=tsi('series')
dat0=tsi('dates')
tso=tsi
tso('freq')=12
a1=floor((dat0(1)-1)/4)
q1=dat0(1)-4*a1
a$=floor((dat0($)-1)/4)
q$=dat0($)-4*a$
tso('dates')=[a1*12+3*q1-2:a$*12+3*q$]'
tso('series')=ser0 .*. ones(3,1)

endfunction
