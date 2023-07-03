function [ costs ] = getTransactionCosts( currentWgt, nextPopWgt, pctFee)
%Calcolo costi di transazione
%
%currentWgt - vettore dei pesi iniziali
%nextPopWgt - matrice della popolazione di pesi, un individuo per colonna
%pctFee - percentuale costi di transazione

costs=sum(abs(currentWgt(2:end)*ones(1,size(nextPopWgt,2))-nextPopWgt(2:end,:)),1)*pctFee;
end

