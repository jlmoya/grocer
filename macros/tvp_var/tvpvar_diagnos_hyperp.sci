function tvpvar_diagnos_hyperp(res,nautocor)
 
// PURPOSE: prints the results of tvp_var diagnostics for
// matrices Q, S, W and Sigma(t) and plots the corresponding
// results
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list from a tvp_var diagnos call
// * nautocor = the order of autocorrelation
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on screen and graphed
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
 
 
M=size(res('y'),2)
K = M+res('nlag')*(M^2);
t=res('nobs')
 
res_Q=tvp_var_diagnos(res,'Q','nautocor='+string(nautocor))
res_S=tvp_var_diagnos(res,'S','nautocor='+string(nautocor))
res_W=tvp_var_diagnos(res,'W','nautocor='+string(nautocor))
res_Sigmat=tvp_var_diagnos(res,'Sigmat','nautocor='+string(nautocor))
 
autocorr_Q=res_Q('autocorrelation')
autocorr_S=res_S('autocorrelation')
autocorr_W=res_W('autocorrelation')
autocorr_Sigmat=res_Sigmat('autocorrelation')
//M=res('nendo')
 
ndata2graph=K*(K+1)/2+M*(M-1)*(M+1)/6+M*(M+1)/2+t*M
data_graph1=zeros(ndata2graph,1)
data_graph1(1:K*(K+1)/2)=vech(autocorr_Q(1))
last_index=K*(K+1)/2
autocorr_S1=autocorr_S(1)
for i=1:M-1
   data_graph1(last_index+[1:i*(i+1)/2])=vech(autocorr_S1([i*(i-1)/2+1:i*(i+1)/2],[i*(i-1)/2+1:i*(i+1)/2]))
   last_index=last_index+i*(i+1)/2
end
data_graph1(last_index+[1:M*(M+1)/2])=vech(autocorr_W(1))
data_graph1(last_index+M*(M+1)/2+1:$)=vec(autocorr_Sigmat(1))
 
pltseries0(data_graph1,0,'20th-autocorelation of Q, S and W draws',string([1:ndata2graph]'),max(winsid())+1)
 
resg_Q=res_Q('Geweke tests')
resg_S=res_S('Geweke tests')
resg_W=res_W('Geweke tests')
resg_Sigmat=res_Sigmat('Geweke tests')
 
ndata2graph=K*(K+1)/2+M*(M-1)*(M+1)/6+M*(M+1)/2+t*M
data_graph1=zeros(ndata2graph,1)
data_graph1(1:K*(K+1)/2)=vech(resg_Q('tapered inefficiency factor'))
last_index=K*(K+1)/2
resg_S4graph=resg_S('tapered inefficiency factor')
for i=1:M-1
   data_graph1(last_index+[1:i*(i+1)/2])=vech(resg_S4graph([i*(i-1)/2+1:i*(i+1)/2],[i*(i-1)/2+1:i*(i+1)/2]))
   last_index=last_index+i*(i+1)/2
end
data_graph1(last_index+[1:M*(M+1)/2])=vech(resg_W('tapered inefficiency factor'))
data_graph1(last_index+M*(M+1)/2+1:$)=vec(resg_Sigmat('tapered inefficiency factor'))
 
pltseries0(data_graph1,0,'Inefficiency factors of Q, S and W draws',string([1:ndata2graph]'),max(winsid())+1)
 
resrl_Q=res_Q('Raftery tests')
resrl_S=res_S('Raftery tests')
resrl_W=res_W('Raftery tests')
resrl_Sigmat=res_Sigmat('Raftery tests')
 
ndata2graph=K*(K+1)/2+M*(M-1)*(M+1)/6+M*(M+1)/2+t*M;
data_graph1=zeros(ndata2graph,1);
data_graph1(1:K*(K+1)/2)=vech(resrl_Q(('# of draws for required accuracy')));
 
last_index=K*(K+1)/2;
resrl_S4graph=resrl_S('# of draws for required accuracy');
for i=1:M-1
   data_graph1(last_index+[1:i*(i+1)/2])=vech(resg_S4graph([i*(i-1)/2+1:i*(i+1)/2],[i*(i-1)/2+1:i*(i+1)/2]));
   last_index=last_index+i*(i+1)/2;
end
data_graph1(last_index+[1:M*(M+1)/2])=vech(resrl_W('# of draws for required accuracy'));
data_graph1(last_index+M*(M+1)/2+1:$)=vec(resrl_Sigmat('# of draws for required accuracy'));
 
pltseries0(data_graph1,0,'number of draws needed for standard precision of Q, S and W',string([1:ndata2graph]'),max(winsid())+1)
 
endfunction
