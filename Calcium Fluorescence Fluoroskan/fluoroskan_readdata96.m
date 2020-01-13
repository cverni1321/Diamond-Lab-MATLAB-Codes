% Read Fluoroskan experiment data and tabulate (must input the filename for
% each unique experiment)

function expt = fluoroskan_readdata96(expt)
%% Read in the data from the Excel file
filename = expt.textfile;
num = xlsread(filename);

%% Start to create the skeleton of the final data matrix
initial = num(4:11,1:12);
numConditions = sum(sum(~isnan(initial)));
numPoints = (length(num)-1)/10;
data = zeros(numPoints,numConditions);
time = zeros(numPoints,numConditions);

%% Reorganize the data from Excel into columns for each condition
for j = 1:numConditions
    for i = 1:numPoints
        if (j <= 8)
            cell = j+3+10*(i-1); % cell is the cell number from the Excel sheet
            data(i,j) = num(cell,1);
        elseif (j > 8) && (j <= 16)
            cell = (j-8)+3+10*(i-1);
            data(i,j) = num(cell,2);
        elseif (j > 16) && (j <= 24)
            cell = (j-16)+3+10*(i-1);
            data(i,j) = num(cell,3);
        elseif (j > 24) && (j <= 32)
            cell = (j-24)+3+10*(i-1);
            data(i,j) = num(cell,4);
        elseif (j > 32) && (j <= 40)
            cell = (j-32)+3+10*(i-1);
            data(i,j) = num(cell,5);
        elseif (j > 40) && (j <= 48)
            cell = (j-40)+3+10*(i-1);
            data(i,j) = num(cell,6);
        elseif (j > 48) && (j <= 56)
            cell = (j-48)+3+10*(i-1);
            data(i,j) = num(cell,7);
        elseif (j > 56) && (j <= 64)
            cell = (j-56)+3+10*(i-1);
            data(i,j) = num(cell,8);
        elseif (j > 64) && (j <= 72)
            cell = (j-64)+3+10*(i-1);
            data(i,j) = num(cell,9);
        elseif (j > 72) && (j <= 80)
            cell = (j-72)+3+10*(i-1);
            data(i,j) = num(cell,10);
        elseif (j > 80) && (j <= 88)
            cell = (j-80)+3+10*(i-1);
            data(i,j) = num(cell,11);
        elseif (j > 88) && (j <= 96)
            cell = (j-88)+3+10*(i-1);
            data(i,j) = num(cell,12);
        else 
            error('The number of conditions exceeds the number of wells in the plate')
        end
    end
end
expt.dataarray = data;

%% Align the times into an identical matrix as data
for j = 1:numConditions
    for i = 1:numPoints
        if (j <= 8)
            cell = j+3+10*(i-1); % range is the cell number from the Excel sheet
            time(i,j) = num(cell,15);
        elseif (j > 8) && (j <= 16)
            cell = (j-8)+3+10*(i-1);
            time(i,j) = num(cell,16);
        elseif (j > 16) && (j <= 24)
            cell = (j-16)+3+10*(i-1);
            time(i,j) = num(cell,17);
        elseif (j > 24) && (j <= 32)
            cell = (j-24)+3+10*(i-1);
            time(i,j) = num(cell,18);
        elseif (j > 32) && (j <= 40)
            cell = (j-32)+3+10*(i-1);
            time(i,j) = num(cell,19);
        elseif (j > 40) && (j <= 48)
            cell = (j-40)+3+10*(i-1);
            time(i,j) = num(cell,20);
        elseif (j > 48) && (j <= 56)
            cell = (j-48)+3+10*(i-1);
            time(i,j) = num(cell,21);
        elseif (j > 56) && (j <= 64)
            cell = (j-56)+3+10*(i-1);
            time(i,j) = num(cell,22);
        elseif (j > 64) && (j <= 72)
            cell = (j-64)+3+10*(i-1);
            time(i,j) = num(cell,23);
        elseif (j > 72) && (j <= 80)
            cell = (j-72)+3+10*(i-1);
            time(i,j) = num(cell,24);
        elseif (j > 80) && (j <= 88)
            cell = (j-80)+3+10*(i-1);
            time(i,j) = num(cell,25);
        elseif (j > 88) && (j <= 96)
            cell = (j-88)+3+10*(i-1);
            time(i,j) = num(cell,26);
        else 
            error('The number of conditions exceeds the number of wells in the plate')
        end
    end
end
expt.timearray = time;

            