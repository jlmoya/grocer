function r=olsarma_d()

n=300

x=grand(n,3,'nor',0,1);
u=0.2*grand(n+4,1,'nor',0,1);
v=[u(1:3) ; zeros(n,1)];
for j=1:n
   v(j+3)=0.5*v(j+2)+0.2*v(j+1)+u(j+4)-0.4*u(j+3);
end

y=x*[1;1;1]+v(4:$);
r=olsarma([0 0],0,'y','x')

endfunction
 
