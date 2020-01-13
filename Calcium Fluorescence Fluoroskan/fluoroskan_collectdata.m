function expt = fluoroskan_collectdata(expt)

% Collect the data into the expt.samewells structure

% First delete 'Blank' wells from the structure
blankwells = zeros(length(expt.samewells), 1);
for i = 1:length(expt.samewells)
    blankwells(i,1) = strcmp(expt.samewells(1,i).label, 'Blank');
end
expt.samewells(find(blankwells)) = [];

% Find each different condition and compile its data but do all of the same
% conditions separately since they will all be of a different count
bufferwells = find(expt.samewells(1).map); % Do buffer condition first because it is always first in plate
if strcmpi(expt.addpredispensebaseline,'y')
    expt.samewells(1).data = zeros(size(expt.dataarray,1)+8,length(bufferwells));
    expt.samewells(1).time = zeros(size(expt.timearray,1)+8,length(bufferwells));
else
    expt.samewells(1).data = zeros(size(expt.dataarray,1),length(bufferwells));
    expt.samewells(1).time = zeros(size(expt.timearray,1),length(bufferwells));
end

for i = 1:length(bufferwells)
    if strcmpi(expt.addpredispensebaseline,'y')
        expt.samewells(1).data(1:8,i) = expt.dataarray(1:8,i);
        expt.samewells(1).data(9:end,i) = expt.dataarray(:,i);
        expt.samewells(1).time(1:8,i) = expt.timearray(1:8,i);
        expt.samewells(1).time(9:end,i) = expt.timearray(:,i)+20;
    else
        expt.samewells(1).data(:,i) = expt.dataarray(:,i);
        expt.samewells(1).time(:,i) = expt.timearray(:,i);
    end
end

count = length(bufferwells)+1; % Now do the other non-buffer conditions
for i = 2:length(expt.samewells)
    numwells = length(find(expt.samewells(i).map));
    if strcmpi(expt.addpredispensebaseline,'y')
        expt.samewells(i).data = zeros(size(expt.dataarray,1)+8,numwells);
        expt.samewells(i).time = zeros(size(expt.timearray,1)+8,numwells);
    else
        expt.samewells(i).data = zeros(size(expt.dataarray,1),numwells);
        expt.samewells(i).time = zeros(size(expt.timearray,1),numwells);
    end
    
    for j = 1:numwells
        if strcmpi(expt.addpredispensebaseline,'y')
            expt.samewells(i).data(1:8,j) = expt.dataarray(1:8,1);
            expt.samewells(i).data(9:end,j) = expt.dataarray(:,count);
            expt.samewells(i).time(1:8,j) = expt.timearray(1:8,count);
            expt.samewells(i).time(9:end,j) = expt.timearray(:,count)+20;
            count = count+1;
        else
            expt.samewells(i).data(:,j) = expt.dataarray(:,count);
            expt.samewells(i).time(:,j) = expt.timearray(:,count);
            count = count+1;
        end
    end
end

end


