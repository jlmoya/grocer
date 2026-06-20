function y_artificial=msvar_draw(T,nb_endo,nlag,nb_states,switching_V,typemod,y0,trans_prob,Const,CMatrix,sigma)
 
// PURPOSE: produce an artificial Markov switching VAR process
// ------------------------------------------------------------
// INPUT:
// * T = a scalar, the # of observations
// * nb_endo = a scalar, the number of endogenous variables
// * nlag = a scalar, the number of lags in the VAR
// * nb_states = a scalar, the number of states
// * switching_V = a scalar, either 1 or the # of states,
//   depending on whether the variance matrix switches or not
// * typemod = either 'const' ('cte') or 'all', depending on
//   whether the VAR model should have only the constant or
//   all coefficients in the VAR switch
// * y0 = a (nlags x nb_endo) vector of starting values for the
//   endogenous variables in the VAR
// * trans_prob = a (nb_states x nb_states) matrix of
//   transition probabilities
// * Const = a (nb_endo x nb_states) matrix of constant
//   coefficients
// * Cmatrix = either a (nb_endo x (nlag*nb_endo) x nb_states)
//   or (nb_endo x (nlag*nb_endo)) matrix of coefficients non
//   constant coefficients, depending on whether the non
//   constant coefficients switch or not
// * sigma = either a (nb_endo x (nlag*nb_endo) x nb_states)
//   or (nb_endo x (nlag*nb_endo)) matrix of coefficients non
//   constant coefficients, depending on whether the non
//   constant coefficients switch or not
// ------------------------------------------------------------
// OUTPUT:
// * y_artificial = a (T x nb_endo) matrix of artifical values
//   drawn from the Markov-switching model given as an input
// ------------------------------------------------------------
// Copyright: Eric Dubois - Stefan Fiesel 2015
// http://grocer.toolbox.free.fr/grocer.html
 
states=zeros(T,1)
resid =zeros(nb_endo,T)
y_artificial=[y0 ; zeros(T,nb_endo)]
 
z = grand(1,T+1,'def');
p=cumsum(trans_prob)
states(1)=sum(z(1)>p)+1
 
// draw residuals based on state
if switching_V == nb_states then
   resid(:,1) = grand(1,'mn',zeros(nb_endo,1),sigma(:,:,states(1)));
else
   resid(:,1) = grand(1,'mn',zeros(nb_endo,1),sigma);
end
 
//Create vector of hidden states
for i = 1:T-1
   states(i+1)=sum(z(i+1)>cumsum(trans_prob(:,states(i))))+1
   if switching_V == nb_states then
      resid(:,i+1) = grand(1,'mn',zeros(nb_endo,1),sigma(:,:,states(i+1)));
   else
      resid(:,i+1) = grand(1,'mn',zeros(nb_endo,1),sigma);
   end
end
 
//create artifical history
if and(typemod ~= ['const' ;'cte']) then
   for i = (nlag+1):T+nlag
      y_artificial(i,:) = (Const(:,states(i-nlag)) + CMatrix(:,:,states(i-nlag))*vec(y_artificial(i-1:-1:i-nlag,:)') + resid(:,i-nlag))';
    end
 
else
   for i = (nlag+1):T
      y_artificial(i,:) = (Const(:,states(i-nlag)) + CMatrix*vec(y_artificial(i-1:-1:i-nlag,:)') + resid(:,i-nlag))';
    end
end
 
endfunction
