% Read Fluoroskan experiment data and tabulate (must input the filename for
% each unique experiment)

function expt = fluoroskan_readdata384(expt)
%% Read in the data from the Excel file
filename = expt.textfile;
num = xlsread(filename);

%% Start to create the skeleton of the final data matrix
initial = num(4:19,1:24);
numConditions = sum(sum(~isnan(initial)));
numPoints = (length(num)-1)/18;
data = zeros(numPoints,numConditions);
time = zeros(numPoints,numConditions);

%% Reorganize the data from Excel into columns for each condition
for j = 1:numConditions
    for i = 1:numPoints
        if (j <= 16)
            cell = j+3+18*(i-1); % cell is the cell number from the Excel sheet
            data(i,j) = num(cell,1);
        elseif (j > 16) && (j <= 32)
            cell = (j-16)+3+18*(i-1);
            data(i,j) = num(cell,2);
        elseif (j > 32) && (j <= 48)
            cell = (j-32)+3+18*(i-1);
            data(i,j) = num(cell,3);
        elseif (j > 48) && (j <= 64)
            cell = (j-48)+3+18*(i-1);
            data(i,j) = num(cell,4);
        elseif (j > 64) && (j <= 80)
            cell = (j-64)+3+18*(i-1);
            data(i,j) = num(cell,5);
        elseif (j > 80) && (j <= 96)
            cell = (j-80)+3+18*(i-1);
            data(i,j) = num(cell,6);
        elseif (j > 96) && (j <= 112)
            cell = (j-96)+3+18*(i-1);
            data(i,j) = num(cell,7);
        elseif (j > 112) && (j <= 128)
            cell = (j-112)+3+18*(i-1);
            data(i,j) = num(cell,8);
        elseif (j > 128) && (j <= 144)
            cell = (j-128)+3+18*(i-1);
            data(i,j) = num(cell,9);
        elseif (j > 144) && (j <= 160)
            cell = (j-144)+3+18*(i-1);
            data(i,j) = num(cell,10);
        elseif (j > 160) && (j <= 176)
            cell = (j-160)+3+18*(i-1);
            data(i,j) = num(cell,11);
        elseif (j > 176) && (j <= 192)
            cell = (j-176)+3+18*(i-1);
            data(i,j) = num(cell,12);
        elseif (j > 192) && (j <= 208)
            cell = (j-192)+3+18*(i-1);
            data(i,j) = num(cell,13);
        elseif (j > 208) && (j <= 224)
            cell = (j-208)+3+18*(i-1);
            data(i,j) = num(cell,14);
        elseif (j > 224) && (j <= 240)
            cell = (j-224)+3+18*(i-1);
            data(i,j) = num(cell,15);
        elseif (j > 240) && (j <= 256)
            cell = (j-240)+3+18*(i-1);
            data(i,j) = num(cell,16);
        elseif (j > 256) && (j <= 272)
            cell = (j-256)+3+18*(i-1);
            data(i,j) = num(cell,17);
        elseif (j > 272) && (j <= 288)
            cell = (j-272)+3+18*(i-1);
            data(i,j) = num(cell,18);
        elseif (j > 288) && (j <= 304)
            cell = (j-288)+3+18*(i-1);
            data(i,j) = num(cell,19);
        elseif (j > 304) && (j <= 320)
            cell = (j-304)+3+18*(i-1);
            data(i,j) = num(cell,20);
        elseif (j > 320) && (j <= 336)
            cell = (j-320)+3+18*(i-1);
            data(i,j) = num(cell,21);
        elseif (j > 336) && (j <= 352)
            cell = (j-336)+3+18*(i-1);
            data(i,j) = num(cell,22);
        elseif (j > 352) && (j <= 368)
            cell = (j-352)+3+18*(i-1);
            data(i,j) = num(cell,23);
        elseif (j > 368) && (j <= 384)
            cell = (j-368)+3+18*(i-1);
            data(i,j) = num(cell,24);
        else 
            error('The number of conditions exceeds the number of wells in the plate')
        end
    end
end
expt.dataarray = data;


%% Align the times into an identical matrix as data
for j = 1:numConditions
    for i = 1:numPoints
        if (j <= 16)
            cell = j+3+18*(i-1); % cell is the cell number from the Excel sheet
            time(i,j) = num(cell,27);
        elseif (j > 16) && (j <= 32)
            cell = (j-16)+3+18*(i-1);
            time(i,j) = num(cell,28);
        elseif (j > 32) && (j <= 48)
            cell = (j-32)+3+18*(i-1);
            time(i,j) = num(cell,29);
        elseif (j > 48) && (j <= 64)
            cell = (j-48)+3+18*(i-1);
            time(i,j) = num(cell,30);
        elseif (j > 64) && (j <= 80)
            cell = (j-64)+3+18*(i-1);
            time(i,j) = num(cell,31);
        elseif (j > 80) && (j <= 96)
            cell = (j-80)+3+18*(i-1);
            time(i,j) = num(cell,32);
        elseif (j > 96) && (j <= 112)
            cell = (j-96)+3+18*(i-1);
            time(i,j) = num(cell,33);
        elseif (j > 112) && (j <= 128)
            cell = (j-112)+3+18*(i-1);
            time(i,j) = num(cell,34);
        elseif (j > 128) && (j <= 144)
            cell = (j-128)+3+18*(i-1);
            time(i,j) = num(cell,35);
        elseif (j > 144) && (j <= 160)
            cell = (j-144)+3+18*(i-1);
            time(i,j) = num(cell,36);
        elseif (j > 160) && (j <= 176)
            cell = (j-160)+3+18*(i-1);
            time(i,j) = num(cell,37);
        elseif (j > 176) && (j <= 192)
            cell = (j-176)+3+18*(i-1);
            time(i,j) = num(cell,38);
        elseif (j > 192) && (j <= 208)
            cell = (j-192)+3+18*(i-1);
            time(i,j) = num(cell,39);
        elseif (j > 208) && (j <= 224)
            cell = (j-208)+3+18*(i-1);
            time(i,j) = num(cell,40);
        elseif (j > 224) && (j <= 240)
            cell = (j-224)+3+18*(i-1);
            time(i,j) = num(cell,41);
        elseif (j > 240) && (j <= 256)
            cell = (j-240)+3+18*(i-1);
            time(i,j) = num(cell,42);
        elseif (j > 256) && (j <= 272)
            cell = (j-256)+3+18*(i-1);
            time(i,j) = num(cell,43);
        elseif (j > 272) && (j <= 288)
            cell = (j-272)+3+18*(i-1);
            time(i,j) = num(cell,44);
        elseif (j > 288) && (j <= 304)
            cell = (j-288)+3+18*(i-1);
            time(i,j) = num(cell,45);
        elseif (j > 304) && (j <= 320)
            cell = (j-304)+3+18*(i-1);
            time(i,j) = num(cell,46);
        elseif (j > 320) && (j <= 336)
            cell = (j-320)+3+18*(i-1);
            time(i,j) = num(cell,47);
        elseif (j > 336) && (j <= 352)
            cell = (j-336)+3+18*(i-1);
            time(i,j) = num(cell,48);
        elseif (j > 352) && (j <= 368)
            cell = (j-352)+3+18*(i-1);
            time(i,j) = num(cell,49);
        elseif (j > 368) && (j <= 384)
            cell = (j-368)+3+18*(i-1);
            time(i,j) = num(cell,50);
        else 
            error('The number of conditions exceeds the number of wells in the plate')
        end
    end
end
expt.timearray = time;

            