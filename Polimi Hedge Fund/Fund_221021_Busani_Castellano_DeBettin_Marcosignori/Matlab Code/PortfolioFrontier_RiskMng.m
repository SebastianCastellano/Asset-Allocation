function frontier = PortfolioFrontier_RiskMng(prices, grid_number,...
    additional_matrix, additional_vector, alpha, max_VaR, VaR_prices, type)
% 
% frontier = PortfolioFrontier(prices, grid_number,...
%     additional_matrix, additional_vector, alpha, max_VaR, VaR_prices,...
%     type)
% 
% This function computes the optimal portfolio frontier starting from a
%   historical series of asset prices. It imposes as constraints:
%   - non negative weights (no short selling)
%   - the unitary sum of the weights (everything is invested)
%   - a maximum Value-at-Risk, computed via historical simulation
% It requires the following auxiliary functions:
%   > "VaR_constraint"
% 
% INPUT:
% prices: the historical series of prices for every asset considered;
%   matrix (rows number of observations x columns number of assets)
%   REMARK: the last prices are at the end of the matrix
% grid_number: the number of points to divide the range of possible
%   expected values in
% additional_matrix: the matrix to be used for additional INEQUALITY
%   constraints;
%   matrix (rows number of additional constraints x columns number of
%   assets)
% additional_vector: the vector to complete the INEQUALITY constraints
%   stated by "additional_matrix";
%   column vector (rows number of additional constraints)
% alpha: confidence level for the Value-at-Risk computation
% max_VaR: the maximum daily Value-at-Risk that can be associated to each
%   weight on the frontier
% VaR_prices: the historical series of prices for every asset considered;
%   matrix (rows number of observations x columns number of assets)
%   REMARK: the last prices are at the end of the matrix
%   REMARK: this may be a different length with respect to "prices"
% type: to select the parts of the curve to be computed
%   > "whole": the entire frontier, even the inefficient part
%   > "efficient": only the efficient part of the curve
%   REMARK: default value is "whole"
%
% OUTPUT:
% frontier: a struct containing the informations of the optimal portfolio
%   frontier:
%   - sigma2: the increasing sequence of portfolio variances; 
%   column vector (rows grid_number)
%   - sigma: the increasing sequence of portfolio volatilities; 
%   column vector (rows grid_number)
%   - mean: the expected values for each of the above variances;
%   column vector (rows grid_number)
%   - weights: the asset weights to reach the above mean-variance
%   portfolios;
%   matrix (rows number of assets x columns grid_number)


%% Settings

% Options for optimisation
settings = optimoptions('fmincon', "Display", 'off');

% Default values for parameters
if nargin < 5
    type = "whole";
    
    if nargin < 3
        additional_matrix = [];
        additional_vector = [];
    end
end

% Necessary in the Value-at-Risk constraint function
portfolioValue = 1;


%% From Prices To Log-Returns

% Compute log-returns from prices for each asset
log_returns = log(prices(2:end,:) ./ prices(1:end-1,:));
VaR_returns = log(VaR_prices(2:end,:) ./ VaR_prices(1:end-1,:));

% Number of assets
assets_number = size(prices,2);

% Extract the average value
% view = zeros(assets_number, 1);
view = mean(mean(prices)) * ones(1,assets_number);
average = jsmean(log_returns, view)';

% Extract the variance-covariance matrix
covariance_matrix = lwcov(log_returns);


%% Portfolio Frontier: Possible Expected Values

% The sum of weights must be one
A_equality1 = ones(1, assets_number);
b_equality1 = 1;

% No weight can be negative
A_inequality = [-eye(assets_number); additional_matrix];
b_inequality = [zeros(assets_number, 1); additional_vector];

% Initial value for optimisation
w0 = ones(assets_number, 1) / assets_number;

% Minimisation (--> find the last portfolio in the efficient branch)
switch type
    case "whole"
        
        % Find the minimum expected return reachable
        [~, average_min] = fmincon(@(w) w' * average, w0, A_inequality,...
            b_inequality, A_equality1, b_equality1, [], [],...
            @(w) VaR_constraint(VaR_returns, w, portfolioValue,...
            alpha, max_VaR), settings);
    
    case "efficient" 
        
        % Find the last portfolio in the efficient branch
        weights_min = fmincon(@(w) w' * covariance_matrix * w, w0,...
            A_inequality, b_inequality, A_equality1, b_equality1,...
            [], [], @(w) VaR_constraint(VaR_returns, w, portfolioValue,...
            alpha, max_VaR), settings);
        average_min = weights_min' * average;
        
end
    

% Maximisation
[~, average_max] = fmincon(@(w) -w' * average, w0, A_inequality,...
    b_inequality, A_equality1, b_equality1, [], [],...
    @(w) VaR_constraint(VaR_returns, w, portfolioValue,...
    alpha, max_VaR), settings);
average_max = -average_max;


%% Portfolio Frontier: Minimising Variance

% Create the grid to divide the possibile expected values
average_grid = linspace(average_min, average_max, grid_number)';

% Initialise the weights matrix and the sigmas for each grid point
weights_grid = zeros(assets_number, grid_number);
sigma_grid = zeros(grid_number, 1);

% The average value of the portfolio is fixed at each iteration
A_equality2 = [A_equality1; average'];

% Routine: fix portfolio mean -> minimise variance
for i = 1:grid_number
    
    % Fix the average value to be reached
    b_equality2 = [b_equality1; average_grid(i)];
    
    % Minimise the variance: store its value and the portfoio weights
    [weights_grid(:,i), sigma_grid(i)] = fmincon(...
        @(w) w' * covariance_matrix * w, w0, A_inequality, b_inequality,...
        A_equality2, b_equality2, [], [],...
        @(w) VaR_constraint(VaR_returns, w, portfolioValue,...
        alpha, max_VaR), settings);
    
end


%% Final Ordering

% Order the variances sequence increasingly 
[frontier.sigma2, sorting_indices] = sort(sigma_grid);

% Standard deviation
frontier.sigma = sqrt(frontier.sigma2);

% Order accordingly the mean values and the weights
frontier.mean = average_grid(sorting_indices);
frontier.weights = weights_grid(:, sorting_indices);

for i=1:length(frontier.sigma)-1
    if frontier.mean(i+1)<frontier.mean(i)
        frontier.mean(i+1) = frontier.mean(i);
        frontier.weights(i+1) = frontier.weights(i);
    end
end
        

end