function Clean = CleanData(Raw)
% This function clean a matrix with raw data: every element which is zero
%   or NaN is replaced by the previous element

obs = size(Raw);
Clean = zeros(size(Raw));
Clean(1, :) = Raw(1, :);

for i = 2:obs
    
    Clean(i, :) = Raw(i, :);
    modify_index = logical(isnan(Raw(i,:)) + (Raw(i,:) == 0));
    Clean(i, modify_index) = Clean(i - 1, modify_index);
   
end

end