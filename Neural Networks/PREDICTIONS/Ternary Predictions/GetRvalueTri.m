function[R, M, B, r, perf] = GetRvalueTri(NNOutputRegularPASdirName, actualTriPAS)

load(actualTriPAS)
% [ UsableDataTernary, UsableConcsTernary, meantimes, data, concmatrix_ternary, sortfields ] = GetUsableConcsData( expt );
[ UsableDataTernary,UsableConcsTernary, meantimes, data, concs ] = GetUsableConcsData( expt );
clearvars -except UsableDataTernary UsableConcsTernary NNOutputRegularPASdirName

% Load a NN output based on regular PAS
for i = 1:10
load(strcat(NNOutputRegularPASdirName,'\','this_',num2str(i))) % this will contain UsableConcs (6x154 in all the cells)

if i == 1
inputSeries = UsableConcsTernary;
targetSeries = UsableDataTernary;
[xc_ternary,xic_ternary,aic_ternary,tc_ternary,~,shift] = preparets(netc,inputSeries,{},targetSeries);
test = zeros(10,length(tc_ternary)*length(tc_ternary{1}));
r = zeros(10,1);
perf = zeros(10,1);
else
end
    
    yc = netc(xc_ternary,xic_ternary,aic_ternary);
    test(i,:) = cell2mat(yc);
    [r(i),~,~] = regression(tc_ternary,yc); 
    perf(i) =  mse(netc,tc_ternary,yc);
    
end

test_avg = mean(test);
% cols = repmat(154,1,393);
cols = repmat(length(yc{1}),1,length(yc)); 
yc_avg = mat2cell(test_avg,1,cols);
 
% perf = mse(netc,tc_ternary,yc_avg);
[R,M,B] = regression(tc_ternary,yc_avg);
plotregression(tc_ternary,yc_avg)

% save(strcat(NNOutputRegularPASdirName,'\R_Time_Course_Tri'))
save('\R_Time_Course_Tri')

end
