clear all
load('sp5h.mat')
sp5=stx50(6199:6500,1:10);
% remove outlier
boxplot(sp5)
sp5(sp5(:,7) == min(sp5(:,7)),:) = [];

m=mean(sp5);
S=cov(sp5);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. The IS optimal frontier is biased and extremely noisy
% 1. compute an estimation of the market parameters -> we pretend that the
% market parameters m and S are the "true", unknown parameters of the
% market
% 2. sample several times from the market and compute the EF
% 3. plot all the EF, their mean and the "true" frontier

T=300;  % # of days in each simulation of the market
C=chol(S);
NSim=60; % # of times a simulated realization from the market is created
NPort=15; % # of ptf along the frontier
NStock=10; % # of different stocks

% risk, return and wgt of the portfolios
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
%% 2. shrinkage estimators
% same as before, but compare with the EF obtained from shrinkage
% estimators

T=80;  
C=chol(S);
NSim=60; 
NPort=15; 
NStock=10; 

% risk, return and wgt of the portfolios
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.5 Resampled and classical frontier
% 1. S and m now represent the values estimated from the historical
% observations
% 2. the calculations proceed as before, sampling NRes market realizations
% from the market (with the estimated parameters S and m), and computing 
% a frontier based on that data set
% 3. for each of the NPort portfolios of the resampled frontier, the weight 
% of a given stock is computed by taking the average of the weights of the 
% same stock in the portfolios with the same rank on all the NRes frontiers
% 4. the resampled frontier is suboptimal with respect to m and S, but it
% shows a few attractive feature, e.g. the weights change smoothly along
% the frontier. 

T=300;  % # of days in each simulation of the market
C=chol(S);
NRes=100;  % # of frontiers that are going to be averaged (same role as NSim)
NPort=15;
NStock=10;

frisk=zeros(NPort, NRes);
frend=zeros(NPort, NRes);
fwgt=zeros(NPort,NStock, NRes);

for i=1:NRes
    r=repmat(m,T,1)+ randn(T,length(m))*C;
    SSim=cov(r);
    mSim=mean(r);
    p = Portfolio('assetmean', mSim , 'assetcovar', SSim, 'lowerbudget', 1, 'upperbudget', 1, 'lowerbound', 0);
    fwgt(:,:,i) = estimateFrontier(p,NPort)';
    [frisk(:,i),frend(:,i)] = estimatePortMoments(p,fwgt(:,:,i)');   
end
fwgtRE=mean(fwgt,3);
frendRE=fwgtRE*m';
friskRE=sqrt(diag(fwgtRE*S*fwgtRE'));
figure()
plot(friskRE,frendRE,'color',[0,1,0])
hold on

p = Portfolio('assetmean', m, 'assetcovar', S, 'lowerbudget', 1, 'upperbudget', 1, 'lowerbound', 0);
fwgtTrue = estimateFrontier(p,NPort)';
[friskTrue,frendTrue] = estimatePortMoments(p,fwgtTrue');
plot(friskTrue,frendTrue,'color',[0,0,1])

figure()                                                                 
bar(fwgtTrue,'stacked')
figure()
bar(fwgtRE,'stacked')

