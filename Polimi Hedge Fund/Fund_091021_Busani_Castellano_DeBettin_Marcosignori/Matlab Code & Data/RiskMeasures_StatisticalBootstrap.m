function [ES, VaR] = RiskMeasures_StatisticalBootstrap(NumberResamples,...
    Alpha, Lambda, PortfolioWeights, PortfolioValue, TimeIntervalDays,...
    Returns)
% 
% [ES, VaR] = RiskMeasures_StatisticalBootstrap(NumberResamples,...
%     Alpha, Lambda, PortfolioWeights, PortfolioValue, TimeIntervalDays,...
%     Returns)
% 
% This function implements the random sampling with replacement
%   (statistical bootstrap) combined with the (weighted) historical
%   simulation approach.
% This function requires the following auxiliary functions:
%   > "RiskMeasures_HistoricalSimulation"
% 
% INPUT:
% NumberResamples: the number of random sampling to be executed
% Alpha: confidence level for VaR and ES, in [0.5 1]
% Lambda: parameter for the creation of weights to evaluate the
%   observations, in [0 1]
% REMARK: Lambda == 1 --> Historical Simulation
%         Lambda  < 1 --> Weighted Historical Simulation
% PortfolioWeights: weights for each stock associated to each return
%   column, column vector (rows number of companies considered)
% PortfolioValue: value in (Mil) euros/usd of the portfolio at current time
% TimeIntervalDays: the horizon for the measures to be computed IN DAYS.
%   Usually a year is here composed by 250 days (the working ones)
% Returns: vector containing DAILY returns, column vector (rows number of
%   observations), matrix (rows number of observations x columns number of
%   companies)
% REMARK: these can be also non-daily but in that case the measures horizon
%   must be adjusted as well
% 
% OUTPUT:
% ES: Expected Shortfall in monetary unit measure as the input
%   PortfolioValues
% VaR: Value-at-Risk in monetary unit measure as the input PortfolioValue


%% Random Sampling With Replacement

% Number of observations
n = size(Returns, 1);

% Random integer numbers
rng('shuffle');
sample_indexes = randi([1 n], NumberResamples, 1);

% New set of returns
sampled_returns = Returns(sample_indexes, :);


%% ES & VaR

% (Weighted) Historical Simulation
[ES, VaR] = RiskMeasures_HistoricalSimulation(Alpha, Lambda,...
    PortfolioWeights, PortfolioValue, TimeIntervalDays, sampled_returns);


end