function [r]=tvp_d2()
 
b10=0
b20=0
u1=0.1*grand(100,1,'nor',0,1)
b1t=b10+cumsum(u1)
b2t=b20+2*cumsum(u1)+cumsum(0.2*grand(100,1,'nor',0,1))
xt=grand(100,1,'nor',0,1)
cte=ones(100,1)
yt=xt.*b1t+cte.*b2t+0.2*rand(100,1,'n')
r=tvp('yt','xt','cte','R=0.04','Q=0.1*eye(2,2)','tvpmeth=2')
write(%io(2),['b1' 'b1hat'])
write(%io(2),[b1t r('betas')(:,1)])
// warning: for some draws, the function may not work ; in that case, try again
r=tvp('yt','xt','cte','R=0.04','Q=[0.01 0.02 ;0.02 0.08]','tvpmeth=2a')

endfunction
