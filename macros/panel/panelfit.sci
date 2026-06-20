function panhat = panelfit(res,paneldb)
 
// PURPOSE: Compute the fitted values of a panel regression
// (work with pooled, fixed effect & random effect estimation)
// ------------------------------------------------------------
// INPUT:
// * res     = tlist result of panel estimation
// * paneldb = tlist containing data in panel format
//   (use of tlist as input allows the user to make out-of-sample
//   forecasts by using a database with different time span,
//   cf. paneldb.sci for the construction of a panel tlist)
// ------------------------------------------------------------
// OUTPUT:
// * panhat  = a tlist with
//   . panhat('meth')   ='panel fit'
//   . panhat('yhat')   = matrix of fitted data
//   . panhat('bounds') = bounds of the adjustment
// ------------------------------------------------------------
// E. Michaux & E. Dubois (2006)
// http://grocer.toolbox.free.fr/grocer.html
 
nind = max(size(paneldb('nameid')))
nprev = max(size(paneldb('dates')))/nind
 
// matrix of endogenous & exogenous data
namey = res('namey')
findendo = (paneldb('namex') == res('namey'))
grocer_x = paneldb('x')(:,~findendo)
grocer_y = paneldb('x')(:,findendo)
 
 
// selec estimation method
if res('meth') == 'panel with fixed effects' then
  grocer_bet  = res('beta')(1:$-nind)
  grocer_beti = res('beta')($-nind+1:$)
elseif res('meth') == 'panel with random effects' then
  grocer_bet  = res('beta')(1:$-1)
  grocer_beti = res('beta')($)+res('random effects')
elseif res('meth') == 'panel pooled' then
  grocer_bet  = res('beta')(1:$-1)
  grocer_beti = res('beta')($)*ones(nind,1)
end
 
// creation of the id matrix using the vector index
index = paneldb('id')
[B,ind]=gsort(vec2col(index),'g','d')
dB=[B(2:$)-B(1:$-1) ; 1]
// eliminates the redundant values
binv=B(dB ~= 0)
// take the inverse of binv to obtain the increasing order
uniq=binv($:-1:1)
 
// construct forecasts
grocer_yhat = zeros(nprev,nind)
for i = 1:nind
    id_i=find(index == uniq(i))
    grocer_xf = [grocer_x(id_i,:) ones(nprev,1)]
    grocer_yhat(:,i) = grocer_xf*[grocer_bet;grocer_beti(i)]
end
 
grocer_bounds = [paneldb('dates')(1);paneldb('dates')($)]
grocer_namey  = res('namey')
grocer_nameid = paneldb('nameid')
 
// tlist result
panhat = tlist(['panel fit';'yhat';'bounds';'namey';'nameid'],...
        grocer_yhat,grocer_bounds,grocer_namey,grocer_nameid)
 
 
endfunction
