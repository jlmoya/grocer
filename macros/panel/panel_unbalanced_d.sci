function panel_unbalanced_d()

load(GROCERDIR+'/panel/Munnellunbal.dat')

// pooled data(i.e ols)
rmun_ppooled=ppooled('log(gsp)',Munnellunbal,'x=log(pcap);log(pc);log(emp);unemp','const')

// fixed effects
rmun_pfixed=pfixed('log(gsp)',Munnellunbal,'x=log(pcap);log(pc);log(emp);unemp')

// fixed effects with heteroskedasticty and autocorrelation correction
rmun_pfixhac=pfixed('log(gsp)',Munnellunbal,'x=log(pcap);log(pc);log(emp);unemp','hac=ccm')

// random effects
rmun_prand=prandom('log(gsp)',Munnellunbal,'x=log(pcap);log(pc);log(emp);unemp')

// Haussman test
phaussman(rmun_pfixed,rmun_prand)

endfunction
