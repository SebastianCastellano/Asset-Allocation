function samples = bootstrapStatistical(days,returns)
% Generate samples for the Bootstrap method of VaR and ES
% INPUT  
% days       
% returns
% OUTPUT
% samples                            

N = size(returns,2);
xmax = size(returns,1);
samples = zeros(xmax,N);
    for i = 1:xmax
        r = randi(xmax,1,days);  %permutation index
            for j = 1:length(r)
                samples(i,:) = samples(i,:) + returns(r(j),:);         %samples
            end
    end
end
