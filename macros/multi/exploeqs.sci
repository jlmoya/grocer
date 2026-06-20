function [xall,lx1,ly1,endoeq,nameinst,lindx1,lindy1]=exploeqs(neqs,lexo,endo,z,namez)
 
// PURPOSE: retrieve from the equations the list of endogenous,
// exogenous and instruments for a Two-Stage or Three-Stage
// Least-squares Regression
// ------------------------------------------------------------
// INPUT:
// * neqs = # of equations
// * lexo = list of independent variables in each equation
// * endo = list of dependent variables in each equation
// * z = matrix of values of the dependent variables
// * namez = matrix of names of the dependent variables
// ------------------------------------------------------------
// OUTPUT:
// * xall = matrix of the values of the instruments
// * lx1 = list of the exogenous variables for each equation
// * ly1 = list of the endogenous variables for each equation
// * endoeq = list of he names of the endogenous variables for
//   each equation
// * nameinst = matrix of the names of the instruments
// * lindx1 = list of the indexes of exogenous variables for
//   each equation
// * lindy1 = list of the indexes of endogenous variables for
//   each equation
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
xall=[]
lx1=list()
ly1=list()
lindx1=list()
lindy1=list()
endoeq=list()
nameinst=[]
speccar=['+' '(' '-' '*' '/' ')' '^']
// for each equation look if an independent variable in lexo(i) is
// endogenous
indexo=neqs
for i=1:neqs
  x1=[]
  y1=[]
  indx1=[]
  indy1=[]
  name1=[]
  lexoi=lexo(i)
  for j=1:size(lexoi,1)
    lexoi_j=lexoi(j)
    indexo=indexo+1
    exoi=%t
    for k=1:size(endo,1)
      endo_k=endo(k)
      ind=strindex(lexoi_j,endo_k)
      if size(ind,1) ~= 0 then
        endvar=ind+length(endo_k)-1
        for l=1:size(ind,2)
          if ind == 1 & endvar(l) == length(lexoi_j) then
// the name of the exogenous variable is exactly the name
// of an endogenous variable
            exoi=%f
          elseif ind ~= 1 & endvar(l) ~= length(lexoi_j) then
// check if the string found is not part of a name
            if part(lexoi_j,ind(l)-1) ~= '(' | ...
              part(lexoi_j,endvar(l)+1) ~= ')' then
// the name is between brackets; check if the variable is
// not lagged
              st2=part(lexoi_j,1:ind-1)
              ind2=strindex(st2,'lagts')
              if size(ind2,1) == 0 then
// variable is not lagged
                exoi=%f
              else
                l=size(ind2,2)
                st3=part(st2,ind2(l):ind-1)
                n1=strindex(st3,'(')
                n2=strindex(st3,')')
                if n1 >= n2 then
// variable is not lagged
                  exoi=%f
                end
              end
              if or(speccar == part(lexoi_j,ind(l)-1)) & ...
                 or(speccar == part(lexoi_j,endvar(l)+1)) then
// the name of the variable found is really the name of
// an endogenous variable; check now if it is not
// lagged
                st2=part(lexoi_j,1:ind-1)
                ind2=strindex(st2,'lagts')
                if size(ind2,1) == 0 then
// variable is not lagged
                  exoi=%f
                else
                  l=size(ind2,2)
                  st3=part(st2,ind2(l):ind-1)
                  n1=strindex(st3,'(')
                  n2=strindex(st3,')')
                  if n1 >= n2 then
// variable is not lagged
                    exoi=%f
                  end
                end
              end
            end
          end
        end
      end
    end
    if exoi then
      indx1=[indx1 j]
      x1=[x1 z(:,indexo)]
      [xall,removed]=test_add([xall z(:,indexo)],1e6)
      if ~removed then
         nameinst=[nameinst ; lexoi_j]
      end
    else
      indy1=[indy1 j]
      y1=[y1 z(:,indexo)]
      name1=[name1 ; lexoi_j]
    end
  end
  lx1($+1)=x1
  ly1($+1)=y1
  lindx1($+1)=indx1
  lindy1($+1)=indy1
  endoeq($+1)=name1
end
 
endfunction
