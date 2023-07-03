function VaR = PlausibilityCheckVaR(alpha, weights, portfolioValue, riskMeasureTimeIntervalInDays, returns)
%PLAUSIBILITYCHECKVAR Computes approximate VaR
%
%   INPUTS: 
%   alpha:                         confidence level
%   weights:                       column vector of portfolio weights
%   portfolioValue:                dollar value of the portfolio
%   riskMeasureTimeIntervalInDays: risk horizon
%   returns:                       matrix with logreturns for portfolio
%                                  assets
%                                  
%   OUTPUTS:
%   VaR: approximate value at risk
%
%   FUNCTIONS:
%   ---
    
    
    %  empirical upper percentile 
   u = prctile(returns, 100*alpha)'; 
   %  empirical lower percentile
   l = prctile(returns, 100 - 100*alpha)'; 
   
   % Correlation matrix of the risk factors 
   C = corr(returns);
   
   %stressed VaR
   sVaR = weights .* (abs(l)+abs(u))/2; 
   
   % VaR of the portfolio
   VaR  = portfolioValue * sqrt(sVaR'*C*sVaR .* riskMeasureTimeIntervalInDays);
   
end % function PlausibilityCheckVaR
