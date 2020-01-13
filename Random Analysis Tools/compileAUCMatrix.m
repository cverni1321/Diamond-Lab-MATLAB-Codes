function [AUC_matrix,AUC_matrix_new,labels,concmatrix] = compileAUCMatrix(pwd)

% Gather a bunch of synergy vectors (or other things like AUC) to be used in plotDendrogram.m

healthyDonorIDs = {'cc','j','mm','nn','p','v','WW_AVG'};
traumaPatientIDs = {'147_T12','153_T48','164_T48','192_T48'};

if ~isempty(traumaPatientIDs)
    labels = strcat({healthyDonorIDs},{traumaPatientIDs});
else
    labels = healthyDonorIDs;
end

numConditions = 153; % Set this based on whatever population you are using (30 for abridged; 135 for full)
AUC_matrix = zeros(numConditions,length(healthyDonorIDs)+length(traumaPatientIDs));

for i = 1:length(healthyDonorIDs)
    regularplts = strcat(pwd,'\Full_PAS_Trauma_Agonists_Donor_',healthyDonorIDs{i});
    expt = load(regularplts);
    [areas,~,baselinediff,~] = NormalizedCalciumAUC(expt.expt);
    [concmatrix,~,~] = GetBasicResults(regularplts);
    if numConditions == 30
        concmatrix = RearrangeConcmatrix_AbridgedPAS(concmatrix);
    elseif numConditions == 153
        [concmatrix,baselinediff] = RearrangeConcmatrix_FullPAS(concmatrix,baselinediff);
    end
    close all
    AUC_matrix(:,i) = baselinediff(2:end);
end

if ~isempty(traumaPatientIDs)
for j = 1:length(traumaPatientIDs)
    regularplts = strcat(pwd,'\Full_PAS_Trauma_Agonists_Patient_',traumaPatientIDs{j});
    expt = load(regularplts);
    [areas,~,baselinediff,~] = NormalizedCalciumAUC(expt.expt);
    [concmatrix,~,~] = GetBasicResults(regularplts);
    if numConditions == 30
        concmatrix = RearrangeConcmatrix_AbridgedPAS(concmatrix);
    elseif numConditions == 153
        [concmatrix,baselinediff] = RearrangeConcmatrix_FullPAS(concmatrix,baselinediff);
    end
    close all
    AUC_matrix(:,j+length(healthyDonorIDs)) = baselinediff(2:end);
end
end

concmatrix(1,:) = [];

figure
load('C:\Users\Chris\Desktop\MATLAB Codes\Random Analysis Tools\cmap_br');
heatmap(AUC_matrix)
colormap(cmap_br)

[AUC_matrix_new] = plotDendrogram(AUC_matrix,healthyDonorIDs);

