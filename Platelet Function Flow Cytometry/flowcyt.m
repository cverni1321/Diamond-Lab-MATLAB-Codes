function [varargout] = flowcyt(expt,query)

% This code will analyze the data from an experiment run in a well plate
% on the Accuri flow cytometer.
%
% See flowcytometer_setupexperiment for an explanation of the fields used in the expt
% structure.

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
expt = flowcyt_setupexperiment(expt, query);

% Label the wells
expt = flowcyt_labelwells(expt);

% Read in the data
expt = flowcyt_readdata(expt);

% Average the data and times for each well type
expt = flowcyt_averagedata(expt);

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

% Save all the data
ddmmyy = date;
savefile = fullfile(expt.datadir, strcat(ddmmyy, '.mat'));
save(savefile, 'expt')

if nargout > 0
    varargout{1} = expt;
end


end