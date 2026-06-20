function res=varwithfac_d()


u=grand(250,1,'nor',0,1);
v=grand(250,3,'nor',0,1);
f=zeros(251,1);
y1=zeros(251,1);
y2=zeros(251,1);
y3=zeros(251,1);

for i=2:250
   f(i+1)=0.9*f(i)+u(i);
   y1(i+1)=-0.2*y1(i-1)+0.7*y1(i)+0.1*y2(i)+0.1*y3(i)+0.02*f(i+1)+0.01*v(i,1);
   y2(i+1)=-0.3*y2(i-1)+0.4*y1(i)+0.4*y2(i)+0.015*f(i+1)+0.01*v(i,2);
   y3(i+1)=-0.2*y3(i-1)+0.4*y1(i)+0.4*y3(i)+0.025*f(i+1)+0.01*v(i,3);
end

y1=reshape(y1(52:251),'2500q1');
y2=reshape(y2(52:251),'2500q1');
y3=reshape(y3(52:251),'2500q1');

bounds()
res=varwithfac(2,['y1';'y2';'y3'],'0.9',[],'optfunc=optim')

endfunction
