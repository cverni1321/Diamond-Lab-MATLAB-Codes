function [PredictedExpt, ActualExpt, concmatrix_higherorder, sortfields, R, perf, tc, yc] = GetPrediction(NNOutputRegularPAS, actualHigherOrderPAS, regularPAS)

load(actualHigherOrderPAS)

[UsableDataTernary, UsableConcsTernary, meantimes, data, concmatrix_higherorder] = GetUsableConcsData(expt);
[~,~,sortfields,sortmatrix] = sortstruct(expt.samewells,expt.sortfield);

ActualExpt = expt;
% As a starting point:
PredictedExpt = expt;
clearvars -except UsableDataTernary UsableConcsTernary meantimes data concmatrix_higherorder sortfields ActualExpt PredictedExpt NNOutputRegularPAS actualTriPAS regularPAS

% Load a NN output based on regular PAS
load(NNOutputRegularPAS) % This will contain UsableConcs (6x154 in all the cells)

% for i = 1:length(UsableConcsTernary)
% 
%     if UsableConcsTernary{i} == -ones(size(UsableConcsTernary{1}))
%         dummy{i} = -ones(size(UsableConcs{1}));
%     else 
%         dummy{i} = UsableConcs{end};
%     end
%     
% end
% 
% UsableConcs = dummy;
% inputSeries = vertcat(UsableConcsTernary , UsableConcs);

inputSeries = UsableConcsTernary;
targetSeries = UsableDataTernary;

netc;

[xc,xic,aic,tc,~,shift] = preparets(netc,inputSeries,{},targetSeries);

% Definitely need a targetSeries or at least a made-up aic, otherwise won't
% work. aic is the initial layer delay states. 

yc = netc(xc,xic,aic);
% yc = neto(xc);
% yc = neto(UsableConcs_Ternary(262:521));
% yc = neto(UsableConcs_Ternary,xic,aic);

[R,M,B] = regression(tc,yc);
perf = perform(netc,tc,yc);
% plotregression(tc,yc)

% The start is actually 20 seconds before dispense
start_idx = ceil(length(inputSeries)/2)-shift;

yc_used = yc(start_idx:end);
x = 0:length(yc_used)-1;
x = x';

% maybe NOT START RIGHT AT DISPENSE

for k = 1:length(PredictedExpt.samewells)

    y_pred = zeros(length(yc_used),1);
    
        for i = 1: length(yc_used)
        y_vector = yc_used{i};
        y_pred(i) = y_vector(k);
        end
     
% plot(1:length(yc),y_actual,'o',1:length(yc),y_pred,'-')


% plot(x,y_actual,'-b')
% hold on
% plot(x,y_pred,'-r')
    
 PredictedExpt.samewells(1,k).datamean =  y_pred;
 PredictedExpt.samewells(1,k).rawmean =  y_pred;
 PredictedExpt.samewells(1,k).data =  y_pred;
 PredictedExpt.samewells(1,k).timemean = x;
 PredictedExpt.samewells(1,k).time = x;

end

%10/23/13 max of PredictedTriExpt is 0.6526, min is -0.0094

load(regularPAS)
% Make ActualTriExpt values between zero and one
[ActualExpt, alldataregular, meandataregular] = makeBtwnZeroAndOne(ActualExpt, expt);

% filename = strcat('Predicted_Ternary_',date);
% save(filename)

end
