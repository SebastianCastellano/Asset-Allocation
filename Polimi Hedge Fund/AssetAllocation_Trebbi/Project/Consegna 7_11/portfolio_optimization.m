clear all
close all
clc
%% Import Historical Data
data=readtable('project1.xlsx');
head(data, 10)
dates = datenum(data.Date);
benchPrice1 = data.MSCIACWI;
benchPrice2 = data.JPMMAGGIE;
assetNames = data.Properties.VariableNames(2:end-2); 
assetPrice = data(:,assetNames).Variables;
assetP = assetPrice./assetPrice(1, :);  
benchmarkP1 = benchPrice1 / benchPrice1(1);
benchmarkP2 = benchPrice2 / benchPrice2(1);

% The visualization shows the evolution of all the asset prices normalized 
% to start at unity, that is accumulative returns.
figure;
plot(dates,assetP);
hold on;
plot(dates,benchmarkP1,'LineWidth',3,'Color','k');
plot(dates,benchmarkP2,'LineWidth',3,'Color','b');
hold off;
xlabel('Date');
ylabel('Normalized Price');
title('Normalized Asset Prices and Benchmark');
datetick('x');
legend('AGGH','IVV','EUMV','IAUF','EMB','MSCI','JPMMAGGIE','Location','southeast')
grid on;

%% Compute Returns and Risk-Adjusted Returns
benchReturn1 = tick2ret(benchPrice1);
benchReturn2 = tick2ret(benchPrice2);
assetReturn = tick2ret(assetPrice);

benchRetn1 = mean(benchReturn1);
benchRetn2 = mean(benchReturn2);
benchRisk1 =  std(benchReturn1);
benchRisk2 =  std(benchReturn2);
assetRetn = mean(assetReturn);
assetRisk =  std(assetReturn);
scale = size(data,1);

assetRiskR = sqrt(scale) * assetRisk;
benchRiskR1 = sqrt(scale) * benchRisk1;
benchRiskR2 = sqrt(scale) * benchRisk2;
assetReturnR = scale * assetRetn;
benchReturnR1 = scale * benchRetn1;
benchReturnR2 = scale * benchRetn2;

figure;
scatter(assetRiskR, assetReturnR, 6, 'm', 'Filled');
hold on
scatter(benchRiskR1, benchReturnR1, 6, 'g', 'Filled');
scatter(benchRiskR2, benchReturnR2, 6, 'g', 'Filled');
for k = 1:length(assetNames)
    text(assetRiskR(k) + 0.005, assetReturnR(k), assetNames{k}, 'FontSize', 8);
end
text(benchRiskR1 + 0.005, benchReturnR1, 'Benchmark1', 'Fontsize', 8);
text(benchRiskR2 + 0.005, benchReturnR2, 'Benchmark2', 'Fontsize', 8);
hold off;

xlabel('Risk (Std Dev of Return)');
ylabel('Expected Annual Return');
grid on;

%% Set Up a Portfolio Optimization
p = Portfolio('AssetList',assetNames);
p = setDefaultConstraints(p); % all weights sum to 1, no shorting, and 100% investment in risky assets
activReturn = assetReturn - 0.4*benchReturn1-0.6*benchReturn2;
pAct = estimateAssetMoments(p,activReturn,'missingdata',false)

%% Compute the Efficient Frontier Using the Portfolio Object
% Compute the mean-variance efficient frontier of 20 optimal portfolios. 
% Visualize the frontier over the risk-return characteristics of the individual assets. 
% Furthermore, calculate and visualize the information ratio for each portfolio along the frontier.

pwgtAct = estimateFrontier(pAct, 20); % Estimate weights
[portRiskAct, portRetnAct] = estimatePortMoments(pAct, pwgtAct); % Get risk and return

% Extract asset moments & names
[assetActRetnDaily, assetActCovarDaily] = getAssetMoments(pAct);
assetActRiskDaily = sqrt(diag(assetActCovarDaily));
assetNames = pAct.AssetList;

