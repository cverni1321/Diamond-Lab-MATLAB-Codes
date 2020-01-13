function expt = flowcyt_averagedata(expt)

% First initialize the other fields we are going to track (each will have
% average and std)
for i=1:length(expt.samewells)
    expt.samewells(i).count = zeros(size(expt.samewells(i).positionsnew,1),1);
    expt.samewells(i).count_avg = zeros(1,size(expt.samewells(i).positionsnew,1));
    expt.samewells(i).FL1MFI = zeros(size(expt.samewells(i).positionsnew,1),1); % This is in Column 6
    expt.samewells(i).FL1MFI_avg = zeros(1,size(expt.samewells(i).positionsnew,1));
    expt.samewells(i).FL1CV = zeros(size(expt.samewells(i).positionsnew,1),1); % This is in Column 7
    expt.samewells(i).FL1CV_avg = [];
    expt.samewells(i).FL2MFI = zeros(size(expt.samewells(i).positionsnew,1),1); % This is in Column 6
    expt.samewells(i).FL2MFI_avg = zeros(1,size(expt.samewells(i).positionsnew,1));
    expt.samewells(i).FL2CV = zeros(size(expt.samewells(i).positionsnew,1),1); % This is in Column 7
    expt.samewells(i).FL2CV_avg = [];
    expt.samewells(i).FL4percpos = zeros(size(expt.samewells(i).positionsnew,1),1); % This is in Column 4
    expt.samewells(i).FL4percpos_avg = zeros(1,size(expt.samewells(i).positionsnew,1));
end


% Next go through each condition and pull out the reps of each result
for i=1:length(expt.samewells) % 'Count' data
    expt.samewells(i).alldata(cellfun(@(C) isnumeric(C) && isnan(C), expt.samewells(i).alldata(:,1)),:) = [];
    index = 0;
    for j=1:size(expt.samewells(i).alldata,1)
        if strcmp(expt.samewells(i).alldata{j,1}(1:2),'Pl')
            index = index+1;
            expt.samewells(i).count(index) = expt.samewells(i).alldata{j+1,2};
        else
            continue
        end
    end
    expt.samewells(i).count = unique(expt.samewells(i).count,'stable');
end

for i=1:length(expt.samewells) % FL1 data (act. IIbIIIa)
    index = 0;
    for j=1:size(expt.samewells(i).alldata,1)
        if strcmp(expt.samewells(i).alldata{j,1}(1:2),'Pl') && strcmp(expt.samewells(i).alldata{j,6},'Mean FL1-H')
            index = index+1;
            expt.samewells(i).FL1MFI(index) = expt.samewells(i).alldata{j+1,6};
            expt.samewells(i).FL1CV(index) = expt.samewells(i).alldata{j+1,7};
        else
            continue
        end
    end
end

for i=1:length(expt.samewells) % FL2 data (P-selectin)
    index = 0;
    for j=1:size(expt.samewells(i).alldata,1)
        if strcmp(expt.samewells(i).alldata{j,1}(1:2),'Pl') && strcmp(expt.samewells(i).alldata{j,6},'Mean FL2-H')
            index = index+1;
            expt.samewells(i).FL2MFI(index) = expt.samewells(i).alldata{j+1,6};
            expt.samewells(i).FL2CV(index) = expt.samewells(i).alldata{j+1,7};
        else
            continue
        end
    end
end
            
for i=1:length(expt.samewells) % FL4 data (% Annexin V +)
    index = 0;
    for j=1:size(expt.samewells(i).alldata,1)
        if strcmp(expt.samewells(i).alldata{j,1}(1:2),'Pl') && strcmp(expt.samewells(i).alldata{j,6},'Mean FL4-H')
            index = index+1;
            expt.samewells(i).FL4percpos(index) = expt.samewells(i).alldata{j+3,4}*100;
        else
            continue
        end
    end
end

% Calculate average and std
for i=1:length(expt.samewells)
    expt.samewells(i).count_avg(1,1) = mean(expt.samewells(i).count);
    expt.samewells(i).count_avg(1,2) = std(expt.samewells(i).count);
    expt.samewells(i).FL1MFI_avg(1,1) = mean(expt.samewells(i).FL1MFI);
    expt.samewells(i).FL1MFI_avg(1,2) = std(expt.samewells(i).FL1MFI);
    expt.samewells(i).FL1CV_avg = mean(expt.samewells(i).FL1CV);
    expt.samewells(i).FL2MFI_avg(1,1) = mean(expt.samewells(i).FL2MFI);
    expt.samewells(i).FL2MFI_avg(1,2) = std(expt.samewells(i).FL2MFI);
    expt.samewells(i).FL2CV_avg = mean(expt.samewells(i).FL2CV);
    expt.samewells(i).FL4percpos_avg(1,1) = mean(expt.samewells(i).FL4percpos);
    expt.samewells(i).FL4percpos_avg(1,2) = std(expt.samewells(i).FL4percpos);
end 
    


end