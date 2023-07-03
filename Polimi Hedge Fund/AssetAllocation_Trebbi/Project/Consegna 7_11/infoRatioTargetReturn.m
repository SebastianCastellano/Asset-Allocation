function [infoRatio,wts] = infoRatioTargetReturn(targetReturn,portObj)
% Calculate information ratio for a target-return portfolio along the
% efficient frontier
wts = estimateFrontierByReturn(portObj,targetReturn);
portRiskAct = estimatePortRisk(portObj,wts);
infoRatio = targetReturn/portRiskAct;
end

