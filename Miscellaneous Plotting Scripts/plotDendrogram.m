function [data_matrix_new] = plotDendrogram(data_matrix,healthyDonorIDs,traumaPatientIDs)

% Calculates similarity of synergy datasets and clusters donors/patients to
% be plotted in dendrogram form

Z = linkage(data_matrix');

figure
[~,~,outperm] = dendrogram(Z);
set(gca,'YTick',[]);

if ~isempty(healthyDonorIDs)
ticklabels = get(gca,'XTickLabel');
ticklabels_new = cell(size(ticklabels,1),1);
for i=1:length(ticklabels_new)
    ticklabels_new{i} = strcat(ticklabels(i,:));
    if str2num(ticklabels_new{i}) > length(healthyDonorIDs)
        ticklabels_new{i} = ['\color{red} ' ticklabels_new{i}];
    end
end
set(gca,'XTickLabel',ticklabels_new);

else
for i=1:length(traumaPatientIDs)
    traumaPatientIDs_new{i} = ['\color{red} ' traumaPatientIDs{outperm(i)}];
end
set(gca,'XTickLabel',traumaPatientIDs_new);
end

% Now rearrange the matrix of synergies based on the dendrogram analysis

data_matrix_new = data_matrix(:,outperm);
load('C:\Users\Chris\Desktop\MATLAB Codes\Random Analysis Tools\cmap_br');
figure
heatmap(data_matrix_new)
colormap(cmap_br)


