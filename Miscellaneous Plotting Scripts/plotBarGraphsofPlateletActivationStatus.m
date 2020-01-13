function plotBarGraphsofPlateletActivationStatus(healthyAUCs,healthyIDs,traumaAUCs,traumaIDs)

%% Generate the healthy bar graph first
% healthyAUCs must be a Nx1 matrix where N is the number of different
% donors

healthyavg = nan(length(healthyAUCs)+1,1);
healthystdev = nan(length(healthyAUCs)+1,1);
healthyavg(end) = mean(healthyAUCs);
healthystdev(end) = std(healthyAUCs);
healthyAUCs = vertcat(healthyAUCs,0);

figure
bar(healthyAUCs)
hold on
errorbar(healthyavg,healthystdev,'or')
set(gca,'xticklabel',{healthyIDs{:}})
xlabel('Healthy Donor ID')
ylabel('Total Platelet Calcium Mobilization')

yl = ylim;

%% Next generate the bar graph for the trauma patients
% traumaAUCs must be a NaN Nx(7+2) matrix where N is the number of patients (there
% are 7 columns for the 7 timepoints - if there is a NaN entry that means
% the calcium expt was not run on that sample)

figure
b = bar(traumaAUCs,1);
legend([b(2),b(3),b(4),b(5),b(6),b(7),b(8)],'0 hr','3 hr','6 hr','12 hr','24 hr','48 hr','120 hr')
set(gca,'xticklabel',{traumaIDs{:}})
xlabel('Trauma Donor ID')
ylabel('Total Platelet Calcium Mobilization')

hold on
plot(xlim, [healthyavg(end) healthyavg(end)], 'r')
plot(xlim, [(healthyavg(end)-healthystdev(end)) (healthyavg(end)-healthystdev(end))], '--r')
plot(xlim, [(healthyavg(end)+healthystdev(end)) (healthyavg(end)+healthystdev(end))], '--r')
ylim([0 yl(2)]) % Ensure that both graphs are on the same y scale

%% Also make a bar graph for all results in one plot

resultsAvg = zeros(7,1); 
resultsStdev = zeros(7,1);

resultsAvg(1) = healthyavg(end);
resultsAvg(2) = nanmean([traumaAUCs(:,2);traumaAUCs(:,3)]); % Combine T0 and T3 into one bar
resultsAvg(3) = nanmean(traumaAUCs(:,4));
resultsAvg(4) = nanmean(traumaAUCs(:,5));
resultsAvg(5) = nanmean(traumaAUCs(:,6));
resultsAvg(6) = nanmean(traumaAUCs(:,7));
resultsAvg(7) = nanmean(traumaAUCs(:,8));

resultsStdev(1) = healthystdev(end);
resultsStdev(2) = nanstd([traumaAUCs(:,2);traumaAUCs(:,3)]);
resultsStdev(3) = nanstd(traumaAUCs(:,4));
resultsStdev(4) = nanstd(traumaAUCs(:,5));
resultsStdev(5) = nanstd(traumaAUCs(:,6));
resultsStdev(6) = nanstd(traumaAUCs(:,7));
resultsStdev(7) = nanstd(traumaAUCs(:,8));

figure
barwitherr(resultsStdev,resultsAvg);
set(gca,'xticklabel',{'Healthy','T0-T3','T6','T12','T24','T48','T120'})
ax = gca;
ax.XTickLabelRotation = 45;
ylabel('Total Platelet Calcium Mobilization')

