function pltspectral(res,pspec,pcospe,pdcorr,pphase,pcoher,pcohes,pboot)
 
// PURPOSE: plot results of spectral analysis
// ------------------------------------------------------------
// INPUT:
// * res= results tlist from the function spectral
// * pspec = 1 if the user wants to print the spectrum of all
//   variables
// * pcospe = 1 if the user wants to print the cospectrum of all
//   variables
// * pdcorr = 1 if the user wants to print the dynamic
//   correlation of the variables
// * pphase = 1 if the user wants to print the phase spectrum
// * pcoher = 1 if the user wants to print the dynamic
//   coherency of the variables
// * pcohes = 1 if the user wants to print the cospectrum of all
//   variables
// * pcospe = 1 if the user wants to print the cohesion of the
//   variables
// * pboot = 1 if the user wants to plot the confidence bands
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted on graphic windows
// ------------------------------------------------------------
// NOTES:
// used by the following function: spectral()
// ------------------------------------------------------------
// Copyright E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
vers=convstr(getversion())
load(GROCERDIR+'/param/param_g.dat')
 
cospe = res('cospe')
dcorr = res('dcorr')
phase = res('phase')
coher = res('coher')
cohes = res('cohes')
pln = res('order')
 
if pboot == 1 then
	udcorr = res('udcorr')
	ldcorr	= res('ldcorr')
 
	ucoher = res('ucoher')
	lcoher	= res('lcoher')
	
	uphase = res('uphase')
	lphase	= res('lphase')
 
	ucospe = res('ucospe')
	lcospe	= res('lcospe')
 
	ucohes = res('ucohes')
	lcohes	= res('lcohes')
end
 
 
ncospe =size(cospe,2)
namex = res('namex')
N = size(namex,1)
omega = (0:%pi/64:%pi)'
 
// plot spectral density
if pspec == 1 then
    ng=scf() // create a new window
 
	intn = int(sqrt(N))+1
	subplot(intn,intn,1)
    g=gca()
    g.font_size=12
	
	titlepage("Spectrum")
	if pboot ~= 1 then
		for i =1:N
			subplot(intn,intn,i+1)	
			plot2d(omega,cospe(:,i))
			titl=namex(i)
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
		end
	else
		for i =1:N
			subplot(intn,intn,i+1)	
			plot2d(omega,[cospe(:,i) ucospe(:,i) lcospe(:,i)],style=[1,2,2],...
						leg="Spectrum@95% confidence band")
			titl=namex(i)
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
		end
	end
end
 
if N >= 2 then
	intn = int(sqrt(N*(N-1)/2))+1
	
	// plot cospectrum
	if pcospe ==1 then
		ng=scf() // create a new window
		subplot(intn,intn,1)	
		titlepage("Cospectrum")
		pl = 2
 
		if pboot ~=1 then
			for i=1:N*(N-1)/2
 				subplot(intn,intn,pl)	
				plot2d(omega,[cospe(:,N+i) zeros(65,1)],style=[1,0])
				titl="between "+namex(pln(i,1))+" and "+namex(pln(i,2))
				xtitle(titl)
                f_title=max(1,5-floor(length(titl)/thresh))
                font_title(f_title)
				pl = pl+1
			end
		else
			for i=1:N*(N-1)/2
 				subplot(intn,intn,pl)	
				plot2d(omega,[cospe(:,N+i) ucospe(:,N+i) lcospe(:,N+i) zeros(65,1)],style=[1,2,2,0],...
								leg="Cospectrum@95% confidence band")
				titl="between "+namex(pln(i,1))+" and "+namex(pln(i,2))
				xtitle(titl)
                f_title=max(1,5-floor(length(titl)/thresh))
                font_title(f_title)
				pl = pl+1
			end
		end
	end
	
	//plot coherency
	if pcoher ==1 then
        ng=scf() // create a new window
		subplot(intn,intn,1)	
		titlepage("Squared coherency")
		pl =2
		
		if pboot ~= 1 then
			for i=1:N*(N-1)/2
 				subplot(intn,intn,pl)	
				plot2d(omega,[coher(:,i) zeros(65,1)],style=[1,0])
				titl="between "+namex(pln(i,1))+" and "+namex(pln(i,2))
				xtitle(titl)
                f_title=max(1,5-floor(length(titl)/thresh))
                font_title(f_title)
				pl = pl+1
			end
		else
			for i=1:N*(N-1)/2
 				subplot(intn,intn,pl)	
				plot2d(omega,[coher(:,i) ucoher(:,i) lcoher(:,i) zeros(65,1)],style=[1,2,2,0],...
							leg="Squared coherency@95% confidence band")
				titl="between "+namex(pln(i,1))+" and "+namex(pln(i,2))
				xtitle(titl)
                f_title=max(1,5-floor(length(titl)/thresh))
                font_title(f_title)
				pl = pl+1
			end
		end
	end
 
	//plot dynamic correlation
	if pdcorr ==1 then
		ng=scf() // create a new window
		subplot(intn,intn,1)	
		titlepage("Dynamic correlation")
		pl =2
		if pboot ~= 1 then
			for i=1:N*(N-1)/2
 				subplot(intn,intn,pl)	
				plot2d(omega,[dcorr(:,i) zeros(65,1)],style=[1,0])
				titl="between "+namex(pln(i,1))+" and "+namex(pln(i,2))
				xtitle(titl)
                f_title=max(1,5-floor(length(titl)/thresh))
                font_title(f_title)
				pl = pl+1
			end
		else
			for i=1:N*(N-1)/2
 				subplot(intn,intn,pl)	
				plot2d(omega,[dcorr(:,i) udcorr(:,i) ldcorr(:,i) zeros(65,1)],style=[1,2,2,0],...
							leg="Dynamic correlation@95% confidence band")
				titl="between "+namex(pln(i,1))+" and "+namex(pln(i,2))
				xtitle(titl)
                f_title=max(1,5-floor(length(titl)/thresh))
                font_title(f_title)
				pl = pl+1
			end
		end
	end
 
	if pcohes ==1 then
		ng=scf() // create a new window
		pl =2
		legs = "Cohesion"
		for i=1:N*(N-1)/2
			junk = "@Dyn. corr. between "+namex(pln(i,1))+" - "+namex(pln(i,2))
			legs = joinstr(legs,junk,'')
			pl = pl+1
		end
		if pboot ~=1 then
			plot2d(omega,[cohes dcorr zeros(65,1)],style=[1:N*(N-1)/2+1 0],leg=legs)
			titl="Cohesion and dynamic correlations"
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
		else
            g=gca()
            g.font_size=6
 
			plot2d(omega,[cohes ucohes lcohes zeros(65,1)],leg=legs,style=[1,2,2,0],...
							leg="Cohesion@95% confidence band")
			titl="Cohesion and 95% confidence band for cons"
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
   		 end
	end			
	
 
	// plot phase spectrum
	if pphase == 1 then
		
		ng=scf() // create a new window
 
		subplot(intn,intn,1)	
		titlepage(["Standardised phase spectrum";"leads (+) - lags (-)"])
		pl =2
 
		if pboot ~= 1 then
			for i=1:N*(N-1)/2
 				subplot(intn,intn,pl)	
				plot2d(omega(2:65),[phase(2:65,i)./omega(2:65) zeros(64,1)],style=[1,0])
				titl=["between "+namex(pln(i,1))+" and "+namex(pln(i,2))]
				xtitle(titl)
        if vers ~= 'scilab-3.0' then
           f_title=max(1,5-floor(length(titl)/thresh))
           font_title(f_title)
        end
				pl = pl+1
			end
		else
			for i=1:N*(N-1)/2
 				subplot(intn,intn,pl)	
				plot2d(omega(2:65),[phase(2:65,i)./omega(2:65)  uphase(2:65,i)./omega(2:65)  lphase(2:65,i)./omega(2:65)  zeros(64,1)],style=[1,2,2,0],...
								leg="Phase spectrum@95% confidence band")
				titl=["between "+namex(pln(i,1))+" and "+namex(pln(i,2))]
				xtitle(titl)
                f_title=max(1,5-floor(length(title)/thresh))
                font_title(f_titl)
				pl = pl+1
			end
		end
	end
 
