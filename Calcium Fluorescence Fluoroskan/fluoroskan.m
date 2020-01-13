function [varargout] = fluoroskan(expt,query)

% This code will analyze the signal from an experiment run in a well plate
% on the Fluoroskan Ascent plate reader.
%
% See fluoroskan_setupexperiment for an explanation of the fields used in the expt
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
expt = fluoroskan_setupexperiment(expt, query);

% Read in the data
if expt.nwells == 96
    expt = fluoroskan_readdata96(expt);
elseif expt.nwells == 384
    expt = fluoroskan_readdata384(expt);
end

% Label the wells
expt = fluoroskan_labelwells(expt);

% Collect the data and compile in samewells structure
expt = fluoroskan_collectdata(expt);

% Normalize the data by the first point in each well
if strcmpi(expt.normalize, 'y')
    expt = fluoroskan_normalizedata2(expt);
else
    for i = 1:length(expt.samewells)
        expt.samewells(i).normalizeddata = expt.samewells(i).data;
    end
end

% Average the data and times for each well type
expt = fluoroskan_averagedata(expt);

% Find the integrated area under each curve (and average)
for i = 1:length(expt.samewells)
    expt.samewells(i).integratedarea.areas = trapz(expt.samewells(i).data);
    expt.samewells(i).integratedarea.avgarea = nanmean(expt.samewells(i).integratedarea.areas);
end

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
if expt.dispensecorrection == 'y';
    expt = fluoroskan_fixDispenseArtifact(expt);
end

%if expt.addpredispensebaseline == 'y';
%    expt = fluoroskan_addPredispenseBaseline(expt);
%end

% Save all the data
ddmmyy = date;
savefile = fullfile(expt.datadir, strcat(ddmmyy, '.mat'));
save(savefile, 'expt')

if nargout > 0
    varargout{1} = expt;
end

end