% Rescale
assetActRiskAnnual = sqrt(scale) * assetActRiskDaily;
portRiskAnnual  = sqrt(scale) *  portRiskAct;
assetActRetnAnnual = scale * assetActRetnDaily;
portRetnAnnual = scale *  portRetnAct;

figure;
subplot(2,1,1);
plot(portRiskAnnual, portRetnAnnual, 'bo-', 'MarkerFaceColor', 'b');
hold on;

scatter(assetActRiskAnnual, assetActRetnAnnual, 12, 'm', 'Filled');
hold on;
for k = 1:length(assetNames)
    text(assetActRiskAnnual(k) + 0.005, assetActRetnAnnual(k), assetNames{k}, 'FontSize', 8);
end

hold off;

xlabel('Risk (Std Dev of Active Return)');
ylabel('Expected Active Return');
grid on;

subplot(2,1,2);
plot(portRiskAnnual, portRetnAnnual./portRiskAnnual, 'bo-', 'MarkerFaceColor', 'b');
xlabel('Risk (Std Dev of Active Return)');
ylabel('Information Ratio');
grid on;


%% Perform Information Ratio Maximization Using Optimization Toolbox
objFun = @(targetReturn) -infoRatioTargetReturn(targetReturn,pAct);
options = optimset('TolX',1.0e-8);
[optPortRetn, ~, exitflag] = fminbnd(objFun,0,max(portRetnAct),options);
[optInfoRatio,optWts] = infoRatioTargetReturn(optPortRetn,pAct);
optPortRisk = estimatePortRisk(pAct,optWts) 

opt1Wts=[0.6 0.15 0.05 0.05 0.15]'
opt1PortRisk = estimatePortRisk(pAct,opt1Wts) 
opt1PortRetn = estimatePortReturn(pAct,opt1Wts) 

%% Plot the Optimal Portfolio
% Rescale
optPortRiskAnnual = sqrt(scale) * optPortRisk;
optPortReturnAnnual = scale * optPortRetn;
opt1PortRiskAnnual = sqrt(scale) * opt1PortRisk;
opt1PortReturnAnnual = scale * opt1PortRetn;
figure;
subplot(2,1,1);

scatter(assetActRiskAnnual, assetActRetnAnnual, 6, 'm', 'Filled');
hold on
for k = 1:length(assetNames)
    text(assetActRiskAnnual(k) + 0.005,assetActRetnAnnual(k),assetNames{k},'FontSize',8);
end
plot(portRiskAnnual,portRetnAnnual,'bo-','MarkerSize',4,'MarkerFaceColor','b');
plot(optPortRiskAnnual,optPortReturnAnnual,'ro-','MarkerFaceColor','r');
plot(opt1PortRiskAnnual,opt1PortReturnAnnual,'go-','MarkerFaceColor','g');
hold off;

xlabel('Risk (Std Dev of Active Return)');
ylabel('Expected Active Return');
grid on;

subplot(2,1,2);
plot(portRiskAnnual,portRetnAnnual./portRiskAnnual,'bo-','MarkerSize',4,'MarkerFaceColor','b');
hold on
plot(optPortRiskAnnual,optPortReturnAnnual./optPortRiskAnnual,'ro-','MarkerFaceColor','r');
plot(opt1PortRiskAnnual,opt1PortReturnAnnual./opt1PortRiskAnnual,'go-','MarkerFaceColor','g');
hold off;

xlabel('Risk (Std Dev of Active Return)');
ylabel('Information Ratio');
title('Information Ratio with Optimal Portfolio');
grid on;


%% Display the Portfolio Optimization Solution
assetIndx = optWts > .001;
results = table(assetNames(assetIndx)', optWts(assetIndx)*100, 'VariableNames',{'Asset', 'Weight'});
disp('Maximum Information Ratio Portfolio:');
disp(results);
fprintf('Max. Info Ratio portfolio has expected active return %0.2f%%\n', optPortRetn*scale*100);
fprintf('Max. Info Ratio portfolio has expected tracking error of %0.2f%%\n', optPortRisk*sqrt(scale)*100);