else
 
	// plot cospectrum
	if pcospe ==1 then
		ng=scf() // create a new window
 
		if pboot ~= 1 then
			plot2d(omega,[cospe(:,3) zeros(65,1)],style=[1,0])
			titl="Cospectrum between "+namex(1)+" and "+namex(2)
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
		else
			plot2d(omega,[cospe(:,3) ucospe(:,3) lcospe(:,3) zeros(65,1)],style=[1,2,2,0],...
						leg="Cospectrum@95% confidence band")
			titl="Cospectrum between "+namex(1)+" and "+namex(2)
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
		end
	end
		
	// plot coherency
	if pcoher ==1 then
		ng=scf() // create a new window
		
		if pboot ~= 1 then
			plot2d(omega,[coher(:,1) zeros(65,1)],style=[1,0])
			titl="Squared coherency between "+namex(1)+" and "+namex(2)
			xtitle(titl)
            f_title=max(1,5-floor(length(title)/thresh))
            font_title(f_title)
		else
			plot2d(omega,[coher(:,1) ucoher(:,1) lcoher(:,1) zeros(65,1)],style=[1,2,2,0],...
					leg="Squared coherency@95% confidence band")
			titl="Squared coherency between "+namex(1)+" and "+namex(2)
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
		end
			
	end
 
	// plot dynamic correlation
	if pdcorr ==1 then
		ng=scf() // create a new window
		
		if pboot ~= 1 then
			plot2d(omega,[dcorr(:,1) zeros(65,1)],style=[1,0])
			titl="Dynamic correlation between "+namex(1)+" and "+namex(2)
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
 
		else
			plot2d(omega,[dcorr(:,1) udcorr(:,1) ldcorr(:,1) zeros(65,1)],style=[1,2,2,0],...
								leg="Dynamic correlation@95% confidence band")
			titl="Dynamic correlation between "+namex(1)+" and "+namex(2)
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
		end
	end
		
	// plot phase spectrum
	if pphase == 1 then
		ng=scf(ng)
			
		if pboot ~=1 then
			plot2d(omega(2:65),[phase(2:65,1)./omega(2:65)  zeros(64,1)],style=[1,0])
			titl=["Standardised phase spectrum between "+namex(1)+" and "+namex(2);"leads (+) - lags (-) "]
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
		else
			plot2d(omega(2:65),[phase(2:65,1)./omega(2:65)  uphase(2:65,1)./omega(2:65)  lphase(2:65,1)./omega(2:65)  zeros(64,1)],...
							style=[1,2,2,0],leg="Phase spectrum@95% confidence band")
			titl=["Standardised phase spectrum between "+namex(1)+" and "+namex(2);...
						"leads (+) - lags (-) "]
			xtitle(titl)
            f_title=max(1,5-floor(length(titl)/thresh))
            font_title(f_title)
		end
	end
end
endfunction
