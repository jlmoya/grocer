function [eq,defJ_j,namex]=reverse_indlagts(eq,namendo,namexo,nameresid,defJ_j,lags,text_replaced,namex)
 
// PURPOSE: in a text where lagts (...) have been replaced
// with grocer_lag1,..., grocer_lagn recover the names of the
// original variable, and indexes them as grocer_date minus
// its lag
// ------------------------------------------------------------
// INPUT:
// * eq = the text of the equation
// * namendo = a string vector, the names of endogenous
//   variables in the model
// * namexo = a string vector, the names of exogenous
//   variables in the model
// * nameresid = a string vector, the names of residual
//   variables in the model
// * defJ_j = the text of the Jacobian associated with the
//   equation
// * lags = a (n x 1) vector, collecting the lag order of each
//   replaced lag text
// * text_replaced = a (n x 1) vector, collecting the original
//   text of the lagged variable or expression
// * namex = a (k x 1) vector, collecting the names of the
//   exogenous variable associated with the coefficients in
//   the equation
// ------------------------------------------------------------
// OUTPUT:
// * eq = the text of the equation, with lagged variables
//   called with index grocer_date minus its lag
// * defJ_j = the text of the Jacobian associated with the
//   equation, with lagged variables called with index
//   grocer_date minus its lag
// * namex = a (k x 1) vector, collecting the names of the
//   exogenous variable associated with the coefficients in
//   the equation, with grocer_lagi replaced with the original
//   text
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2015
// http://grocer.toolbox.free.fr/grocer.html
 
textfin=[]
 
for j=1:size(lags,2)
   textj=text_replaced(j)
   namex=strsubst(namex,'grocer_lag'+string(j)+'_',textj)
   for k=1:size(namexo,1)
      exok=namexo(k)
      if ~isempty(strindex(textj,exok)) then
         [textj,trueobj]=strsubst_trueobj(textj,exok,...
                 exok+'(grocer_date-'+string(lags(j))+')',[' ' ;'=';'+' ;'-';'*';'/';',';'^';'('],...
                 [' ' ;'=';'+' ;'-';'*';'/';' ';'^';')'],%f,%f)
      end
   end
 
   for k=1:size(nameresid,1)
      residk=nameresid(k)
      if ~isempty(strindex(textj,residk)) then
         [textj,trueobj]=strsubst_trueobj(textj,residk,...
                 residk+'(grocer_date-'+string(lags(j))+')',[' ' ;'=';'+' ;'-';'*';'/';',';'^';'('],...
                 [' ' ;'=';'+' ;'-';'*';'/';' ';'^';')'],%f,%f)
      end
   end
 
   for k=1:size(namendo,1)
      endok=namendo(k)
      if ~isempty(strindex(textj,endok)) then
         [textj,trueobj]=strsubst_trueobj(textj,endok,...
                     endok+'(grocer_date-'+string(lags(j))+')',[' ' ;'=';'+' ;'-';'*';'/';',';'^';'('],...
                    [' ' ;'=';'+' ;'-';'*';'/';' ';'^';')'],%f,%f)
      end
   end
 
   for m=j+1:size(lags,2)
      if ~isempty(strindex(textj,'grocer_lag'+string(m)+'_')) then
      // the lag # m is encapsulated in lag # j:
      // add the lag j to the lag m to obtain the final lag
         lags(m)=lags(m)+lags(j)
      end
   end
 
   comma=strindex(textj,',')
   textj='('+part(textj,comma(1)+1:length(textj))
   textfin=[textfin ; textj]
   eq=strsubst(eq,'grocer_lag'+string(j)+'_',textj)
   defJ_j=strsubst(defJ_j,'grocer_lag'+string(j)+'_',textj)
end
 
endfunction
