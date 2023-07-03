
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computational Finance
% Fund Composition 24/09/21
% Group Busani, Castellano, De Bettin, Marcosignori
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Data

clear; close all; clc;

% Extract data from Excel file
data_table = readtable('prices.xls',...
    'VariableNamingRule', 'preserve',...
    'Sheet', 'prices_euro');


%% Data Preparation

% Eliminate the weekends
week_index = (data_table{:,end-1} == 1);
data = data_table(week_index,2:end-2);

% Separate the benchmarks
benchmarks = data(:, [16 17]);

% Leave out benchmarks and euro-dollar change
prices = data(:, 1:14);

% Clean data: remove NaNs
prices_final = CleanData(prices{473:end,:});
benchmarks_final = CleanData(benchmarks{4:end,:});

% Add a column for liquidity
prices_final = [prices_final, ones(length(prices_final), 1)];
prices_final = prices_final(2:end,:);


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
     eye(15)];
b = [0.1001 -0.0999 0.2701 -0.2699 0.0301 -0.0299 0.5001 -0.4999...
    0.33*ones(1, 15)]';

% Construct the frontier
frontier = PortfolioFrontier(prices_final(end-252:end,:), pft_number,...
    A, b, "efficient");

% Current weights (i.e. liquidity only)
w0 = [zeros(1,14) 1]';

% Fees to be applied
fee = 0.003;

% Current portfolio value (i.e. the money to be starting with)
current_value = 5e+6;

% Add the impact of transation costs (first day return only)
frontier = TransactionCosts(frontier, w0, current_value, fee);


%% Benchmark Analysis

% Benchmark weights
benchmark.weights = [0.3 0.7]';

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


%% Visual Analysis

d = sqrt(252);

figure;
plot(d*frontier.sigma, d*frontier.mean, 'ob');
hold on; grid on;
plot(d*frontier.sigma, d*frontier.real_return, 'or');
plot(d*benchmark.volatility, d*benchmark.mean, 'dg', 'LineWidth', 2);
title('Portfolio Frontier', 'Interpreter', 'Latex');
% legend('Portfolio Frontier',...
%     'Portfolio Frontier (with costs, una tantum)',...
%     'Interpreter', 'Latex', 'Location', 'Best');
legend('Portfolio Frontier',...
    'Portfolio Frontier (with costs, una tantum)',...
    'Benchmark', 'Interpreter', 'Latex', 'Location', 'Best');
xlabel('Expected Volatility', 'Interpreter', 'Latex');
ylabel('Expected Log-Return', 'Interpreter', 'Latex');

