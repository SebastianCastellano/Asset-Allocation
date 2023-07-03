clear all
load('sp5h.mat')
sp5=stx50(6199:6500,1:10);
% controllo e rimozione outlier
boxplot(sp5)
sp5(sp5(:,7) == min(sp5(:,7)),:) = [];

m=mean(sp5);
S=cov(sp5);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. distorsione della frontiera IS; isolare effetto distorsivo della media
% Da una stima dei parametri effettua simulazioni e per cascuna calcola la
% frontiera efficiente. Plotta ogni frontiera, la loro media e la frontiera
% "vera"

T=300;  %giorni del campione
C=chol(S);
NSim=60; % numero di simulazioni
NPort=15; % portafogli estratti sulla frontiera
NStock=10; % numero di titoli

% rischo, rendimento, pesi dei portafogli sulla frontiera
frisk=zeros(NPort, NSim);
frend=zeros(NPort, NSim);
fwgt=zeros(NPort,NStock, NSim);

for i=1:NSim
    r=repmat(m,T,1)+ randn(T,length(m))*C;
    SSim=cov(r);
    mSim=mean(r);
    p = Portfolio('assetmean', mSim, 'assetcovar', SSim, 'lowerbudget', 1, 'upperbudget', 1, 'lowerbound', 0);
    fwgt(:,:,i) = estimateFrontier(p,NPort)';
    [frisk(:,i),frend(:,i)] = estimatePortMoments(p,fwgt(:,:,i)');
    plot(frisk(:,i),frend(:,i),'--','color',[.8,.8,.8])
    hold on
end

p = Portfolio('assetmean', m, 'assetcovar', S, 'lowerbudget', 1, 'upperbudget', 1, 'lowerbound', 0);
fwgtTrue = estimateFrontier(p,NPort);
[friskTrue,frendTrue] = estimatePortMoments(p,fwgtTrue);
plot(friskTrue,frendTrue,'color',[0,0,1])
friskMean=mean(frisk,2);
frendMean=mean(frend,2);
plot(friskMean,frendMean,'color',[1,0,0])





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. distorsione della frontiera IS; stimatori shrinkage
% Da una stima dei parametri effettua simulazioni e per cascuna calcola la
% frontiera efficiente. Plotta ogni frontiera, la loro media e la frontiera
% "vera"

T=80;  %giorni del campione
C=chol(S);
NSim=60; % numero di simulazioni
NPort=15; % portafogli estratti sulla frontiera
NStock=10; % numero di titoli

% rischo, rendimento, pesi dei portafogli sulla frontiera
frisk=zeros(NPort, NSim);
frend=zeros(NPort, NSim);
fwgt=zeros(NPort,NStock, NSim);

friskShr=zeros(NPort, NSim);
frendShr=zeros(NPort, NSim);
fwgtShr=zeros(NPort,NStock, NSim);

for i=1:NSim
    r=repmat(m,T,1)+ randn(T,length(m))*C;
    SSim=cov(r);
    mSim=mean(r);
    p = Portfolio('assetmean', mSim , 'assetcovar', SSim, 'lowerbudget', 1, 'upperbudget', 1, 'lowerbound', 0);
    fwgt(:,:,i) = estimateFrontier(p,NPort)';
    [frisk(:,i),frend(:,i)] = estimatePortMoments(p,fwgt(:,:,i)');

    SShr=lwcov(r);
    mtgt=mean(mean(r))*ones(1,NStock);
    mShr=jsmean(r,mtgt);
    q = Portfolio('assetmean', mShr , 'assetcovar', SShr, 'lowerbudget', 1, 'upperbudget', 1, 'lowerbound', 0);
    fwgtShr(:,:,i) = estimateFrontier(q,NPort)';
    [friskShr(:,i),frendShr(:,i)] = estimatePortMoments(q,fwgtShr(:,:,i)');
    plot(frisk(:,i),frend(:,i),'--','color',[.6,.6,.8])
    hold on
    plot(friskShr(:,i),frendShr(:,i),'--','color',[.8,.6,.6])
end

p = Portfolio('assetmean', m , 'assetcovar', S, 'lowerbudget', 1, 'upperbudget', 1, 'lowerbound', 0);
fwgtTrue = estimateFrontier(p,NPort)';
[friskTrue(:,i),frendTrue(:,i)] = estimatePortMoments(p,fwgtTrue');

plot(friskTrue,frendTrue,'color',[0,0,0])
friskMean=mean(frisk,2);
frendMean=mean(frend,2);
plot(friskMean,frendMean,'color',[0,0,1])
friskShrMean=mean(friskShr,2);
frendShrMean=mean(frendShr,2);
plot(friskShrMean,frendShrMean,'color',[1,0,0])

bar(fwgtShr(:,:,15),'stacked')
figure()
bar(fwgtTrue(:,:),'stacked')




