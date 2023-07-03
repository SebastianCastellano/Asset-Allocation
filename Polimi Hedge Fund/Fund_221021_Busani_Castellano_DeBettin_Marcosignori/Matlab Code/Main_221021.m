
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computational Finance
% Fund Composition 22/10/21
% Group Busani, Castellano, De Bettin, Marcosignori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Data

clear; close all; clc;

% Extract data from Excel file
data_table = readtable('Portfolio Valorisation.xlsx','sheet','Prices');
    %'VariableNamingRule', 'preserve',...
    %'Sheet', 'Sheet 1');


%% Data Preparation

data=data_table;

% Separate the benchmarks
benchmarks = data(:, [17 18]);

% Leave out benchmarks and euro-dollar change
prices = data(:, 2:15);

% Clean data: remove NaNs
prices_final = CleanData(prices{:,:});
benchmarks_final = CleanData(benchmarks{4:end,:});

% Add a column for liquidity
prices_final = [prices_final, ones(length(prices_final), 1)];
%prices_final = prices_final(2:end,:);


%% Value-at-Risk settings

% Compute the analysis on a unitary value portfolio
portfolio_value = 1;

% 99% confidence level 
alpha = 0.99;
time_interval_days = 1;


%% Portfolio Frontier

% Consider only the prices back to 1 year in the past
priceConsidered = prices_final(end-252:end,:);

% Auxiliary variables
T = size(priceConsidered,1);
nFunds = size(priceConsidered,2)-1;

% Compute the log-return matrix 
logReturns = log( priceConsidered(2:end,1:end-1) ./ priceConsidered(1:end-1,1:end-1) );

% Compute mean and covariance of the returns
meanReturns = mean(logReturns);
covReturns = cov(logReturns);
C = chol(covReturns);


% Number of portfolios
pft_number = 30;

% Constraints
A = [1 zeros(1,11) 1 1 0;
     -1 zeros(1,11) -1 -1 0;
     0 1 0 0 0 1 1 1 1 1 0 0 0 0 0;
     0 -1 0 0 0 -1 -1 -1 -1 -1 0 0 0 0 0;
     0 0 0 0 1 zeros(1,10);
     0 0 0 0 -1 zeros(1,10);
     0 0 1 1 0 zeros(1,5) 1 1 0 0 0;
     0 0 -1 -1 0 zeros(1,5) -1 -1 0 0 0;
     eye(15);
     -eye(15)];
b = [0.1201 -0.1199 0.3501 -0.3499 0.0301 -0.0299 0.4001 -0.3999...
    0.33*ones(1, 15)...
    -0.02*ones(1, 15)]';

% Maximum daily VaR
VaR_limit = 0.04; % 4%

% Construct the frontier
frontierTrue = PortfolioFrontier_RiskMng_opt(meanReturns, covReturns,...
    pft_number, A, b, alpha, VaR_limit, prices_final(end-252:end,:), "efficient");

% Shrinkage Estimators

mb = -0.001; % return bond asset class
mc = 0.03; % return Ethereum
me = 0; % return equity and commotidy asset classes

mtgt = [me, me, mb, mb, mc, me, me, me, me, me, mb, mb, me, me];

%mtgt = mean(meanReturns);
[mSHR, gamma] = jsmean(logReturns, mtgt );
cSHR = lwcov(logReturns);

% Construct Frontier with shrinkage estimators
frontierSHR = PortfolioFrontier_RiskMng_opt(mSHR, cSHR,...
    pft_number, A, b, alpha, VaR_limit, prices_final(end-252:end,:), "efficient");

%% Resampling


% Initializing simulated Prices
simulatedPrices = priceConsidered;

nSim = 100; % number of resample

% Initializing empty frontiers
frontier.sigma = zeros(pft_number,1);
frontier.sigma2 = zeros(pft_number,1);
frontier.mean = zeros(pft_number,1);
frontier.weights = zeros(15,pft_number);
retFrontier = zeros(pft_number,1);
varFrontier = zeros(pft_number,1);
wFrontier = zeros(pft_number, nFunds+1)';

rng(1)

figure(1)

