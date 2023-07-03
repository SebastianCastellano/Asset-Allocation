%% Risk Measurements of a Linear Portfolio

clc;
clear all;

%% General parameters
                       
alpha1 = 0.99; 
alpha2 = 0.95;
portfolioValue = 4989153.98;             %Portfolio value at 16/10 
weights = [0.5999,0.1498,0.0501,0.0501,0.1501];          %weights

%% Select returns of interest

load('logreturn.mat')

%% Historical Simulation

[ES1, VaR1] = HSMeasurements(logreturn, alpha1, weights, portfolioValue)  
[ES2, VaR2] = HSMeasurements(logreturn, alpha2, weights, portfolioValue)  

%% Statistical Bootstrap and path generation for 7 days Var and ES

days = 7;
samples = bootstrapStatistical(days,logreturn);

[ES3, VaR3] = HSMeasurements(samples, alpha1, weights, portfolioValue)  
[ES4, VaR4] = HSMeasurements(samples, alpha2, weights, portfolioValue) 

%% Statistical Bootstrap and path generation for 14 days Var and ES

days1 = 14;
samples1 = bootstrapStatistical(days1,logreturn);

[ES5, VaR5] = HSMeasurements(samples1, alpha1, weights, portfolioValue)  
[ES6, VaR6] = HSMeasurements(samples1, alpha2, weights, portfolioValue)  

