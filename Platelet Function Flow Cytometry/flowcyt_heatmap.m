function flowcyt_heatmap(expt)

% This script will plot MFI values in heatmap form

%% First gather the average values into one vector
totalMFIdata = zeros(length(expt.samewells)*2,1);
for i=1:length(expt.samewells)
    FL1MFI(i) = expt.samewells(i).FL1MFI_avg(1,1);
    FL2MFI(i) = expt.samewells(i).FL2MFI_avg(1,1);
    FL4percpos(i) = expt.samewells(i).FL4percpos_avg(1,1);
end
totalMFIdata = [FL1MFI'; FL2MFI'];

figure
heatmap(totalMFIdata)
colorbar

figure
heatmap(FL4percpos')
colorbar


%% Next make the concmatrix and heatmap
concmatrix = zeros(length(expt.samewells),6);
for i=1:length(expt.samewells)
    if ~isempty(strfind(expt.samewells(i).label, 'Buffer'))
        continue
    end
    if ~isempty(strfind(expt.samewells(i).label, 'A|'))
        concmatrix(i,1) = 1;
    end
    if ~isempty(strfind(expt.samewells(i).label, 'C|'))
        concmatrix(i,2) = 1;
    end
    if ~isempty(strfind(expt.samewells(i).label, 'U|'))
        concmatrix(i,3) = 1;
    end
    if ~isempty(strfind(expt.samewells(i).label, 'SFL|'))
        concmatrix(i,4) = 1;
    end
    if ~isempty(strfind(expt.samewells(i).label, 'AYP|'))
        concmatrix(i,5) = 1;
    end
    if ~isempty(strfind(expt.samewells(i).label, 'Ilo|'))
        concmatrix(i,6) = 1;
    end
end

figure
heatmap(concmatrix)
