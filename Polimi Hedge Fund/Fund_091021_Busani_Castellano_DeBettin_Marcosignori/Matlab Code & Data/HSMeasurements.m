 function [ES, VaR] = HSMeasurements(returns, weights, portfolioValue,alpha)
%Evaluation of VaR (Value at Risk) and ES (Expected Shortfall)measures  by
%Historical Simulation 
% INPUTS:
% returns  : returns of the assets/funds in our portfolio
% weights  : vector containig portfolio weights 
% portfolioValue : Portfolio value
% alpha    : confidence level
%
% OUTPUTS :
% VaR   : Value at Risk
% ES  :Expected Shortfall

 n = size(returns,1);
 % initialization
 loss = zeros(1,n);
 for i = 1:n
 portfolio_sim = portfolioValue .* exp(weights' * returns(i,:)');
 loss(i) = portfolioValue - portfolio_sim; % positive loss--> I lose money
 end

 loss_distrib = sort(loss,'descend'); % loss distribution sorted
 %VaR  Computed at confidence level given by alpha
 VaR = loss_distrib(floor(n*(1-alpha))); 
 es_l = 0;
 for ii = 1:floor(n*(1-alpha)) %Integral of the losses 
     es_l = es_l + loss_distrib(ii);

 end
 ES = (1/(floor(n*(1-alpha))))*es_l; %Expected Shortfall
 end