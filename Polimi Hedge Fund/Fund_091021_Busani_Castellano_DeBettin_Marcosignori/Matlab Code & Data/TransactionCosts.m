function frontier = TransactionCosts(frontier, current_weights,...
    current_value, fee)
% 
% frontier = TransactionCosts(frontier, current_weights,...
%     current_prices, fee)
%
% This function computes the effect of transaction costs to every portfolio
%   change from the current composition to the ones inside the input
%   optimal portfolio frontier.
% 
% INPUT:
% REMARK: the last asset must be liquidity
% frontier: a struct containing the informations of the optimal portfolio
%   frontier:
%   - sigma2: the increasing sequence of portfolio variances; 
%   column vector (rows grid_number)
%   - mean: the expected values for each of the above variances;
%   column vector (rows grid_number)
%   - weights: the asset weights to reach the above mean-variance
%   portfolios;
%   matrix (rows number of assets x columns grid_number)
% current_weights: the current portfolio weights;
%   column vector (rows number of assets)
% current_value: today portfolio value
% fee: the proportion of money lost in the transactions
%   REMARK: not expressed as percentage but in [0 1]
% 
% OUTPUT:
% frontier: the same imput struct containing the informations of the
%   optimal portfolio frontier, with the following additional fields:
%   > transaction_fees: the money that will be lost due to transaction
%       costs for every possibility;
%       column vector (rows number of portfolios in the frontier)
%   > real_return: the expected return for the first day taking into
%       account the transaction costs;
%       column vector (rows number of portfolios in the frontier)


%% Transaction costs

% Absolute changes in the portfolio weights for each possible transaction
weights_changes = abs(frontier.weights - current_weights);

% The amount lost in every transaction for every asset
transactions_fees_all = fee * weights_changes * current_value;

% Liquidity does not suffer from transaction costs
transactions_fees_all(end, :) = zeros(1, size(frontier.weights, 2));

% The total amount lost in every possible transaction
frontier.transactions_fees = sum(transactions_fees_all)'; 


%% Real Expected Log-Return

% Expected portfolio value (considering transaction costs)
real_expected_value =...
    (current_value - frontier.transactions_fees) .* exp(frontier.mean);

% Real expected log-return
frontier.real_return = log(real_expected_value / current_value);


end