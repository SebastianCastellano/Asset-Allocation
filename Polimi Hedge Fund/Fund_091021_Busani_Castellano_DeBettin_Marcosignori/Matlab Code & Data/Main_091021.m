
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computational Finance
% Fund Composition 09/10/21
% Group Busani, Castellano, De Bettin, Marcosignori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Data

clear; close all; clc;

% Extract data from Excel file
data_table = readtable('Prices 2021-10-07.xlsx');
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


%% Portfolio Frontier

% Number of portfolios
pft_number = 500;

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

% Construct the frontier
frontier = PortfolioFrontier(prices_final(end-252:end,:), pft_number,...
    A, b, "efficient");

% % Current weights (i.e. liquidity only)
% w0 = [zeros(1,14) 1]';
% 
% % Fees to be applied
% fee = 0.003;
% 
% % Current portfolio value (i.e. the money to be starting with)
% current_value = 5e+6;
% 
% % Add the impact of transation costs (first day return only)
% frontier = TransactionCosts(frontier, w0, current_value, fee);


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

% Log-Returns for the assets
assets_returns = log(prices_final(2:end,:) ./ prices_final(1:end-1,:));
assets_returns2 = assets_returns(end-252:end, :);
pft_returns = (frontier.weights' * assets_returns2')';

% Compute benchmark historical series of returns
bnc_returns = (benchmark.weights' * benchmark_returns(end-252:end,:)')';

% Information ratio
info_ratio = (mean(pft_returns - bnc_returns)...
    ./ std(pft_returns - bnc_returns, 1))';

% Find the frontier portfolio that maximises the information ratio
[info_max, idx_max] = max(info_ratio);


%% VaR & ES Analysis

% Compute the analysis on a unitary value portfolio
portfolio_value = 1;

% 99% confidence level 
alpha = 0.99;
time_interval_days = 1;
risk_measures = struct(...
    'ES_HS', zeros(pft_number, 1),...
    'VaR_HS', zeros(pft_number, 1),...
    'ES_bootHS', zeros(pft_number, 1),...
    'VaR_bootHS', zeros(pft_number, 1),...
    'VaR_check', zeros(pft_number, 1));

% Number of resamples
resamples = 1e+4;

for i = 1:pft_number
    
    % Compute VaR and ES via a Historical Simulation approach
    [risk_measures.ES_HS(i), risk_measures.VaR_HS(i)] =...
        HSMeasurements(assets_returns, frontier.weights(:,i),...
        portfolio_value ,alpha);
    
    % Apply a statistical bootstrap (sampling with replacement)
    [risk_measures.ES_bootHS(i), risk_measures.VaR_bootHS(i)] =...
        RiskMeasures_StatisticalBootstrap(resamples, alpha, 1,...
        frontier.weights(:,i), portfolio_value, time_interval_days,...
        assets_returns);
    
    % Check the magnitude level through a plausibility check
    risk_measures.VaR_check(i) =...
        PlausibilityCheckVaR(alpha, frontier.weights(1:end-1,i),...
        0.9, time_interval_days, assets_returns(:,1:end-1));
    
end


%% Visual Analysis

d = sqrt(1);
figure;
plot(d*frontier.sigma, d*frontier.mean, 'ob');
hold on; grid on;
plot(d*benchmark.volatility, d*benchmark.mean, 'dg', 'LineWidth', 2);
title('Portfolio Frontier', 'Interpreter', 'Latex');
legend('Portfolio Frontier', 'Benchmark',...
    'Interpreter', 'Latex', 'Location', 'Best');
xlabel('Expected Volatility', 'Interpreter', 'Latex');
ylabel('Expected Log-Return', 'Interpreter', 'Latex');

figure;
plot(100*risk_measures.VaR_check, '-+k');
hold on; grid on;
plot(100*risk_measures.VaR_HS, '-+b');
plot(100*risk_measures.ES_HS, '-+r');
plot(100*risk_measures.VaR_bootHS, 'xc');
plot(100*risk_measures.ES_bootHS, 'xr');
title('VaR and ES Chart', 'Interpreter', 'Latex');
legend('VaR: plasubility check', 'VaR', 'ES', 'VaR (bootstrap)',...
    'ES (bootstrap)', 'Interpreter', 'Latex',...
    'location', 'best');
xlabel('Portfolio number', 'Interpreter', 'Latex');
ylabel('Percentage at risk', 'Interpreter', 'Latex');


%%

writematrix(frontier.weights, 'pesi.xlsx');