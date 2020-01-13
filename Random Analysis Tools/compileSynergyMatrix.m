function [synergy_matrix,synergy_matrix_new,labels,concmatrix] = compileSynergyMatrix(pwd)

% Gather a bunch of synergy vectors (or other things like AUC) to be used in plotDendrogram.m

healthyDonorIDs = {'cc','j','mm','nn','p','v','WW_AVG'};
traumaPatientIDs = {'147_T12','153_T48','164_T48','192_T48'};

if ~isempty(traumaPatientIDs)
    labels = strcat({healthyDonorIDs},{traumaPatientIDs});
else
    labels = healthyDonorIDs;
end

numConditions = 135; % Set this based on whatever population you are using (15 for abridged; 135 for full)
synergy_matrix = zeros(numConditions,length(healthyDonorIDs)+length(traumaPatientIDs));

if ~isempty(healthyDonorIDs)
for i = 1:length(healthyDonorIDs)
    regularplts = strcat(pwd,'\Full_PAS_Trauma_Agonists_Donor_',healthyDonorIDs{i});
    [concmatrix,data,meantimes] = GetBasicResults(regularplts);
    if numConditions == 15
        concmatrix = RearrangeConcmatrix_AbridgedPAS(concmatrix);
    elseif numConditions == 135
        [concmatrix,data] = RearrangeConcmatrix_FullPAS(concmatrix,data);
    end
    [actual_s_normalized,~] = CalculateSynergy(data,data,meantimes,concmatrix);
    close all
    synergy_matrix(:,i) = actual_s_normalized;
end
end

if ~isempty(traumaPatientIDs)
for j = 1:length(traumaPatientIDs)
    regularplts = strcat(pwd,'\Full_PAS_Trauma_Agonists_Patient_',traumaPatientIDs{j});
    [concmatrix,data,meantimes] = GetBasicResults(regularplts);
    if numConditions == 15
        concmatrix = RearrangeConcmatrix_AbridgedPAS(concmatrix);
    elseif numConditions == 135
        [concmatrix,data] = RearrangeConcmatrix_FullPAS(concmatrix,data);
    end
    [actual_s_normalized,~] = CalculateSynergy(data,data,meantimes,concmatrix);
    close all
    synergy_matrix(:,j+length(healthyDonorIDs)) = actual_s_normalized;
end
end

concmatrix(1,:) = [];

figure
load('C:\Users\Chris\Desktop\MATLAB Codes\Random Analysis Tools\cmap_br');
heatmap(synergy_matrix)
colormap(cmap_br)

[synergy_matrix_new] = plotDendrogram(synergy_matrix,healthyDonorIDs,traumaPatientIDs);

