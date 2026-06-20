function rolsrw = olsrw(y,x,sratio)
// calcul de ols sur modèle en différences pour tenir compte
//  de la présence d'une marche aléatoire dans les résidus 

n = size(y,1) 
dy = tdiff(y,1) ; dy = trimr(dy,1,0) 
dx = tdiff(x,1) ; dx = trimr(dx,1,0)
n = n-1
if isempty(search_cte(dx)) & sratio ~= 0 then 
   dx = [dx , sratio^2*ones(n,1)]
end
	
rolsrw = ols2(dy,dx)	
llike = (-n/2)*log(2*%pi)-(n/2)*log(rolsrw('sigu')/n) - (n/2)		// vraisemblance 

rolsrw(1)($+1) = 'like'
rolsrw('like') = llike

endfunction
