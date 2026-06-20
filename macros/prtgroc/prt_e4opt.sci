function prt_e4opt(r)
 
E4OPTION=r('E4OPTION')
write(%io(2),'*********************** E4 Options set by user ********************','(a)');
if E4OPTION(1)==1 then
  s1 = 'KALMAN';
else
  s1 = 'CHANDRASEKHAR';
end
 
if E4OPTION(2)==1 then
  s2 = 'YES';
else
  s2 = 'NO';
end
 
select E4OPTION(3)
case 1 then
  s3 = 'LYAPUNOV';
case 2 then
  s3 = 'ZERO';
case 3 then
  s3 = 'DJONG';
else
  s3 = 'IDEJONG';
end
 
select E4OPTION(4)
case 1 then
  s4 = 'u0 = EXOGENOUS MEAN';
case 2 then
  s4 = 'MAXIMUM LIKELIHOOD';
case 3 then
  s4 = 'ZERO';
case 4 then
  s4 = 'u0 = EXOGENOUS FIRST VALUE (u1)';
else
  s4 = 'AUTOMATIC SELECTION';
end
 
if E4OPTION(5)==1 then
  s5 = 'FACTOR';
else
  s5 = 'VARIANCE';
end
 
if E4OPTION(6)==1 then
  s6 = 'BFGS';
else
  s6 = 'NEWTON';
end
 
if E4OPTION(10)==1 then
  s10 = 'YES';
else
  s10 = 'NO';
end
 
write(%io(2),'Filter. . . . . . . . . . . . . : '+s1,'(a)');
write(%io(2),'Scaled B and M matrices . . . . : '+s2,'(a)');
write(%io(2),'Initial state vector. . . . . . : '+s4,'(a)');
write(%io(2),'Initial covariance of state v.  : '+s3,'(a)');
write(%io(2),'Variance or Cholesky factor . : '+s5,'(a)');
write(%io(2),'Optimization algorithm. . . . . : '+s6,'(a)');
write(%io(2),'****************************************************************','(a)');
write(%io(2),' ','(a)');
write(%io(2),' ','(a)');
 
endfunction
