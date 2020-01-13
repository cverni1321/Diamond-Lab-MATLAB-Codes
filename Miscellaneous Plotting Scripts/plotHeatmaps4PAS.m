function datamatrix = plotHeatmaps4PAS(expt,matrix,datadir)
% Define matrix as the filename of the Ca data
% Define datadir as directory where the data is

%% Reconfigure the mean datasets into an appropriately formatted matrix
datamatrix = zeros(length(expt.samewells),length(expt.samewells(1).datamean));
for i = 1:size(datamatrix,1)
    datamatrix(i,:) = expt.samewells(i).datamean;
end

% Create heatmap for "datamatrix"
figure
heatmap(datamatrix);

%% Create a concentration matrix to be similarly configured into heatmap form
file = strcat(datadir,'\',matrix); % Must specify date of experiment as an input
concmatrix = makeConcMatrix(file); 

% Create heatmap for "concmatrix" with labels
figure
heatmap(concmatrix);
