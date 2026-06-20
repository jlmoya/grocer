function panelauto_d()

load(GROCERDIR+'/data/Munnell_testauto.dat')

// pooled data(i.e ols)
automatic('gsp',Munnell_testauto,'estim=ppooled','x=lpcap;private;emp;unemp;const;'+joinstr('rand',string(1:10),';'))

// with "clustered" covariance matrix 
automatic('gsp',Munnell_testauto,'estim=ppooled','x=lpcap;private;emp;unemp;const;'+joinstr('rand',string(1:10),';'),'hac=ccm')

// fixed effects
automatic('gsp',Munnell_testauto,'estim=pfixed','x=lpcap;private;emp;unemp;'+joinstr('rand',string(1:10),';'))

// fixed effects at a looser size, which leads rand3 to be selected
automatic('gsp',Munnell_testauto,'estim=pfixed','x=lpcap;private;emp;unemp;'+joinstr('rand',string(1:10),';'),'alpha=0.1')

// fixed effects with heteroskedasticty and autocorrelation correction
automatic('gsp',Munnell_testauto,'estim=pfixed','x=lpcap;private;emp;unemp;'+joinstr('rand',string(1:10),';'),'hac=ccm')

// random effects
automatic('gsp',Munnell_testauto,'estim=prandom','x=lpcap;private;emp;unemp;'+joinstr('rand',string(1:10),';'))

endfunction
