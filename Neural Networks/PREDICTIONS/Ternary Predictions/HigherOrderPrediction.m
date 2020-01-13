% Takes in a NN training output structure from a regular PAS then tests netc to get predicted ternary
% responses; also creates predicted expt and plots ternary Ca traces.

function [PredictedExpt,ActualExpt,R,perf,predictedData_higherorder,actualData_higherorder,concmatrix_higherorder] = HigherOrderPrediction(NNOutputRegularPAS,actualHigherOrderPAS,regularPAS,plotFlag)

% NNOutputRegularPAS: complete pathname to workspace structure of a NN trained on regular PAS
% actualHigherOrderPAS: complete pathname to expt structure from actual higher order PAS
% regularPAS: complete pathname to expt structure from regular PAS 
% plotFlag: 'plot' if you want plots


% NNOutputRegularPAS = 'C:\Users\SLDLab\Desktop\Mei Experiments\2013\PAS with IIa\Donor R\10-10-13 PAS - Donor R\this';
% actualTriPAS = 'C:\Users\SLDLab\Desktop\Mei Experiments\2013\PAS with IIa\Donor R\10-11-13 PAS Ternary - Donor R\17-Oct-2013';
% regularPAS = 'C:\Users\SLDLab\Desktop\Mei Experiments\2013\PAS with IIa\Donor R\10-10-13 PAS - Donor R\17-Oct-2013';

[PredictedExpt, ActualExpt, concmatrix_higherorder, ~, R, perf, tc, yc] = GetPrediction(NNOutputRegularPAS, actualHigherOrderPAS, regularPAS);
% ActualTriExpt is now between 0 and 1

[predictedData_higherorder,actualData_higherorder] = ConvertNNOutputs(yc,tc,concmatrix_higherorder);
close % Don't want the figure that is outputted from this command

[concmatrix_higherorder,predictedData_higherorder,actualData_higherorder] = RearrangeConcmatrix_HigherOrderExpt(concmatrix_higherorder,predictedData_higherorder,actualData_higherorder);
ProcessedTimes = 1:size(predictedData_higherorder,2);

if strcmp(plotFlag,'plot')
    figure
    subplot(1,3,1)
    heatmap(concmatrix_higherorder);
    caxis([-1 1])
    title('Higher Order Input')
    subplot(1,3,2)
    heatmap(actualData_higherorder);
    caxis([0 1])
    title('Actual Data')
    subplot(1,3,3)
    heatmap(predictedData_higherorder);
    caxis([0 1])
    title('Predicted Data')
    plotPredictedvsActualCalciumTraces(predictedData_higherorder,actualData_higherorder,concmatrix_higherorder,ProcessedTimes);
else
end

% Calculate synergy scores (first need to load the single conditions to use
% in the calculation)
load(NNOutputRegularPAS)
actualDataSINGLE = actualData(2:19,:);
predictedDataSINGLE = predictedData(2:19,:);
concmatrixSINGLE = concmatrix(2:19,:);

if size(actualDataSINGLE,2) ~= size(actualData_higherorder,2) % Check to see that the matrices are the same size for concatenation
    vectordiff = size(actualDataSINGLE,2)-size(actualData_higherorder,2);
    if vectordiff>0
        actualDataSINGLE = actualDataSINGLE(:,1:end-vectordiff);
    elseif vectordiff<0
        actualData_higherorder = actualData_higherorder(:,1:end+vectordiff);
    end
else
end

if size(predictedDataSINGLE,2) ~= size(predictedData_higherorder,2)
    vectordiff = size(predictedDataSINGLE,2)-size(predictedData_higherorder,2);
    if vectordiff>0
        predictedDataSINGLE = predictedDataSINGLE(:,1:end-vectordiff);
    elseif vectordiff<0
        predictedData_higherorder = predictedData_higherorder(:,1:end+vectordiff);
    end
else
end

if size(ProcessedTimes,2) ~= size(predictedData_higherorder,2)
    vectordiff = size(ProcessedTimes,2)-size(predictedData_higherorder,2);
    if vectordiff>0
        ProcessedTimes = ProcessedTimes(:,1:end-vectordiff);
    elseif vectordiff<0
        ProcessedTimes = ProcessedTimes(:,1:end+vectordiff);
    end
else
end

actualData = [actualDataSINGLE; actualData_higherorder(2:end,:)];
predictedData = [predictedDataSINGLE; predictedData_higherorder(2:end,:)];
concmatrix = [concmatrixSINGLE; concmatrix_higherorder(2:end,:)];

[actual_s_normalized,predicted_s_normalized] = CalculateSynergy_higherorder(actualData,predictedData,ProcessedTimes,concmatrix);

end