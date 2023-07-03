clear all
load('sp5h.mat')

NStock=10; % numero di titoli universo
T=300;
sp5=stx50((6500-T+1):6500,1:NStock);

% rendimento indice sintetico
wgtIdx=exp(-0.2*(1:NStock))';
wgtIdx=wgtIdx/sum(wgtIdx);
% bar(wgtIdx);
rendIdx=sp5*wgtIdx;

mR=mean(sp5,1); % rendimento medio titoli
mI=mean(rendIdx); % rendimento medio indice
mdadI=mean(-rendIdx(rendIdx<0)); % mdad indice (solo per ordine di grandezza)

% costruzione curve
EM=-mI*10; %-1e-3; %ampio margine, considero solo TE
%99.9 in corrispondenza di rend indice
K=0.999;
alphaE=log(1/K-1)/EM;
muE=@(x)1./(1+exp(-alphaE*(x-EM)));
xx=2*EM:1e-4:-2*EM;
plot(xx,muE(xx))


SM=mdadI/10;%prossimo a 0 che è minimo per mdad
%95 in corrispondenza di 0
K=0.95;
alphaS=-log(1/K-1)/SM;
muS=@(x)1./(1+exp(alphaS*(x-SM)));
xx=-1e-3:1e-4:2*SM;
plot(xx,muS(xx))

% input di linprog
%fx obiettivo
f=

%disuguaglianze
A=
b=

%uguaglianze
Aeq=
beq=

%positività
lb=

%ottimizzazione
w=linprog(f,A,b,Aeq,beq,lb);

