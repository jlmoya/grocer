function [eqsimpl,reseq_ds]=deriv_eq(reseq,vari)
 
// PURPOSE: provide the derivative of a function with respect
// to a variable x
// ------------------------------------------------------------
// INPUT:
// * reseq = an 'equation' tlist, the result of the breaking
//  down of an equation into elementary bricks
// * vari = a string, the name of a variable
// ------------------------------------------------------------
// OUTPUT:
// * eqsimpl = the resulting symbolic derivative
// * reseq_ds = the corresponding tlist collecting the
//   structure of the derivative
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012-2015
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR;
load(GROCERDIR+'\param\symb_listfunc.dat')
 
reseq_d=deriv_eq1(reseq,vari)
// provides some simplifications
reseq_ds=simplify_eq(reseq_d)
// transform the tlist into the text of the equation
eqsimpl=rebuild_eq(reseq_ds)
eqsimpl=strsubst(eqsimpl,'*',' .*')
eqsimpl=strsubst(eqsimpl,'. .*',' .*')
eqsimpl=strsubst(eqsimpl,'/',' ./')
eqsimpl=strsubst(eqsimpl,'. ./',' ./')
eqsimpl=strsubst(eqsimpl,'^',' .^')
eqsimpl=strsubst(eqsimpl,'. .^','.^')
eqsimpl=strsubst(eqsimpl,'--','+')
 
 
endfunction
