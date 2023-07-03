clear all
load('sp5h.mat')% serie rendimenti S&P500
load('cap.mat')% capitalizzazione prime società del listino
sp5=stx50(6199:6500,1:10);

% controllo e rimozione outlier
%boxplot(sp5)
sp5(sp5(:,7) == min(sp5(:,7)),:) = [];
stx50(stx50(:,7) == min(stx50(:,7)),:) = [];

m=mean(sp5)';
S=cov(sp5);
cap5=cap(1:10); 

% Analisi di scenario
% pongo la media di GE pari a quella di lungo periodo
mlong=mean(stx50(3200:6200,1:10))';
bar((1+[mlong m]).^250-1)
selcode(1:10);

%picking e view
v=zeros(1,10);
v(1,7)=1;
mview=mlong(7);

%calcolo media e covarianza dello scenario
mSA=m+S*v'*((v*S*v')\(mview-v*m));
bar((1+[mlong m mSA]).^250-1)

SSA=S-S*v'*((v*S*v')\v*S);
heatmap(S)
figure()
heatmap(SSA)

%%%%%%%%%%%%%%%%%%%%%%%%%
% black & litterman

% implied views
lambda=1.2;
w=cap5/sum(cap5); % assumo l'universo di 10 titoli come portafoglio di mercato
mBL=2*lambda*S*w; % rendimenti impliciti 
bar((1+[mBL m]).^250-1)

% GE pari rendimento di lungo periodo
% AAPL-MSFT=-2% (ca. annuo)

c=500; % parametro di scala per la matrice di covarianza delle views
t=length(sp5); % parametro di scala per la matrice di covarianza dei rendimenti impliciti
v=zeros(2,10);
v(1,7)=1;
v(2,1)=1;
v(2,2)=-1;
mview=[mlong(7);(1-.02)^(1/250)-1];
Sview=v*S*v'/c; % matrice di covarianza delle views

%posterior
mBLP=mBL+S*v'*((v*S*v'/t+Sview)\(mview-v*mBL))/t;
SBLP=(1+1/t)*S-S*v'*((v*S*v'/t+Sview)\v*S)/(t^2);
bar((1+[mBLP mBL]).^250-1)
figure()
