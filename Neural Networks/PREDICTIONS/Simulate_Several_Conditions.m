clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SPECIFY CONCMATRIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify concentration at each time point (6 x t_sim matrix), where t_sim is the
% final time point, time progresses in increments of one second. 
% Agonist order (from top to bottom row) = ADP, CVX, Thrombin, U46619, Iloprost, GSNO
% Concentrations range from -1 (0 x EC50) to 1 (10 x EC50) of specific
% agonists (-1/3 for 0.1 x EC50 and 1/3 for 1 x EC50 of each). EC50 of
% each agonist may be found in Supplementary Figure S2.
% Output will be calcium concentration at each time point (between 0 and 1,
% where 1 is the maximum platelet calcium response, in the PAS assay that is typically the high convulxin response). 
% Output is an averaged combined response from 10NNs trained on each of the 12 donors (6
% male, 6 female) as specified in the Donors_Train_Set variable. 
% Questions may be directed to vernic@seas.upenn.edu

% t_sim : simulation time length (in seconds)
% t_dispense : time of agonist dispense  (in seconds)
% dirname : directory where the trained neural networks were saved

dirname = 'C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\Trained NNs\'; % Directory where trained NN's are
t_sim = 260;
t_dispense = 20;

regularplts = strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Full PAS (Trauma)\AVG_Full_PAS_Trauma_Agonists'); % Example dataset to set up the conditions matrix
[conditions,data,meantimes] = GetBasicResults(regularplts);
[conditions,data] = RearrangeConcmatrix_FullPAS(conditions,data); % Uncomment if you want to arrange with single conditions first
[ProcessedTimes,ProcessedData,UsableTimes,UsableData,UsableConcs,SingleMatrixOfUsableConcs,SingleMatrixOfUsableData] = InterpolateData(conditions,data,meantimes);

% Get the actual data plotted up
figure
heatmap(conditions)
figure
heatmap(ProcessedData)
xlabel('Time(s)','FontSize',26)
ylabel('Ca^{2+}(t) Measured','FontSize',26)

conditions = conditions';
concmatrix = repmat(-ones(6,1),1,t_sim);
y_avg = zeros(length(conditions),t_sim);

nRuns = 1; % Number of trained NN's for each donor
Donors_Train_Set = {'WW'}; % Donor data to be used for predictions

for i = 1:length(conditions)
concmatrix(:,t_dispense:end) = repmat(conditions(:,i),1,t_sim-t_dispense+1); % Specify the concmatrix for each condition one at a time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count = 0;
for j = 1:length(Donors_Train_Set)               
    for k = 1:nRuns       
        count = count + 1;
        NN = strcat(dirname,'Donor_',Donors_Train_Set{j},'_NN_NEWCONDITIONS',num2str(k));   
        y = Simulate_single_NN(concmatrix, NN, t_sim, t_dispense);
        y_matrix(count,:) = y;
    end
end

y_matrix(y_matrix<0) = 0;
y_matrix = y_matrix(:,1:t_sim); % Correct the size of this matrix to take avg
y_avg(i,:) = mean(y_matrix);
clear y_matrix
disp(i) % Show the progress of the code by displaying the conditions it has completed
%x = 0:size(y_avg,2)-1;
end

figure
heatmap(y_avg)
%set(gca,'FontSize',20)
%ylim([-0.2 1.2])
%xlim([0 t_sim+20])
xlabel('Time(s)','FontSize',26)
ylabel('Ca^{2+}(t) Prediction','FontSize',26)
%print(gcf,'-dpdf','Ca_Prediction')

% Find correlation coefficient between predicted data and actual data
[r,p,rlo,rup] = corrcoef(ProcessedData,y_avg); % Uncomment to calculate R when the NN's are trying to predict data that is already measured 
