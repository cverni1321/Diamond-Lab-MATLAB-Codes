function [ProcessedTimes,ProcessedData,UsableTimes,UsableData,UsableConcs,SingleMatrixOfUsableConcs,SingleMatrixOfUsableData] = InterpolateData(concmatrix,data,meantimes)

% This script interpolates times to get data at 1 second intervals


% Inputs (all from GetBasicResults m-file):

% concmatrix - A matrix of size MxN (where M is the number of conditions in
% the plate and N is the number of species/agonists that are present at
% varying concentrations and combinations). Values will include
% [-1,-1/3,1/3,1] where each represents 0x, 0.1x, 1x, or 10x EC50 values
% for each agonist, respectively.

% data - A matrix of size MxP (where M is the number of conditions in the
% plate and P is the number of timepoints read in the FlexStation experiment).
% The data are normalized to the pre-dispense baseline such that values are
% within the range [0 1]. This is often plotted on the y-axis in heatmap
% form.

% meantimes - A vector of size Px1 (where P is the number of timepoints read
% in the Flexstation experiment). It averages the real time of each
% timepoint for all conditions to be able to be plotted against 'data' on
% the x-axis.


% Outputs (to be used in the SetUpNNModel m-file):

% ProcessedTimes - Vector of times at which the values are reported (0:end)
% ProcessedData - Interpolated data at these instants
% UsableTimes - Vector of times to actually use (-endtime.....0.....endtime)
% UsableData - Matrix of data with 0s behind t=0 for the data
% UsableConcs- Matrix of concmatrix with concentrations in a form that
% accounts for the total duration of the signal experiment and tapped delay
% line
% (These last three things were just to account for the tapped delay lines)
% SingleMatrixOfUsableConcs- Conc Matrix in a form consistent with the NN
% toolbox
% SingleMatrixOfUsableData- Matrix of Data (Not used)

% First let us put in artificially that the value of the response is 0 at time = 0
ProcesedTimes = cat(1,0,meantimes);
dummy = zeros(size(data,1),1);
ProcesedData = cat(2,dummy,data);

times2use = 0:1:ceil(ProcesedTimes(end));
UsableTimes = -ceil(ProcesedTimes(end)):1:ceil(ProcesedTimes(end)); % UsableTimes is 1x525

% Set up the matrix to contain the data
dummy = NaN(size(data,1),length(times2use));
for  i = 1:size(data,1)
    dummy(i,:) = interp1(ProcesedTimes,ProcesedData(i,:),times2use,...
        'linear','extrap'); % Interpolate the data at one-second intervals
end

ProcessedTimes = times2use; %(1x260 double, which is 0 to 259)
ProcessedData = dummy; %(154x260 double)

% Make Usableconcmatrix
totaltimesteps = length(UsableTimes);
actualstepofdispense = ((totaltimesteps+1)/2)+20;%Because dispense happens at 20s
concmatrix_before_dispense = -1*ones(size(concmatrix'));
concmatrix_after_dispense = concmatrix';

for i = 1:actualstepofdispense
    UsableConcs{i} = concmatrix_before_dispense;
end

for i = actualstepofdispense:length(UsableTimes)
    UsableConcs{i} = concmatrix_after_dispense;
end

% Make UsableData (important for next step of NNModel)
SingleMatrixOfUsableData = NaN(length(UsableTimes),size(concmatrix,1));

for i = 1:length(UsableTimes)
    superdummy = [];
    for j = 1:size(concmatrix,1)
        if UsableTimes(i)<0
            superdummy(j) = 0;
        else
            superdummy(j) = ProcessedData(j,UsableTimes(i)+1);
        end
    end
    UsableData{i} = superdummy; % Data at time instant i
    clear superdummy
end

SingleMatrixOfUsableConcs = concmatrix';

end

