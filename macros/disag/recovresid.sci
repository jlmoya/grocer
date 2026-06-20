function retal = recovresid(retal,ny_prov)

// ------------------------------------------------------------
// Function that recovers the resiudals on the provisional
// years
// ------------------------------------------------------------

hx = retal('x trim aug')
u = retal('resid annu')
s = retal('high freq')

n = size(hx,1)
N = size(retal('y annu'),1)

// récupération de la resid de l'INSEE 
hx_prev = hx(s*N+1:s*N+s*ny_prov,:)
lx_prev = (eye(ny_prov,ny_prov) .*. ones(1,s)) *hx_prev 
u_lrsp = retal('annu prov y') - lx_prev*retal('beta')

ny_resid=ceil((N-s*n)/s)-ny_prov
u_full=[u ; u_lrsp ; u_lrsp($)*retal('rho').^[1:ny_resid]']

// prévision des résidus 
retal(1)($+1) = 'prov resid annu'
retal('prov resid annu') = u_full 

retal = lissquadra(retal,'full') 

endfunction



