function [datamatrix,concmatrix,meantimes] = plotHeatmaps4Trauma(expt,expt1a,expt1b,expt2a,expt2b,matrix1,matrix2)

% This script takes data from trauma Ca expts and healthy Ca expts and
% combines all the data together (to ensure the heatmap is consistent).
% First need to load the healthy expt files (save as expt1a and expt1b). Then do the same
% for the trauma data (expt2a, expt2b). Then specify the matrix1
% and matrix2 inputs as the names of the expt files for healthy. Run this
% to get two heatmaps: (1) Ca traces (2) agonist concentrations. 

%% Reconfigure the mean datasets into an appropriately formatted matrix
datamatrix1a = zeros(length(expt1a.samewells),length(expt1a.samewells(1).datamean));
for i = 1:size(datamatrix1a,1)
    datamatrix1a(i,:) = expt1a.samewells(i).datamean;
end

datamatrix1b = zeros(length(expt1b.samewells)-1,length(expt1b.samewells(1).datamean));
for i = 2:length(expt1b.samewells)
    datamatrix1b(i-1,:) = expt1b.samewells(i).datamean;
end

datamatrix1 = [datamatrix1a;datamatrix1b];

datamatrix2a = zeros(length(expt2a.samewells),length(expt2a.samewells(1).datamean));
for i = 1:size(datamatrix2a,1)
    datamatrix2a(i,:) = expt2a.samewells(i).datamean;
end

datamatrix2b = zeros(length(expt2b.samewells)-1,length(expt2b.samewells(1).datamean));
for i = 2:length(expt2b.samewells)
    datamatrix2b(i-1,:) = expt2b.samewells(i).datamean;
end

datamatrix2 = [datamatrix2a;datamatrix2b];

datamatrix = [datamatrix1;datamatrix2];

meantimes = expt.samewells(1).timemean;

% Create heatmap for "datamatrix"
figure
heatmap(datamatrix);


%% Create a concentration matrix to be similarly configured into heatmap form
file1 = strcat(expt.datadir,'\',matrix1); % Must specify date of experiment as an input
concmatrix1 = makeConcMatrix(file1); % This will need to be given a sixth column to reflect no iloprost
j = size(concmatrix1,2);
for i = 1:length(concmatrix1)
    concmatrix1(i,j+1) = -1;
end

file2 = strcat(expt.datadir,'\',matrix2); % Must specify date of experiment as an input
concmatrix2 = makeConcMatrix(file2);
% The second concmatrix only has 1xEC50 values (medium doses), so go back
% and overwrite with 1/3 whereever there is a 1
for i = 1:length(concmatrix2)
    for j = 1:size(concmatrix2,2)
        if concmatrix2(i,j) == 1
            concmatrix2(i,j) = 1/3;
        else
        end
    end
end

concmatrix = [concmatrix1;concmatrix2]; % Need to delete the second buffer row since buffer was in each expt file

index = 1;
for i = 1:length(concmatrix)-1
    avgvalues(index) = mean(concmatrix(i,:));
    if avgvalues(index)==-1 && i>1
        concmatrix(index,:) = [];
    else
    end
    index = index+1;
end

concmatrix = repmat(concmatrix,2,1);

% Create heatmap for "concmatrix" with labels
figure
heatmap(concmatrix);



