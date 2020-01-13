function [PredictedExpt, r, perf, tc, yc] = ExtractNNPASPrediction(ActualPAS, NNOutput)

% makes a predicted_expt structure
% load('C:\Users\SLDLab\Desktop\Mei Experiments\2013\PAS with IIa\Donor P\09-26-13 PAS - Donor P\this.mat') %NN Output 
% load('C:\Users\SLDLab\Desktop\Mei Experiments\2013\PAS with IIa\Donor P\09-26-13 PAS - Donor P\26-Sep-2013.mat') %Actual PAS

load(NNOutput);
load(ActualPAS);

predicted_expt = expt;

% basically reverse preparets
% figure out at which timestep in tc, target starts to be non-zero (recall
% that in preparets a bunch of null timesteps were added to the beginning
% of tc)
% assumes that the first timestep in tc is a null - not a bad assumption

% for i = 1:size(tc,2)
%    
%     if sum(find(tc{i}~=zeros(size(tc{1}))))
%     start_idx = i;
%     break
%     else
%     end
%     
% end

% % Try this and see
% for i = 1:start_idx-1
%     UsableConcs_Now{i} = -ones(size(UsableConcs{end}));
% end
% 
% for i = start_idx:size(tc,2)
%     UsableConcs_Now{i} = UsableConcs{end};
% end
inputSeries = UsableConcs;
targetSeries = UsableData;
% view(netc)
[xc,xic,aic,tc,~,shift] = preparets(netc,inputSeries,{},targetSeries);

% [xc,xic,aic,tc] = preparets(netc,inputSeries,{},targetSeries); % doesn't make a diff
% [xc,xic,aic,tc] = preparets(netc,inputSeries);  % doesn't make a diff
yc = netc(xc,xic,aic);

[r,~,~] = regression(tc,yc); 
perf =  mse(netc,tc,yc);
    
% The start is actually 20 seconds before dispense
start_idx = ceil(length(inputSeries)/2)-shift;

% yc = net(UsableConcs_Ternary);
% wb = getwb(netc);
% [b,IW,LW] = separatewb(netc,wb);

% same as before, can just use xc straight up too. 
yc = yc(start_idx:end);
x = 0:length(yc)-1;
x = x';


for k = 1:length(predicted_expt.samewells)

    y_pred = zeros(length(yc),1);
  
        for i = 1: length(yc)
        y_vector = yc{i};
        y_pred(i) = y_vector(k);
        end

 predicted_expt.samewells(1,k).datamean =  y_pred;
 predicted_expt.samewells(1,k).rawmean =  y_pred;
 predicted_expt.samewells(1,k).data =  y_pred;
 predicted_expt.samewells(1,k).timemean = x;
 predicted_expt.samewells(1,k).time = x;

end

PredictedExpt = predicted_expt;
% save(strcat(dirname,'\','Predicted','_',date),'predicted_expt')
% clear expt
% clear predicted_expt
% load(strcat(dirname,'\','Predicted','_',date))
% expt = predicted_expt;
% save(strcat(dirname,'\','Predicted','_',date),'expt')

% predplts = strcat(dirname,'\','Predicted','_',date,'_1');

end
