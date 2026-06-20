function [AR,ARS,MA,MAS,V]=transf_arma(AR,ARS,MA,MAS,V)
 
corrv_ar=1
corrv_ars=1
corrv_ma=1
corrv_mas=1
 
if ~isempty(strindex(AR0,'=')) & ~isempty(strindex(AR0,'<')) then
   [AR,corrv_ar]=transf_roots(AR)
end
if ~isempty(strindex(ARS0,'=')) & ~isempty(strindex(AR0,'<')) then
   [ARS,corrv_ars]=transf_roots(ARS)
end
if ~isempty(strindex(MA0,'=')) & ~isempty(strindex(MA0,'<')) then
   [MA,corrv_ma]=transf_roots(MA)
end
if ~isempty(strindex(MAS0,'=')) & ~isempty(strindex(MAS0,'<')) then
   [MAS,corrv_mas]=transf_roots(MAS)
end
V=sqrt(V*corrv_ar*corrv_ars/corrv_ma/corrv_mas)
 
endfunction
