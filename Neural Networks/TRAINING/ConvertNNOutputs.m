function [predictedData,actualData] = ConvertNNOutputs(yc,targets,concmatrix)
    
% This script converts the predicted outputs from the neural network
% training from cell format to plottable matrix format

numConditions = size(targets{1},2);

predictedData = zeros(numConditions,length(targets));
actualData = zeros(numConditions,length(targets));

% Dump everything into matrices and zero out stuff that is negative
for i = 1:length(targets)
    predictedData(:,i) = yc{i}';
    if predictedData(:,i) < 1e-3
        predictedData(:,i) = 0;
    end
end

for i = 1:length(targets)
    actualData(:,i) = targets{i}';
    if actualData(:,i) < 1e-3
        actualData(:,i) = 0;
    end
end

% There will be a large region of zeroed data but only want a period of 20
% sec to precede the dispense time
testZeros = all(predictedData);
numGoodColumns = sum(testZeros)+19; 
startRead = size(predictedData,2)-numGoodColumns;
predictedData = predictedData(:,startRead:end);

startRead = size(actualData,2)-numGoodColumns;
actualData = actualData(:,startRead:end);

% Plot up all the results and the concmatrix
figure
subplot(1,3,1)
heatmap(concmatrix);
subplot(1,3,2)
heatmap(actualData);
caxis([0 1])
title('Actual Data')
subplot(1,3,3)
heatmap(predictedData);
caxis([0 1])
title('Predicted Data')

end