function [C, Ceq] = VaR_constraint(log_returns, weights, portfolioValue,...
    alpha, max_VaR)
% Function to implement a Value-at-Risk constraint inside "fmincon" Matlab
%   function.
% It requires the following auxiliary functions:
%   > "HSMeasurements"

% No equality constraint
Ceq = 0;

% Compute VaR
[~, VaR] = HSMeasurements(log_returns, weights, portfolioValue, alpha);

% To be under zero constraint
C = VaR - max_VaR;

end