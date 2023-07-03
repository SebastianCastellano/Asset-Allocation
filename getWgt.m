function [ wgt ] = getWgt( chrom_S, chrom_Z, LowUpBound )
%Restituisce vettore di pesi partendo dai cromosomi e dai vincoli
%  
% chrom_S cromosoma con percentuale ptf libero attribuita al titolo;
% comprende costi nel primo elemento
% chrom_Z cromosoma con selezione titoli; comprende costi (sempre 1)
% LowUpBound due colonne con epsilon e delta; comprende costi

if sum(LowUpBound(:,1))>1 || sum(LowUpBound(:,2))<1
    msgID = 'getWgt';
    msg = 'Admissible space empty.';
    baseException = MException(msgID,msg);
    throw(baseException)
end
chrom_Z=logical(chrom_Z);
wgt=chrom_Z.*(LowUpBound(:,1)+chrom_S.*(1-sum(LowUpBound(chrom_Z,1)))/sum(chrom_S(chrom_Z)));
atUBound=zeros(length(chrom_Z),1);
aboveUBound=wgt>LowUpBound(:,2);
c=0;
while any(aboveUBound) && c<100
    atUBound(aboveUBound)=true;
    wgt=chrom_Z.*(LowUpBound(:,1)+chrom_S.*(1-sum(LowUpBound(chrom_Z & ~atUBound,1))-sum(LowUpBound(chrom_Z & atUBound,2)))/sum(chrom_S(chrom_Z & ~atUBound)));
    wgt(chrom_Z & atUBound)=LowUpBound(chrom_Z & atUBound,2);
    aboveUBound=wgt>LowUpBound(:,2) & ~atUBound;
    c=c+1;
end

end

