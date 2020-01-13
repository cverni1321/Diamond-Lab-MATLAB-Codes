function expt = fluoroskan_normalizedata2(expt)

% Normalize the data for each well from a fluoroskan expt by the first
% point of each condition

for i = 1:length(expt.samewells)
    for j = 1:size(expt.samewells(i).data,2)
        expt.samewells(i).normalizeddata(:,j) = expt.samewells(i).data(:,j)./expt.samewells(i).data(1,j);
    end
end