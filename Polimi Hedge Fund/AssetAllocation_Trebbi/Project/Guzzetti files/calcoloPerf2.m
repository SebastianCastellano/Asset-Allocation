
clear all
load ptf.mat

%--------- File content ----------%
% allocationBmk: weights of the benchmark; 
%               one row per day, one column per index
% BuySellCtv: purchase and sales in euro for each of the ten stocks in the
%               portfolio
% BuySellH: purchase and sales in number of shares for each of the
%               ten stocks in the portfolio
% CoupDiv: cash flows (coupons & dividends) for each of the ten stocks 
%               in the portfolio
% DepWith: deposits and withdrawals for the portfolio
% iniCapital: initial value invested
% iniLiquidity: initial cash
% iniPrices: Prices of the ten stock in the portfolio at t=0
% marketBmk: Market returns for the ten indices of the benchmark

% Please note the example assumes no transaction cost!

% change in the mean of the indices, please ignore
marketBmk = exp(log(marketBmk) +.005)-1;


NStock = size(marketBmk,2); 
NTimes = size(marketBmk,1)+1;

Prices = [iniPrices; Prices];

%% Computing the holdings (# of shares and liquidity amount for each day)
Holdings = ones(NTimes,1) * floor(iniCapital/NStock * 1./iniPrices) ; % assume equal weighted portfolio
Liquidity = (iniCapital - Holdings(1,:) * iniPrices' + iniLiquidity) * ones(NTimes,1);
Holdings(2:end,:) = Holdings(2:end,:) + cumsum(BuySellH); %# of shares
Liquidity(2:end) = Liquidity(2:end) - cumsum(sum(BuySellCtv,2)); % changes in liquidity due to purchases and sales
Liquidity(2:end) = Liquidity(2:end) + cumsum(sum(CoupDiv,2)); % changes in liquidity due to cash flows from the stocks
Liquidity(2:end) = Liquidity(2:end) + cumsum(DepWith); % changes in liquidity due to deposits and withdrawals

% check - balance constraint as taught in class
mov=sum(BuySellCtv,2) - sum(CoupDiv,2) - DepWith;
sum(mov+ Liquidity(2:end) - Liquidity(1:end-1))

%% computing the Money Weighted and Time Weighted returns
Valo = Holdings .* Prices; % total stocks value
NAV = sum(Valo,2) + Liquidity; % Net Asset Value (portfolio value)
dateFlows = find(DepWith); 
%modified Dietz return
MDietzRet = (NAV(end) - NAV(1) - sum(DepWith))/(NAV(1) + (1 - dateFlows/NTimes)' * DepWith(dateFlows));

%Time Weighted return
TWRetDaily = (NAV(2:end)-NAV(1:end-1)-DepWith)./NAV(1:end-1); % daily returns
TWRet = prod(1+TWRetDaily)-1; 
% MW and TW are quite close - a "lucky" case

%% Decomposing the return into contribution margins
%Margins
 PeL = Valo(2:end,:)- Valo(1:end-1,:) - BuySellCtv + CoupDiv; % daily Profit & Loss
 MC =   diag(1./NAV(1:end-1)) * PeL; % contribution margins
 %check: the sum of MC must equal the return every day
 sum(sum(MC,2) - TWRetDaily)
 
 %Cumulative margins
 capFactor = cumprod(1+TWRetDaily(2:end),'reverse'); %capitalization factors
 cmlMC = MC;
 cmlMC(1:end-1,:) = cmlMC(1:end-1,:) .* (capFactor * ones(1,NStock));
 cmlMC = sum(cmlMC,1); % sum along time
 %check: the sum along assets must equal the cumulative return
 sum(cmlMC)-TWRet
 
 %% Decomposing the excess return - performance attribution
 TWBmkDaily = sum(allocationBmk .* marketBmk,2); % daily benchmark return
 TWBmk = prod(1 + TWBmkDaily) - 1; % cumulative benchmark return
 allocationPtf = Valo(1:end-1,:) ./ (NAV(1:end-1) * ones(1,NStock)); % weights of the stocks
 marketPtf = PeL ./ Valo(1:end-1,:); % market returns for each stock
 %check: the weight times the return must equal the margin
 sum(sum(abs(allocationPtf .* marketPtf - MC)))
 
 % PA daily contributions
 AA = (allocationPtf - allocationBmk) .* marketBmk;
 SP = (marketPtf - marketBmk) .* allocationBmk;
 IE = (allocationPtf - allocationBmk) .* (marketPtf - marketBmk);
 %check: the sum of the contributions must equal the daily excess return
 sum(sum(AA,2)+sum(SP,2)+sum(IE,2) - (TWRetDaily-TWBmkDaily))
 
 %Cumulative PA contributions
 bmkFactor = cumprod(1+TWBmkDaily(1:end-1));
 cmlAA = AA;
 cmlAA(1:end-1,:) = cmlAA(1:end-1,:) .* (capFactor * ones(1,NStock));
 cmlAA(2:end,:) = cmlAA(2:end,:) .* (bmkFactor * ones(1,NStock));
 cmlSP = SP;
 cmlSP(1:end-1,:) = cmlSP(1:end-1,:) .* (capFactor * ones(1,NStock));
 cmlSP(2:end,:) = cmlSP(2:end,:) .* (bmkFactor * ones(1,NStock));
 cmlIE = IE;
 cmlIE(1:end-1,:) = cmlIE(1:end-1,:) .* (capFactor * ones(1,NStock));
 cmlIE(2:end,:) = cmlIE(2:end,:) .* (bmkFactor * ones(1,NStock));
 %check: adding the three contribution over time must equal the cumulative
 %excess return
 sum(cmlAA(:))+sum(cmlSP(:))+sum(cmlIE(:)) - (TWRet-TWBmk)
 
 
 