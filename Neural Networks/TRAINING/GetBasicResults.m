function [concmatrix,data,meantimes] = GetBasicResults(regularplts)

% This script generates outputs that are required as inputs to train a NN
% model. The outputs are:
%
% concmatrix - A matrix of size MxN (where M is the number of conditions in
% the plate and N is the number of species/agonists that are present at
% varying concentrations and combinations). Values will include
% [-1,-1/3,1/3,1] where each represents 0x, 0.1x, 1x, or 10x EC50 values
% for each agonist, respectively.
% 
% data - A matrix of size MxP (where M is the number of conditions in the
% plate and P is the number of timepoints read in the FlexStation experiment).
% The data are normalized to the pre-dispense baseline such that values are
% within the range [0 1]. This is often plotted on the y-axis in heatmap
% form.
%
% meantimes - A vector of size Px1 (where P is the number of timepoints read
% in the Flexstation experiment). It averages the real time of each
% timepoint for all conditions to be able to be plotted against 'data' on
% the x-axis.

regularplatelets = load(regularplts); % Usually strcat the expt structure as 'regularplts'

[~,~,sortfields,sortmatrix] = sortstruct(regularplatelets.expt.samewells,regularplatelets.expt.sortfield);
% The above function analyzes the expt structure and outputs the species
% and their concentrations 

nSpecies = length(sortfields);

ec_vector_labels = cell(1,nSpecies);
ec_vector = zeros(1,nSpecies);

for i = 1:length(ec_vector)
    temp = sortfields{i};
    ec_vector_labels{i} = temp{2};   
switch ec_vector_labels{i}
    case {'ADP'}
    ec_vector(i) = 1e-6;
    case {'CVX'}
    ec_vector(i) = 2e-9; 
    case {'IIa'}
    ec_vector(i) = 2e-8;
    case {'U466'}
    ec_vector(i) = 1e-6;
    case {'U46619'}
    ec_vector(i) = 1e-6;
    case {'Ilo'}
    ec_vector(i) = 0.5e-6;
    case {'Epi'}
    ec_vector(i) = 2e-6;
    case {'PGE2'}
    ec_vector(i) = 20e-6;
    case {'AYPGKF'}
    ec_vector(i) = 300e-6;
    case {'AYP'}
    ec_vector(i) = 300e-6;
    case {'PAR4'}
    ec_vector(i) = 300e-6;
    case {'SFLLRN'}
    ec_vector(i) = 10e-6;
    case {'SFL'}
    ec_vector(i) = 10e-6;
    case {'PAR1'}
    ec_vector(i) = 10e-6;
    case {'GSNO'}
    ec_vector(i) = 7e-6;
    case {'A'}
    ec_vector(i) = 1e-6;
    case {'C'}
    ec_vector(i) = 2e-9; 
    case {'T'}
    ec_vector(i) = 2e-8;
    case {'U'}
    ec_vector(i) = 1e-6;
    case {'I'}
    ec_vector(i) = 0.5e-6;
    case {'G'}
    ec_vector(i) = 7e-6;
    otherwise
        error('unidentified agonist')   
end
end

sortmatrix = bsxfun(@rdivide,sortmatrix,ec_vector);

% Make sure that the unique values are 0, 0.1, 1, 10 only after the
% function above converted the values to metric scale
sortmatrix = (round(sortmatrix*1000))/1000;

% Check 1
unique_vals = unique(sortmatrix);
for i = 1:length(unique_vals)
lia = ismember(unique_vals(i),[0 0.1 1 10]);
    if lia == 0
        sortmatrix(sortmatrix == 0.04) = 0.1;
        sortmatrix(sortmatrix == 0.4) = 1;
        sortmatrix(sortmatrix == 4) = 10;        
    else
    end
end

% Check 2
%unique_vals = unique(sortmatrix);
for i = 1:length(unique_vals)
lia = ismember(unique_vals(i),[0 0.1 1 10]);
    if lia == 0       
        error('sortmatrix values is not 0, 0.1, 1 or 10')
    else
    end
end

% Find ternary conditions (probably won't be any because it's PAS)
blah = sum(sortmatrix==0,2);
whereare3 = (blah==3);

% Map the concentration to a scale from [-1 to 1]
% sortmatrix = sortmatrix(~whereare3,:); % Uncomment this if doing a PAS
P = sortmatrix/10;
P(P==0) = 0.001;
P = log10(P);
P = mapminmax(P'); % Built-in MATLAB function to map matrix row minimum and maximum values to [-1 1].

concmatrix_reg = P';

% Find the mean times by just using the buffer conditions
meantimes_reg = regularplatelets.expt.samewells(1).timemean;

% Find the mean baseline (buffer)
meanbaseline = regularplatelets.expt.samewells(1).datamean;

% Subtract the meanbaseline off of every curve
for i = 1:length(regularplatelets.expt.samewells)
    for replicatenumber = 1:size(regularplatelets.expt.samewells(i).data,2)
        alldataregular(i,replicatenumber,:) = regularplatelets.expt.samewells(i).data(:,replicatenumber)-meanbaseline;
    end
end

% Throw out the stuff which is below the mean baseline 
alldataregular(alldataregular<0)=0;

% Calculate the meandata and maxdata
meandataregular = squeeze(mean(alldataregular,2));
if sum(whereare3) > 0 % If there are any ternary conditions
    maxdataregular = max(max(meandataregular));
else
    maxdataregular = max(max(meandataregular(~whereare3,:))); % Calculate the max only using the mean curves of the double agonist combinations
end

% Delete ternaries (but there shouldn't be any)
% meandataregular = meandataregular(~whereare3,:); % Again uncomment if PAS

% Get the maximum of the entire plate and calculate the fraction of the
% maximum signal we had and NORMALIZE
allmax = max(maxdataregular);
meandataregular = meandataregular/allmax; % This is the normalization step

data_reg = meandataregular;

concmatrix = concmatrix_reg; 
data = data_reg;
meantimes = meantimes_reg;

end