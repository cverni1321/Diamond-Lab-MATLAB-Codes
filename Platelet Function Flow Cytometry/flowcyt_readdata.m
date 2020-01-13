% Read Accuri experiment data and tabulate (must input the filename for
% each unique experiment)

function expt = flowcyt_readdata(expt)
%% Read in the data from the Excel file
filename = expt.xlsfile;
[~,~,raw] = xlsread(filename);

%% Start to create the skeleton of the final data matrix by deleting unnecessary data and gathering reps of same conditions
for i=1:length(expt.samewells)
    expt.samewells(i).alldata = {};
end

for i=1:13:size(raw,1) % Depending on what you are reading will have to change the interval (PAS-FC: interval = 32)
    wellID = raw{i,1}(9:11);
    for j=1:length(expt.samewells)
        k = strfind(expt.samewells(j).positionsnew(:,3),wellID);
        if ~isempty(cell2mat(k))
            break
        else
            continue
        end
    end
    condition_index = j;
    alldata = raw(i:i+8,:); % Again the range of data for each well will vary (check XLS file and adjust accordingly)
   
    if isempty(expt.samewells(condition_index).alldata)
        expt.samewells(condition_index).alldata = alldata;
    else
        expt.samewells(condition_index).alldata = [expt.samewells(condition_index).alldata; alldata];
    end
end



            