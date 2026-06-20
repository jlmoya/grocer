function [matf,puis_f,ind]=ms_coding(mati,nbvar,nbpar)
 
//************************************************************************************//
//** INF_UTIL.PRG: MATRICE DE CODAGE DES INFORMATIONS UTILISABLES                   **//
//************************************************************************************//
//**   1. Le sous-programme principal                                               **//
//**   2. Estimation de la densité et de la fdr par la méthode des noyaux           **//
//**   3. Graphique du codage                                                       **//
//************************************************************************************//
 
//************************************************************************************//
//** 1. Sous-programme principal                                                    **//
//**    en entrée: -fic: le fichier de données contenant les séries,                **//
//**               -nbv: le nb de séries,                                           **//
//**               -nbqua: le nb de quantiles souhaité ainsi que les valeurs        **//
//**    en sortie: -res_code: la matrice de codage de taille (nbqua*nbv,n)       **//
//************************************************************************************//
 
n=size(mati,1);
puis_i=ones(n,1);
reconst=ones(n,1);
 
// date of the first non NA data
ind=1;
while sum(mati(ind,:)) == 0 then
   ind=ind+1
end
 
// Calculation of the power applied to the transition matrices
for i=ind+1:n
   if sum(mati(i-1,:))==0  then
      puis_i(i)=puis_i(i-1)+1;
      reconst(i)=reconst(i-1);
   else
      reconst(i)=reconst(i-1)+1;
   end
end
 
// suppression des dates non utilisables //
matf=[mati miss(sum(mati,'c'),0) puis_i]
matf=packr(matf);
puis_f=matf(:,nbpar(1)*nbvar+2);
matf=matf(:,1:nbpar(1)*nbvar);
 
endfunction
