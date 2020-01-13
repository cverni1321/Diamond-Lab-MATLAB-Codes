function expt = combineexperiments(expt1,expt2)

% Combine two expt structures to be able to plot the data together with
% flexplot

% Need to rename the individual structures after loaded into the workspace

expt = struct();
expt.samewells = [expt1.samewells,expt2.samewells];

% Check if any of the labels from the individual expt files are the same
% (work more on this at a later date if I find it necessary)
for i = 1:length(expt1.samewells)
    for j = 1:length(expt2.samewells)
        if strcmpi(expt1.samewells(i).label,expt2.samewells(j).label)
            label = expt1.samewells(i).label;
            replicates = zeros(length(expt.samewells),length(expt1.samewells));
            for k = 1:length(expt.samewells)
                replicates(k,i) = strcmpi(expt.samewells(k).label,label);
            end
        else
        end
    end
end