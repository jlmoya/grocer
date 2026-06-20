function prtetalcal(retal)  

// Affichage des résultats des l'étalonnage-calage 
//---------------------------------------------------------

if retal('high freq') == 4 then 
	freqe = 'quarterly'
else 
	freqe = 'monthly'	
end 

out =%io(2)
write(out,'')
write(out,'')
write(out,'*****************************************************************')
write(out,' 	Insee''s disaggregation method')
write(out,' ') 
write(out,'Disagregated variable: '+string(retal('namey')))
write(out,'High level frequency: '+freqe)
write(out,' ') 

rho = retal('rho')
const = retal('trend')
if rho == 1
	if const == 1 then 
		write(out,'Model: random walk with drift') 		
	else
		write(out,'Model: random walk without drift') 		
	end 

else 		
	if const == 2 then  
		write(out,'Model with a constant and an AR(1) model for residuals')
		mat2print   = ['Autocorrelation coefficient: ' string(rho) ]
		printmat(mat2print,out) 
	else
		write(out,'Model without constant and an AR(1) model for residuals')
		mat2print   = ['Autocorrelation coefficient: ' string(rho) ]
		printmat(mat2print,out) 
	end 
end 	
write(out,' ') 

mat2print = ['variable' 'coeff.' ' Student' 'p-value'] ; 

bet = retal('beta')
tstat = retal('tstat')
pval = retal('pvalue')
nom = retal('namex') ; 

if const == 1 | const == 2  
	nom = [nom;'const']
end 
	
mat2print  = [mat2print;nom string(bet) string(tstat) string(pval)]
printmat(mat2print,out) 
printsep(out)

endfunction
