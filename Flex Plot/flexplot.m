function flexplot(expt, flag, errorflag)

% Plots the data imported and analyzed from the SoftMax Pro software. This
% works with any data conforming to the 'expt' data structure.
%
% flag      - 0 refers to plotting compiled/normalized data (expt.samewells.data)
%             1 refers to plotting raw data (expt.samewells.rawdata)
% errorflag - 0 refers to plotting without error bars for mean data
%             1 refers to plotting with error bars


if nargin == 1
    flag = 0;
end

if nargin < 3
    errorflag = 1;
end

tmppath = mfilename('fullpath');
list = strfind(tmppath, '\');
functionpath = tmppath(1:list(end) - 1);
filelist = what(functionpath);
saveme = strcat(functionpath, '\colors.mat'); 
    % colors.mat stores a list of default colors to use. Loading the
    % colormap rather than generating it with another m-file saves time.

if isempty(filelist.mat) || ~strcmp('colors.mat', filelist.mat)
    colors = distinguishable_colors(24);
    save(saveme, 'colors')
else
    load(saveme)
end

% Convert well information into correct format for flexplot and start
% gathering info
handle = 'SBplot_for_flex'; % Filename for plotting function
numwells = length(expt.samewells);
timepoints = length(expt.samewells(1).datamean(:,1));
welltags = num2cell(zeros(1, numwells));
meandata = zeros(timepoints, numwells);
meanrawdata = meandata;
meantime = meandata;
datastd = meandata;
rawstd = meandata;
replicates = zeros(1, length(expt.samewells)); % Sometimes different wells have different numbers of repeats

for i = 1:length(expt.samewells)
    welltags{i} = expt.samewells(i).label;
    replicates(i) = size(expt.samewells(i).data, 2);
    for j = 1:replicates(i)
        data(:,i,j) = expt.samewells(i).data(:,j);
        rawdata(:,i,j) = expt.samewells(i).data(:,j);
        time(:,i,j) = expt.samewells(i).time(:,j);
        meandata(:,i) = expt.samewells(i).datamean;
        meantime(:,i) = expt.samewells(i).timemean;
        datastd(:,i) = expt.samewells(i).datastd;
    end
end

% Initialize the structures
maxreplicates = max(replicates);
for i = 1:maxreplicates
    str = strcat('rep', num2str(i));
    main.(str).name = str;
    main.(str).marker = '-';
    main.(str).datanames = welltags(replicates>=i); % Only record wells that have i (or more) replicates
    
    if flag == 0
        main.(str).data = data(:,replicates>=i,i);
    else
        main.(str).data = rawdata(:,replicates>=i,i);
    end
    
    main.(str).time = time(:,replicates>=i,i);
    main.(str).legendtext = main.(str).datanames;
    main.(str).errorindices = [];
    main.(str).minvalues = [];
    main.(str).maxvalues = [];
    main.(str).skipthese = [];
    main.(str).colorvector = colors;
    
    if i == 1
        structlist = str;
    else
        structlist = strcat(structlist, ',', str); % Comma-separated list of structure fields for passing to flexplot
    end
end

main.mean.name = 'Averaged Reps';
main.mean.marker = '-';
main.mean.datanames = welltags;

if flag == 0
    main.mean.data = meandata;
    main.mean.minvalues = main.mean.data - datastd/2;
    main.mean.maxvalues = main.mean.data + datastd/2;
else
    main.mean.data = meanrawdata;
    main.mean.minvalues = main.mean.data - rawstd/2;
    main.mean.maxvalues = main.mean.data + rawstd/2;
end

main.mean.time = meantime;
main.mean.legendtext = main.mean.datanames;

if errorflag
    main.mean.errorindices = 1:numwells;
else
    main.mean.errorindices = [];
end

main.mean.skipthese = 5;
main.mean.colorvector = colors;
structlist = strcat(structlist, ',', 'mean');


s = main;
cellfun(@(n,v) assignin('caller', n, v), fieldnames(s), struct2cell(s));
input = strcat(handle, '(',structlist,')');

% Make the plot window
eval(input)

end