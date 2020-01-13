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
% Questions may be directed to meil@seas.upenn.edu

% t_sim : simulation time length (in seconds)
% t_dispense : time of agonist dispense  (in seconds)
% dirname : directory where the trained neural networks were saved

dirname = 'C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\Trained NNs';
t_sim = 260;
t_dispense = 20;

% example
concmatrix = repmat(-ones(6,1),1,t_sim);
concmatrix(2,t_dispense:end) = 1; % CVX (10xEC50) was dispensed at t = 20 seconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nRuns = 10;
Donors_Train_Set = {'B','C','D','F','O','P','Q','R','S','U','G','M'}; % used for predictions

count = 0;
for i = 1:length(Donors_Train_Set)               
        for k = 1:nRuns       
        count = count + 1;
        NN = strcat(dirname,'Donor_',Donors_Train_Set{i},'_NN_',num2str(k));   
        y = Simulate_single_NN(concmatrix, NN, t_sim, t_dispense);
        y_matrix(count,:) = y;
        end
end
y_matrix(y_matrix<0) = 0;
y_avg = mean(y_matrix);
s = std(y_matrix,[],1);
x = 0:size(y_avg,2)-1;

figure
errorbar(x,y_avg,s)
set(gca,'FontSize',20)
ylim([-0.2 1.2])
xlim([0 t_sim+20])
xlabel('Time(s)','FontSize',26)
ylabel('Ca^{2+}(t) Prediction','FontSize',26)
print(gcf,'-dpdf','Ca_Prediction')