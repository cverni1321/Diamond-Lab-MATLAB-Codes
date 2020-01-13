% Use this script to plot lots of graphs (one for each combinatorial
% condition) of predicted calcium vs actual calcium 

% First run HigherOrderPrediction to get predictedData and actualData

function plotPredictedvsActualCalciumTraces(predictedData,actualData,concmatrix,ProcessedTimes)

% Delete buffer condition if present
numAgonists = size(concmatrix,2);
testvector = -ones(1,numAgonists);
if isequal(testvector,concmatrix(1,:))
    predictedData(1,:) = [];
    actualData(1,:) = [];
    concmatrix(1,:) = [];
else
end

% Create carcass of final figure
numConditions = size(concmatrix,1);
cols = 7;
rows = round(numConditions/cols);

leftplots = (0:rows-1)*cols+1;
bottomplots = (numConditions-cols+1:numConditions);

figure
for i=1:numConditions   
    subplot(rows,cols,i)
    plot(ProcessedTimes,predictedData(i,:),'b');
    hold on
    plot(ProcessedTimes,actualData(i,:),'r');
    ylim([0 1])
    xlim([0 300])
    
    if ~any(bottomplots==i)
        set(gca,'XTickLabel',[])
    else
    end
    
    if ~any(leftplots==i)
        set(gca,'YTickLabel',[])
    else
    end
end

numConditions = size(concmatrix,1);
cols = 7;
rows = round(numConditions/cols);

figure
for i=1:numConditions   
    subplot(rows,cols,i)
    heatmap(concmatrix(i,:));
    caxis([-1 1])
end


