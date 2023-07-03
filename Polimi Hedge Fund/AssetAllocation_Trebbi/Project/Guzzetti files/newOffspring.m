function [ chromS, chromZ ] = newOffspring( popS, popZ, fit,pMut,KSel)
%Genera un nuovo individuo partendo dai cromosomi della popolazione
%corrente
%
%popS - cromosomi S, un individuo per colonna
%popZ - cromosomi Z, un individuo per colonna
%fit - vettore che contiene il fit di ciascun individuo
%pMut - probabilità di mutazione
%KSel - numero di titoli nel portafoglio


%randomly select two couples of parents
t=randsample(size(popS,2),4);
t1=t(1:2);
t2=t(3:4);

% for each couple select the best fit and discard the other
p1=t1(fit(t1)==max(fit(t1)));
p2=t2(fit(t2)==max(fit(t2)));
if length(p1)>1 
    p1=p1(1);
end
if length(p2)>1 
    p2=p2(1);
end

% uniform crossover
selS=rand(size(popS,1),1);
selZ=rand(size(popZ,1),1);

chromS=popS(:,p1);
chromS(selS<0.5)=popS(selS<0.5,p2);

chromZ=popZ(:,p1);
chromZ(selZ<0.5)=popZ(selZ<0.5,p2);


% mutation: increase each of the S cells with probability pMut
selM=rand(size(popS,1),1);
chromS(selM<pMut/2)=chromS(selM<pMut/2)+selM(selM<pMut/2);
chromS(selM>(1-pMut/2))=chromS(selM>(1-pMut/2))+1-selM(selM>(1-pMut/2));

% selZ=rand();
% if selZ<pMut
%     idx=randsample(length(chromZ),1);
%     chromZ(idx)=~chromZ(idx);
% end

%enforce the constraint on the number of selected stocks
if sum(chromZ)>KSel+1
    toChange=randsample(sum(chromZ)-1,sum(chromZ)-KSel-1);
    idx=find(chromZ(2:end))+1;
    chromZ(idx(toChange))=false;
end


end

