function [areas,percentbaseline,baselinediff,labels] = NormalizedCalciumAUC(expt)

% Take integrated area measurements from calcium experiments and normalize against Buffer control

areas = zeros(length(expt.samewells),1);
percentbaseline = zeros(length(expt.samewells),1);
baselinediff = zeros(length(expt.samewells),1);
labels = cell(length(expt.samewells),1);

for i = 1:length(expt.samewells)
    areas(i) = expt.samewells(i).integratedarea.integratedarea;
    labels{i} = expt.samewells(i).label;
end

for i = 1:length(expt.samewells)
    percentbaseline(i) = areas(i)/areas(1);
    baselinediff(i) = areas(i)-areas(1); % Could also think about plotting just the difference in AUC
end

bar(percentbaseline);
set(gca,'xtick',[1:length(labels)])
set(gca,'xticklabel',{labels{:}})
set(gca,'xticklabelrotation',90)
ylim([round(min(percentbaseline)-0.05,1) round(max(percentbaseline)+0.05,1)])

%bar(baselinediff);
%set(gca,'xtick',[1:length(labels)])
%set(gca,'xticklabel',{labels{:}})
%set(gca,'xticklabelrotation',90)