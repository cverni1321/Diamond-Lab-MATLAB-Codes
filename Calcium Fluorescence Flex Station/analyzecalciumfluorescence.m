function [varargout] = analyzecalciumfluorescence(expt,query)

% This code will analyze the signal from an experiment run in a well plate
% on a Molecular Devices FlexStation 3.
%
% See FA_setupexperiment for an explanation of the fields used in the expt
% structure.
%
% Query: Enter analyzefluorecense(expt,1) if you want to use the same
% defaults without having to enter the inputs again and again

% .csv label files cannot start with blank columns, so make sure that
% empty columns preceding actual data are labeled 'Blank' in the .csv label
% file. expt.samewells with the label 'Blank' will be deleted
% automatically. Buffer wells will be determined by the
% expt.samewells.label that is named 'Buffer'. Make sure buffer wells are
% labeled 'Buffer' in .csv label files.

% Enter all the inputs again
if nargin < 1
    expt = struct(); query = 0;
end

if query ~=1 && nargin ~=0
    error('The value of query (the second input after expt) must be 1 if you are trying to use the same input values as before');
end

% Pop up the window to enter the default answers
expt = AF_setupexperiment(expt, query);

% Read in the data
% NOTE: 'rawdata' contains the data only for the reading portion; 'data'
% has the data concatanated with the data from the normalizing also

[data, rawdata, times, mindata, maxdata, skipped, expt, totalrawdata, totaltimes] = AF_readdata(expt);

% Label the wells
expt = AF_labelwells(expt, data, skipped);

% Collect all the data together and setup the expt structure with all the
% necessary information
expt = AF_collectdata(expt, data, times, rawdata, mindata, maxdata, totalrawdata, totaltimes);

% Average the data and times for each well type
expt = AF_averagedata(expt);

% Calculate important parameters from the data
expt = AF_calcdata(expt);

% Sort the experiment by agonist concentrations and apply multipliers for
% different concentration units
expt = AF_setconcs(expt);

if isfield(expt.samewells(1), 'conc')
    expt.samewells = normalizestruct(expt.samewells, 'conc', 0);
end

if ~isempty(expt.sortfield) 
    [expt.samewells, ~, sortfields, ~] = sortstruct(expt.samewells, expt.sortfield);
end

if exist('sortfields', 'var')
    expt.nspecies = length(sortfields);
end

% Delete wells labeled 'Blank'
blankwells = zeros(length(expt.samewells), 1);
for i = 1:length(expt.samewells)
    blankwells(i,1) = strcmp(expt.samewells(1,i).label, 'Blank');
end
expt.samewells(find(blankwells)) = [];

% Get a list of wells
expt.listwells = cell(length(expt.samewells), 1);
for i = 1:length(expt.samewells)
    expt.listwells{i} = expt.samewells(1,i).label;
end

% Update control well
controlwells = zeros(length(expt.samewells), 1);
for i = 1:length(expt.samewells)
    controlwells(i,1) = strcmpi(expt.samewells(1,i).label, 'Buffer');
end
expt.whereiscontrol = find(controlwells);

% Correct the data for dispense artifacts if necessary
expt.dispensecorrection
if strcmp(expt.dispensecorrection, 'y')
    expt = fixDispenseArtifact1(expt);
end
if strcmp(expt.dispensecorrection, 'yy')
    expt = fixDispenseArtifact1(expt);
    expt = fixDispenseArtifact2(expt);
end
if strcmp(expt.dispensecorrection, 'yyy')
    expt = fixDispenseArtifact1(expt);
    expt = fixDispenseArtifact2(expt);
    expt = fixDispenseArtifact3(expt);
end

% Smooth the data if called to do so
if expt.smoothdata == 'y';
    for i=1:length(expt.samewells)
        expt.samewells(i).datamean = smooth(expt.samewells(i).datamean);
        expt.samewells(i).datastd = smooth(expt.samewells(i).datastd);
    end
end

% Save all the data
ddmmyy = date;
savefile = fullfile(expt.datadir, strcat(ddmmyy, '.mat'));
save(savefile, 'expt')

% expt = AF_plotsamewells(expt); % Turn these off when using flexplot
% expt = AF_plotsamewellsmeans(expt);


if nargout > 0
    varargout{1} = expt;
end

end