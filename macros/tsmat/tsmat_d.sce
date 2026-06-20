global GROCERDIR ;

load(GROCERDIR+'/data/bdhenderic.dat')

bounds()
tsmat=ts2tsmat('lm1','ly','lp','rnet','const')
tsmat=ts2tsmat('lm1/1000','ly/1000','lp/1000','rnet/1000','const')
tsmat=ts2tsmat('lm1','ly','lp','rnet','const')
bounds('1963q1','1963q2')
tsmat=ts2tsmat('lm1','ly','lp','rnet','const')
bounds()
 
tsmat=ts2tsmat('lm1','ly','lp','rnet','const','dropna')
ols(tsmat(:,1),tsmat(:,2:$))
 
st=ts2tsmat('1+rnet','const')
st=tsmat.*tsmat
st=tsmat*tsmat
st=tsmat*tsmat-tsmat^2
st=tsmat.*tsmat-tsmat.^2
st=tsmat/tsmat
st=tsmat./tsmat
st=1/tsmat
st=tsmat+lm1
st=tsmat*2-tsmat-tsmat
st=2*tsmat-tsmat-tsmat
st=tsmat/2-0.5*tsmat
st=2/tsmat
stl=lagts(tsmat)
dst=delts(tsmat)
st=tsmat-stl-dst
st=growthr(tsmat)-delts(log(tsmat))
 
st=tsmat/lm1
st=lm1/tsmat
 
st=tsmat>1000*lm1
st=tsmat<1000*lm1
st=tsmat>=1000*lm1
st=tsmat<=1000*lm1
st=tsmat==1000*lm1
st=tsmat~=1000*lm1
 
st=1000*lm1<tsmat
st=1000*lm1>tsmat
st=1000*lm1<=tsmat
st=1000*lm1>=tsmat
st=1000*lm1==tsmat
st=1000*lm1~=tsmat
 
st=tsmat>1000
st=tsmat<1000
st=tsmat>=1000
st=tsmat<=1000
st=tsmat==1000
st=tsmat~=1000
 
st=1000>tsmat
st=1000<tsmat
st=1000>=tsmat
st=1000<=tsmat
st=1000==tsmat
st=1000~=tsmat
 
st=exp(tsmat)
st=sin(tsmat)
st=cos(tsmat)
st=round(tsmat)
st=ceil(tsmat)
st=floor(tsmat)
st=log(tsmat)
st=abs(tsmat)
st=sign(tsmat)
 
st=studentize(tsmat)
st=mean(tsmat,'c')
st=mean(tsmat,'r')
st=st_dev(tsmat,'c')
st=st_dev(tsmat,'r')
st=cumprod(tsmat)
st=cumsum(tsmat)
 
st=subper(tsmat,'1989q1','1989q2')
st=values(tsmat,'1989q1')
 
st_a=q2a(tsmat,3)
st_a=q2a(tsmat,-1)
 
 
