function rqreg=qreg_d()

global GROCERDIR 

load(GROCERDIR+'\data\qreg_d.dat')

france_clim_t=m2q((france_clim_c+lagts(france_clim_c)+lagts(2,france_clim_c))/3,2)
france_clim_nl=delts(france_clim_t)*abs(delts(france_clim_t))

rols=ols('growthr(FRA_GDP)','const','france_clim_t','france_clim_nl')

GDP_f=res2ts(rols,'yhat')
rqreg=qreg('growthr(FRA_GDP)',[0.05;0.95],'const','france_clim_t','france_clim_nl')

GDP=res2ts(rqreg,'y');
x=rqreg('x');
bet=rqreg('beta');
bound=rqreg('bounds');
lower=reshape(x*bet(:,1),bound(1))
upper=reshape(x*bet(:,2),bound(1))
pltseries('GDP','GDP_f','lower','upper','color=[1;6;2;2]','title=growth rate of GDP: observed, forecasted and 5% confidence band','legend=GDP;forecasted;5% lower band;95% upper band' )
    
endfunction
