function [c,pred] = matagreg(n,N,s) 

//----------------------------------------------------------
//	fonction  permettant calcul des données agrégées 		
//----------------------------------------------------------

// création de la matrice permettant l'agrégation 
c = eye(n,n).*.ones(1,s) 

// ajout de colonnes pour pouvoir extrapoler si nécessaire 
if (N > s*n) then
	c = [c zeros(n,N-s*n)] 
	pred = 1 
else 
	pred = 0 	
end 
endfunction
