 function samples = Statisticalbootstrap(days,returns)
 % Generate samples for the statistical Bootstrap method of VaR and ES
 % INPUT
 % days    : vector of days 
 % returns : asset/fund returns of our portfolio
 % OUTPUT
 % samples
 
 x_max = size(returns,1);
 N = size(returns,2);
 samples = zeros(x_max,N);
 
 r = randi(x_max,days,1);
    for j = 1:length(r)
        samples(j,:) = returns(r(j),:); 
    end
    

 
 end