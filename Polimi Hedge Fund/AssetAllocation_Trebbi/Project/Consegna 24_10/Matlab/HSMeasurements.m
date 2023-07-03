function [ES, VaR] = HSMeasurements(returns, alpha, weights, portfolioValue)
%Evaluation of VaR (Value at Risk) and ES (Expected Shortfall) by
%Historical Simulation
% INPUTS
% returns                
% weights                   Portfolio weights (raw vector)
% alpha                     confidence level
% portfolioValue            Portfolio value       
%
% OUTPUTS
% VaR                       VaR (Value at Risk)
% ES                        ES   (Expected Shortfall)

n = size(returns,1);
Loss = zeros(1,n);
for i = 1:n 
    sim_portfolio = portfolioValue * exp(weights * returns(i,:)');
    Loss(i) = portfolioValue - sim_portfolio;     %Loss positiva se ho una perdita
end

L = sort(Loss,'descend');                                 %Distribution of losses
VaR = L(floor(n*(1-alpha)));                              %VaR at confidence level alpha
es_l = 0;
for ii = 1:floor(n*(1-alpha))                             %Integral of the losses between the quantile of 0.99 and 1
    es_l = es_l + L(ii);
end
ES = (1/(floor(n*(1-alpha))))*es_l;                              %Expected Shortfall
end