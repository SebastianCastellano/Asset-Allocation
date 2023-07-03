clear all
load('sp5h.mat')

countMax=60000; %massimo numero di generazioni senza miglioramento fit
NOff=300000; % massimo numero generazioni
lambda=1.00; % in [0,1]; 1 min TE; 0 max ER
pMut=0.02; % probabilità mutazione, impatta anche ampiezza mut.
thresh=0.000001; % soglia sotto la quale il fit viene considerato uguale
threshUnfit=0.0001; % soglia sotto la quale l'unfit è considerato accettabile

NStock=10; % numero di titoli universo
NPop=100; % numerosità popolazione iniziale
KSel=10; % numero di titoli da selezionare
fee=0.003; % pct fee

epsilon=ones(NStock+1,1)*0; % limite inferiore ai pesi
delta=1*ones(NStock+1,1); % limite superiore ai pesi
%delta(1)=0.001;

%estrazione dati e generazione pesi correnti
sp5=stx50(5001:6500,1:NStock);
currentWgt=zeros(NStock+1,1);
currentWgt(1+randsample(NStock,KSel))=rand(KSel,1);
currentWgt=currentWgt./(ones(1+NStock,1)*sum(currentWgt));

% rendimento indice sintetico
wgtIdx=exp(-0.2*(1:NStock))';
wgtIdx=wgtIdx/sum(wgtIdx);
% bar(wgtIdx);
rendIdx=sp5*wgtIdx;


% popolazione iniziale
pop=zeros(NStock+1,NPop); %costi in posizione 1
sel=zeros(NStock+1,NPop);
sel(1,:)=true;
for i=1:NPop    
    sel(1+randsample(NStock,KSel),i)=true;    
end
pop(logical(sel(:)))=rand((KSel+1)*NPop,1);
pop=pop./(ones(NStock+1,1)*sum(pop,1));

%bar(pop', 'stacked')

% valutazione
[fit, unfit, popWgt]=evaluate(currentWgt, pop, sel, sp5, rendIdx, fee,lambda,[epsilon delta]);

fitMem=min(fit(unfit<threshUnfit)); % ricorda l'ultimo minimo fit registrato
fitCount=0; % conta il numero di generazioni che non migliorano il fit

fitHistory=zeros(1,NOff); % memorizza i minimi

newMin=0;
for i=1:NOff
    %nuovo individuo
    [offCS,offCZ]=newOffspring(pop,sel,fit,pMut,KSel);
    [offFit,offUnfit,offWgt]=evaluate(currentWgt, offCS,offCZ, sp5, rendIdx, fee,lambda,[epsilon delta]);

    %sostituzione
    
    %Se unfit è entro tolleranza usa solo il criterio del fit
    idx= false(1,NPop);
    if offUnfit<threshUnfit
        %if max(fit)>offFit
            idx=fit==max(fit);
        %end
    else        
        %trova individuo con fit massimo tra quelli con unfit maggiore.
        idx(unfit>=offUnfit)=(fit(unfit>=offUnfit)==max(fit(unfit>=offUnfit)));
        if all(~idx)
            %trova individuo con fit massimo tra quelli con unfit minore 
            idx(unfit<offUnfit)=(fit(unfit<offUnfit)==max(fit(unfit<offUnfit)) & fit(unfit<offUnfit)>=offFit);    
        end
    end
    % gestisce caso di più titoli selezionati
    if sum(idx)>1
        midx=find(idx);
        idx(midx(2:end))=false;
    end
    % se l'indice non è vuoto aggiorna i dati della popolazione

    if any(idx)
        pop(:,idx)=offCS;
        sel(:,idx)=offCZ;
        popWgt(:,idx)=offWgt;
        fit(idx)=offFit;
        unfit(idx)=offUnfit;
    end

    newMin=min(fit(unfit<threshUnfit));
    %aggiorna memoria e check per convergenza
    if ~isempty(newMin) && ~isempty(fitMem)    
        if fitMem-newMin<thresh
            fitCount=fitCount+1;
            if fitCount>countMax
                break
            end
        else
            fitCount=0;
        end
    end
    fitMem=newMin;
    if isempty(fitMem)
        fitHistory(i)=0;
    else        
        fitHistory(i)=fitMem;
    end
end

%mostra pesi: output ottimizzazione, ottimi, iniziali
idxUnfit=unfit<threshUnfit;
idxFit=(fit==min(fit(idxUnfit)));
idx=find(idxFit,1);

newWgt=popWgt(:,idx);
bar([newWgt [0;wgtIdx] currentWgt])
sum(newWgt)

%controllo costi
sum(abs(currentWgt(2:end)-newWgt(2:end)))*fee - newWgt(1)
unfit(idx)

figure
plot(fitHistory)


