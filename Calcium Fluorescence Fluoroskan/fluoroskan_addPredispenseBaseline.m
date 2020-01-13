function expt = fluoroskan_addPredispenseBaseline(expt)

% Add a pre-dispense baseline that mimics the Flex Station script

baseline = ones(8,1);

for i = 1:length(expt.samewells)
    a = expt.samewells(i).datamean;
    expt.samewells(i).datamean = [baseline; a];
end


end