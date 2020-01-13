function expt = fluoroskan_normalizedata2(expt)

% Normalize the data for each well from a fluoroskan expt by the first
% point of each condition

avgbuffer = mean(expt.samewells(1).data,2);
for i = 1:length(expt.samewells)
    for j = 1:size(expt.samewells(i).data,2)
        expt.samewells(i).normalizeddata(:,j) = expt.samewells(i).data(:,j)./avgbuffer(:);
    end
end