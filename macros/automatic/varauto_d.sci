function rmse=varauto_d()
    
load(GROCERDIR+'\data\varauto_d.dat')

gr_PIB=growthr(PIB_7CH);
gr_P3=growthr(P3_D_7CH);
gr_P51=growthr(P51_D_7CH)
gr_P7=growthr(P7_D_7CH)

i1=date2num('2007q1');
i2=date2num('2011q2');
err1=zeros(i2-i1+1,4);
err2=err1;
rmse=zeros(2,4);

for i=i1:i2
   bounds('1977q1',num2date(i,4));
   rvar1=VAR(2,'endo=gr_PIB;gr_P3;gr_P51;gr_P7');
   rfvar1=varf(rvar1,num2date(i+4,4));
   fore1=rfvar1('prev_gr_PIB');
   err1(i-i1+1,:)=series(gr_PIB-fore1)';

   rautov=automatic(2,'estim=var','endo=gr_PIB;gr_P3;gr_P51;gr_P7');
   rvar2=autovar2var(rautov,'final model');
   rfvar2=varf(rvar2,num2date(i+4,4));
   fore2=rfvar2('prev_gr_PIB');
   err2(i-i1+1,:)=series(gr_PIB-fore2)';
end

rmse(1,1)=sqrt(mean0(err1(:,1).^2));
rmse(1,2)=sqrt(mean0(err1(:,2).^2));
rmse(1,3)=sqrt(mean0(err1(:,3).^2));
rmse(1,4)=sqrt(mean0(err1(:,4).^2));
rmse(2,1)=sqrt(mean0(err2(:,1).^2));
rmse(2,2)=sqrt(mean0(err2(:,2).^2));
rmse(2,3)=sqrt(mean0(err2(:,3).^2));
rmse(2,4)=sqrt(mean0(err2(:,4).^2));

mat2prt1_1=['horizon' ; 'standard VAR' ; 'VAR automatically estimated'];
mat2prt1_2='Q'+string(1:4);
mat2prt=[mat2prt1_1 [mat2prt1_2 ;string(rmse)]];
printmat(mat2prt,%io(2))

endfunction
