function [ fitness, unfitness, nextPopWgt] = evaluate( currentWgt, nextPopCS, nextPopCZ, stockRet, indexRet, pctFee,lambda, lowUpBound)
%restituisce fitness e unfitness della popolazione e il vettore di pesi
%della popolazione
%
%Il primo elemento dei cromosomi e del vettore dei vincoli fa riferimento
%ai costi di transazione
%currentWgt - vettore dei pesi iniziali
%nextPopCS - matrice dei cromosomi S, un individuo per colonna
%nextPopCZ - matrice dei cromosomi Z, un individuo per colonna
%stockRet - matrice dei rendimenti dei titoli, periodi temporali sulle
%righe
%indexRet - vettore dei rendimenti dell'indice da replicare
%pctFee - costi di transazione in percentuale
%lambda - parametro della funzione obiettivo
%lowUpBound - matrice con vincoli di peso inferiore e superiore nella prima
%e seconda colonna rispettivamente

nextPopWgt=zeros(size(nextPopCS));
for i=1:size(nextPopWgt,2)
    nextPopWgt(:,i)=getWgt(nextPopCS(:,i),nextPopCZ(:,i),lowUpBound);
end
fitness=objFun(nextPopWgt,stockRet, indexRet,lambda);
c=getTransactionCosts( currentWgt, nextPopWgt, pctFee);
unfitness=abs(c-nextPopWgt(1,:));


end

