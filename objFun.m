function [ fitness ] = objFun( popWgt, stockRet, indexRet,lambda )
% Restituisce il valore della fx obiettivo da minimizzare
%
%popWgt - insieme dei pesi, un individuo per ciascuna colonna
%stockRet - matrice dei rendimenti dei titoli (periodi temporali sulle
%righe)
%indexRet - vettore dei rendimenti dell'indice da replicare
%lambda - parametro della fx obiettivo

Wgt=popWgt(2:end,:)./(ones(size(popWgt,1)-1,1)*sum(popWgt(2:end,:),1));
TE=stockRet*Wgt-indexRet*ones(1,size(Wgt,2));
TEV=std(TE,1);
ER=mean(TE,1);

fitness=lambda*TEV-(1-lambda)*ER;
end

