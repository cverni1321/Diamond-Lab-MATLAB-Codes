function flowcyt_plots(expt)

% This script will plot MFI values in bar graph form

%% Plot FL1 data
numConditions = 1:length(expt.samewells);
for i=1:length(expt.samewells)
    FL1MFI(i,1) = expt.samewells(i).FL1MFI_avg(1,1); % Compile mean values
    FL1MFI(i,2) = expt.samewells(i).FL1MFI_avg(1,2); % Compile std values
end
figure
bar(numConditions,FL1MFI(:,1));
hold on
er = errorbar(numConditions,FL1MFI(:,1),zeros(length(expt.samewells),1),FL1MFI(:,2));
er.Color = [0 0 0];
er.LineStyle = 'none';
ylabel('PAC-1 MFI')
set(gca,'XTick',[1:length(expt.samewells)],'XTickLabel',{expt.listwells{:}},'XTickLabelRotation',90)
hold off

%% Plot FL2 data
numConditions = 1:length(expt.samewells);
for i=1:length(expt.samewells)
    FL2MFI(i,1) = expt.samewells(i).FL2MFI_avg(1,1); % Compile mean values
    FL2MFI(i,2) = expt.samewells(i).FL2MFI_avg(1,2); % Compile std values
end
figure
bar(numConditions,FL2MFI(:,1));
hold on
er = errorbar(numConditions,FL2MFI(:,1),zeros(length(expt.samewells),1),FL2MFI(:,2));
er.Color = [0 0 0];
er.LineStyle = 'none';
ylabel('CD62P MFI')
set(gca,'XTick',[1:length(expt.samewells)],'XTickLabel',{expt.listwells{:}},'XTickLabelRotation',90)
hold off

%% Plot FL4 data
numConditions = 1:length(expt.samewells);
for i=1:length(expt.samewells)
    FL4percpos(i,1) = expt.samewells(i).FL4percpos_avg(1,1); % Compile mean values
    FL4percpos(i,2) = expt.samewells(i).FL4percpos_avg(1,2); % Compile std values
end
figure
bar(numConditions,FL4percpos(:,1));
hold on
er = errorbar(numConditions,FL4percpos(:,1),zeros(length(expt.samewells),1),FL4percpos(:,2));
er.Color = [0 0 0];
er.LineStyle = 'none';
ylabel('% Annexin V +')
set(gca,'XTick',[1:length(expt.samewells)],'XTickLabel',{expt.listwells{:}},'XTickLabelRotation',90)
hold off