for i=1:nSim
    simulatedReturns = meanReturns + randn(T-1, nFunds) * C;
    cumulativeReturns = cumsum(simulatedReturns);
    simulatedPrices(2:end, 1:end-1) = ( ones(T-1,1) * simulatedPrices(1,1:end-1) ) .* exp(cumulativeReturns); 
    simulatedPrices(:,5) = prices_final(end-252:end,5);
    m = mean(simulatedReturns);
    c = cov(simulatedReturns);
    frontier(i) = PortfolioFrontier_RiskMng_opt(m, c, pft_number,...
    A, b,alpha, VaR_limit, simulatedPrices, "efficient");
    retFrontier = retFrontier + frontier(i).mean;
    varFrontier = varFrontier + frontier(i).sigma;
    wFrontier = wFrontier + frontier(i).weights;
end

% Plotting
plot(frontierTrue.sigma, frontierTrue.mean, '-b','LineWidth',2);
hold on;
plot(frontierSHR.sigma, frontierSHR.mean, '-g', 'LineWidth',2);
hold on;
retFrontierMean = retFrontier/nSim;
varFrontierMean = varFrontier/nSim;
wFrontierMean = wFrontier/nSim;
plot(varFrontierMean,retFrontierMean,'r-','LineWidth',2)

for i=1:nSim
    plot(frontier(i).sigma, frontier(i).mean, '--','color',[.8,.8,.8]);
    hold on;
end

title('RESAMPLING','Interpreter','Latex')
xlabel('variance','Interpreter','Latex')
ylabel('return','Interpreter','Latex')
legend('Real data Frontier', 'Shrinkage Frontier','Average Frontier','Interpreter','LatEx')
hold off;


%% Benchmark Analysis

% Benchmark weights
benchmark.weights = [0.45 0.55]';

% Log-Returns
benchmark_returns = log(benchmarks_final(2:end,:)...
    ./ benchmarks_final(1:end-1,:));

% Mean value & variance-covariance matrix
means = mean(benchmark_returns(end-252:end,:))';
variance = cov(benchmark_returns(end-252:end,:));

% Benchmark statistics
benchmark.mean = benchmark.weights' * means;
benchmark.volatility =...
    sqrt(benchmark.weights' * variance * benchmark.weights);


%% Best Portfolio Selection

frontier1.weights = wFrontierMean;
frontier1.mean = retFrontierMean;
frontier1.sigma = varFrontierMean;
frontier1.sigma2 = varFrontierMean.^2;

% Log-Returns for the assets
assets_returns = log(prices_final(2:end,:) ./ prices_final(1:end-1,:));
assets_returns2 = assets_returns(end-252:end, :);
pft_returns = (frontier1.weights' * assets_returns2')';

% Compute benchmark historical series of returns
bnc_returns = (benchmark.weights' * benchmark_returns(end-252:end,:)')';

% Information ratio
info_ratio = (mean(pft_returns - bnc_returns)...
    ./ std(pft_returns - bnc_returns, 1))';

% Find the frontier portfolio that maximises the information ratio
[info_max, idx_max] = max(info_ratio);


%% Visual Analysis

d = sqrt(1);
figure (2);
plot(d*frontier1.sigma, d*frontier1.mean, 'ob');
hold on; grid on;
plot(d*benchmark.volatility, d*benchmark.mean, 'dg', 'LineWidth', 2);
title('Portfolio Frontier', 'Interpreter', 'Latex');
legend('Portfolio Frontier', 'Benchmark',...
    'Interpreter', 'Latex', 'Location', 'Best');
xlabel('Expected Volatility', 'Interpreter', 'Latex');
ylabel('Expected Log-Return', 'Interpreter', 'Latex');

figure(3);
plot(100*risk_measures.VaR_check, '-+k');
hold on; grid on;
plot(100*risk_measures.VaR_HS, '-+b');
plot(100*risk_measures.ES_HS, '-+r');
plot(100*risk_measures.VaR_bootHS, 'xc');
plot(100*risk_measures.ES_bootHS, 'xr');
title('VaR and ES Chart', 'Interpreter', 'Latex');
legend('VaR: plasubility check', 'VaR', 'ES', 'VaR (bootstrap)',...
    'ES (bootstrap)', 'Interpreter', 'Latex',...
    'Location', 'best');
xlabel('Portfolio number', 'Interpreter', 'Latex');
ylabel('Percentage at risk', 'Interpreter', 'Latex');


%% Distance from old weights

oldW = [0.020459276, 0.021023833, 0.020777168, 0.021200794, 0.030082223, 0.247315801, 0.020214472, 0.021127539, 0.020165825,...
    0.020184859, 0.028622419, 0.329404552, 0.022181473, 0.077400227, 0.09983954]';

distance = oldW(1:end-1)' * cSHR * wFrontierMean(1:end-1,idx_max);





%%

%writematrix(frontier.weights, 'pesi.xlsx');