function expt = fluoroskan_labelwells(expt)

% Label the wells and put it into the field expt.samewells

if ~isempty(expt.labelfile)
    [~, ~, ext] = fileparts(expt.labelfile);
    if strcmpi(ext, '.csv') || strcmpi(ext, '.txt')
        labels = text2cell(fullfile(expt.datadir, expt.labelfile));
    elseif strcmpi(ext, '.tsv') % Tab separated value (probably never going to have one of these)
        labels = reshape(textscan(fullfile(expt.datadir, expt.labelfile), '%q', 'delimiter', '\t'), size(data,2), size(data,1))';
    else
        startcol = char(double('A')+skipped(2));
        endcol = char(double(startcol)-1+size(data,2));
        startrow = 1+skipped(1);
        endrow = startrow+size(data,1);
        labelrange = sprintf('%s%d:%s%d', startcol, startrow, endcol, endrow);
        [~, labels] = xlsread(fullfile(expt.datadir, expt.textfile), expt.labelfile, labelrange);
    end
end

if ~exist('labels', 'var')
    error('Labels were not found')
end

expt.samewells = findsame(labels);

i = 0; % Eliminate labeled wells that are empty
while i < length(expt.samewells)
    i = i+1;
    if isempty(expt.samewells(i).label)
        fprintf('   Discarding label "%s"\n', expt.samewells(i).label);
        expt.samewells = deleterowcolumn(expt.samewells, i, 2);
        i = i-1;
    end
end

end