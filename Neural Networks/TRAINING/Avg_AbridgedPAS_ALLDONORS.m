Donors = {'aa','e','m','p','v','VV','w','z'};

% Average across all donors for averaged response
% Main output: finalmeandatamatrix

AllExpts = cell(1,length(Donors));

for i = 1:length(Donors)
    traumaplts = strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\','Donor_',Donors{i},'_Abridged_PAS_1'); % Use specific rep for each donor - can do it on averaged stuff too
    load(traumaplts,'expt')
    AllExpts{i} = expt;
    clear expt
end

for j = 1:length(Donors)
    for i = 1:length(AllExpts{j}.samewells)
        datamatrix{i,j} = AllExpts{j}.samewells(i).datamean;
    end
end

meandatamatrix = cell(length(datamatrix),1);
for i = 1:length(datamatrix)
    for j = 1:size(datamatrix,2)
        allData(:,j) = datamatrix{i,j};
        for k = 1:length(allData)
            a(k) = mean(allData(k,:));
            a = a';
        end
    end
    meandatamatrix{i} = a;
end

for i = 1:length(meandatamatrix)
    finalmeandatamatrix(i,:) = meandatamatrix{i};
end

heatmap(finalmeandatamatrix);

CombinedPAS_expt = AllExpts{1};
for i = 1:length(CombinedPAS_expt.samewells)
    CombinedPAS_expt.samewells(i).datamean = finalmeandatamatrix(i,:)';
end

expt = CombinedPAS_expt;

save(strcat('C:\Users\Chris\Desktop\Chris PhD Research\Experiments\Compiled PAS Data\Abridged PAS (Trauma)\','AVG_Abridged_PAS'),'expt')
