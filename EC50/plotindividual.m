% Plot several EC50 curves on multiple displays
% 
% Need as inputs: conc_matrix, avg_responses_matrix, stdev_responses_matrix

labels={'ADP';'CVX';'IIa';'U46619';'SFLLRN';'AYPGKF';'Ilo';'GSNO'};
master_ec50=findsame(labels);

% Construct master EC50 structure for agonists
for i=1:length(master_ec50)
    master_ec50(1,i).conc = conc_matrix(:,i);
    master_ec50(1,i).avg_responses = avg_responses_matrix(:,i);
    master_ec50(1,i).stdev_responses = stdev_responses_matrix(:,i);
end

% Overwrite master EC50 structure for antagonists (different # of points)
for i=(length(master_ec50)-1):length(master_ec50)
    master_ec50(1,i).conc(15)=[];
    master_ec50(1,i).avg_responses(15)=[];
    master_ec50(1,i).stdev_responses(15)=[];
end

% Calculate EC50
results=zeros(8,4);
for i=1:(length(master_ec50)-2)
    results(i,:) = ec50(master_ec50(1,i).conc, master_ec50(1,i).avg_responses);
    master_ec50(1,i).min = min(master_ec50(1,i).avg_responses);
    % master_ec50(1,i).min = mean(results(:,1)); these are what Mei had but
    % they don't make sense to me
    master_ec50(1,i).max = max(master_ec50(1,i).avg_responses);
    % master_ec50(1,i).max = mean(results(:,2));
    master_ec50(1,i).ec50 = results(i,3);
    % master_ec50(1,i).ec50 = mean(results(:,3));
    master_ec50(1,i).hill = results(i,4);
    % master_ec50(1,i).hill = mean(results(:,4));
    master_ec50(1,i).curve_fit_responses = master_ec50(1,i).min + ((master_ec50(1,i).max - master_ec50(1,i).min)./(1 + (((master_ec50(1,i).ec50)./(master_ec50(1,i).conc)).^(master_ec50(1,i).hill))));
end

% Overwrite results for antagonists (change of inflection)
for i=(length(master_ec50)-1):length(master_ec50)
    results(i,:) = ec50(master_ec50(1,i).conc, master_ec50(1,i).avg_responses);
    master_ec50(1,i).min = min(master_ec50(1,i).avg_responses);
    master_ec50(1,i).max = max(master_ec50(1,i).avg_responses);
    master_ec50(1,i).ec50 = results(i,3);
end
master_ec50(1,7).hill = -0.985; 
master_ec50(1,8).hill = -0.882; % these were calculated from the Excel macro I was given access to
master_ec50(1,7).curve_fit_responses = master_ec50(1,7).min + ((master_ec50(1,7).max - master_ec50(1,7).min)./(1 + (((master_ec50(1,7).ec50)./(master_ec50(1,7).conc)).^(master_ec50(1,7).hill))));
master_ec50(1,8).curve_fit_responses = master_ec50(1,8).min + ((master_ec50(1,8).max - master_ec50(1,8).min)./(1 + (((master_ec50(1,8).ec50)./(master_ec50(1,8).conc)).^(master_ec50(1,8).hill))));

% Plot all curves on same figure
colorset = varycolor(length(master_ec50));
colorset(4,:) = 0.50; % Adjust some of the colors for better contrast
colorset(5,1) = 1;
colorset(5,2) = 0.75;
colorset(5,3) = 0.50;

for i=1:length(master_ec50)
    figure
    plot = errorbar(master_ec50(1,i).conc, master_ec50(1,i).avg_responses, master_ec50(1,i).stdev_responses, 'o', 'Color', colorset(i,:));
    errorbarlogx(0.01);
    set(plot(1),'MarkerEdgeColor','none','MarkerFaceColor',colorset(i,:));
    hold on
    semilogx(master_ec50(1,i).conc, master_ec50(1,i).curve_fit_responses, '-', 'Color', colorset(i,:));
    xlabel(['Concentration of ', char(master_ec50(1,i).label), ' (M)'])
    ylabel('Area Under F/Fo Curve')
    title(master_ec50(1,i).label)
    legend({['EC50: ',num2str(real(master_ec50(1,i).ec50)*10^6),' uM']})
end
