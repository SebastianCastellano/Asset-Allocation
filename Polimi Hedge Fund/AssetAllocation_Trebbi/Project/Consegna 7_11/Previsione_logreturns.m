clear all
close all
clc

%% Importazione Dati 
load('projectmyversionS1.mat');

projectmyversionS2 = flipud(projectmyversionS1); %logreturns ordinati dal meno recente al più recente

%% Modelli per i rendimenti logaritmici

modelAR3 = arima(3,0,0); 
modelAR4 = arima(4,0,0);

modelMA3 = arima(0,0,3);
modelMA4 = arima(0,0,4);

modelARMA3 = arima(3,0,3);
modelARMA4 = arima(4,0,4);

K = 2; %numero di giorni per cui vogliamo fare previsione

%% Stima dei modelli e forecast per ciascun titolo

for j = 1:5
    
    EstMdlAR3(j) = estimate(modelAR3,projectmyversionS2(:,j));
    [FAR3(:,j),MSEAR3(:,j)] = forecast(EstMdlAR3(j),K,projectmyversionS2(:,j));
    
    EstMdlAR4(j) = estimate(modelAR4,projectmyversionS2(:,j));
    [FAR4(:,j),MSEAR4(:,j)] = forecast(EstMdlAR4(j),K,projectmyversionS2(:,j));
    

    EstMdlMA3(j) = estimate(modelMA3,projectmyversionS2(:,j));
    [FMA3(:,j),MSEMA3(:,j)] = forecast(EstMdlMA3(j),K,projectmyversionS2(:,j));
    
    EstMdlMA4(j) = estimate(modelMA4,projectmyversionS2(:,j));
    [FMA4(:,j),MSEMA4(:,j)] = forecast(EstMdlMA4(j),K,projectmyversionS2(:,j));
    
     EstMdlARMA3(j) = estimate(modelARMA3,projectmyversionS2(:,j));
    [FARMA3(:,j),MSEARMA3(:,j)] = forecast(EstMdlARMA3(j),K,projectmyversionS2(:,j));
    
    EstMdlARMA4(j) = estimate(modelARMA4,projectmyversionS2(:,j));
    [FARMA4(:,j),MSEARMA4(:,j)] = forecast(EstMdlARMA4(j),K,projectmyversionS2(:,j));
end


