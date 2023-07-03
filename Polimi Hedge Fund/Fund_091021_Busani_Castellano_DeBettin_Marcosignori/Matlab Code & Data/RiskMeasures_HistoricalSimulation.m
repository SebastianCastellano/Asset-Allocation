function [ES, VaR] = RiskMeasures_HistoricalSimulation(Alpha, Lambda,...
    PortfolioWeights, PortfolioValue, TimeIntervalDays, Returns)
%
% [ES, VaR] = RiskMeasures_HistoricalSimulation(Alpha, Lambda,...
%     PortfolioWeights, PortfolioValue, TimeIntervalDays, Returns)
%
% This function computes the Expected Shortfall (ES) and the Value at Risk
%   (VaR) with the (weighted) historical simulation technique. The
%   portfolio considered is linear in stocks (--> use of portfolio weights).
% 
% INPUT:
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
%   PortfolioValue
% VaR: Value-at-Risk in monetary unit measure as the input PortfolioValue


%% Portfolio Losses & HS

% Portfolio losses
portfolio_losses = - Returns * PortfolioWeights;

% Number of observations
n = length(portfolio_losses);

% Order the sequence in the decreasing way
[ordered_losses, ordered_indexes] = sort(portfolio_losses, 'descend');

if Lambda == 1
    
    % Array index of VaR
    index_var = floor(n * (1 - Alpha));
    
    % Value-at-Risk
    VaR = ordered_losses(index_var);
    
    % Expected Shortfall
    ES = mean(ordered_losses(1:index_var));
    
end


%% Weighted Historical Simulation

if Lambda < 1
    
    % Create weights
    weights = (1 - Lambda)/(1 - Lambda^n)...
        *(Lambda.^(n-1:-1:0)');
    
    % Sort the weights as losses were sorted
    ordered_weights = weights(ordered_indexes);
    
    % Array index for VaR
    cumulated_weights = cumsum(ordered_weights);
    [~, index_var] = max(cumulated_weights(cumulated_weights <= 1 - Alpha));
    
    % Value-at-Risk
    VaR = ordered_losses(index_var);
    
    % Expected Shortfall
    ES = sum(ordered_weights(1:index_var).*ordered_losses(1:index_var))...
        /sum(ordered_weights(1:index_var));
    
end


%% Scaling Factor & Portfolio Value

% Apply scaling factor and portfolio value (to get results in the same
%   unit measure)
ES = PortfolioValue * sqrt(TimeIntervalDays) * ES;
VaR = PortfolioValue * sqrt(TimeIntervalDays) * VaR;


end