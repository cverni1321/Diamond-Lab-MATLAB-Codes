function [R,M,B,r,perf] = GetRvalue(NNOutputRegularPASdirName,j,numRuns)

% Load a NN output based on regular PAS
load(strcat(NNOutputRegularPASdirName)); % This will contain UsableConcs (6x154 in all the cells)

inputSeries = UsableConcs;
targetSeries = UsableData;
[xc_correct,xic_correct,aic_correct,tc_correct,~,shift] = preparets(netc,inputSeries,{},targetSeries);
    
if j == 1
    test = zeros(numRuns,length(tc_correct)*length(tc_correct{1}));
    r = zeros(numRuns,1);
    perf = zeros(numRuns,1);
else
end
    
yc = netc(xc_correct,xic_correct,aic_correct);
test(j,:) = cell2mat(yc);
[r(j),~,~] = regression(tc_correct,yc); 
perf(j) =  mse(netc,tc_correct,yc);

test_avg = mean(test);
cols = repmat(length(yc{1}),1,length(yc)); 
yc_avg = mat2cell(test_avg,1,cols);
 
[R,M,B] = regression(tc_correct,yc_avg);
plotregression(tc_correct,yc_avg)

end
