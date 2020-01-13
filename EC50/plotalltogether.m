% Plot several EC50 curves on one display
% 
% Need as inputs: conc_matrix, avg_responses_matrix, stdev_responses_matrix

labels={'ADP';'U46619';'CVX';'SFLLRN';'AYPGKF';'Ilo'};
master_ec50=findsame(labels);

% Construct master EC50 structure for agonists
for i=1:length(master_ec50)
    master_ec50(1,i).conc = conc_matrix(:,i);
    master_ec50(1,i).avg_responses = avg_responses_matrix(:,i);
    master_ec50(1,i).stdev_responses = stdev_responses_matrix(:,i);
end

% Overwrite master EC50 structure for antagonists (different # of points)
for i=length(master_ec50)
    master_ec50(1,i).conc(15)=[];
    master_ec50(1,i).avg_responses(15)=[];
    master_ec50(1,i).stdev_responses(15)=[];
end

% Calculate EC50
results=zeros(length(labels),4);
for i=1:(length(master_ec50)-1) % Have to change this based on # of antagonists being tested
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
for i=length(master_ec50) % Have to change this based on # of antagonists being tested
    results(i,:) = ec50(master_ec50(1,i).conc, master_ec50(1,i).avg_responses);
    master_ec50(1,i).min = min(master_ec50(1,i).avg_responses);
    master_ec50(1,i).max = max(master_ec50(1,i).avg_responses);
    master_ec50(1,i).ec50 = results(i,3);
end
master_ec50(1,6).hill = -0.985;  % This is the iloprost value calculated from the Excel macro I was given access to
master_ec50(1,6).curve_fit_responses = master_ec50(1,6).min + ((master_ec50(1,6).max - master_ec50(1,6).min)./(1 + (((master_ec50(1,6).ec50)./(master_ec50(1,6).conc)).^(master_ec50(1,6).hill))));

% Plot all curves on same figure
colorset = {'m','g','b','k','y','r'};

for i=1:length(master_ec50)
    index=1;
    plot1(index) = errorbar(master_ec50(1,i).conc, master_ec50(1,i).avg_responses, master_ec50(1,i).stdev_responses, 'o', 'Color', colorset{i});
    set(gca,'xscale','log')
    set(plot1(1),'MarkerEdgeColor','none','MarkerFaceColor',colorset{i});
    hold on
    plot2(index) = semilogx(master_ec50(1,i).conc, master_ec50(1,i).curve_fit_responses, '--', 'Color', colorset{i});    
    xlabel('Concentration of Agonist (M)');
    ylabel('Area Under F/Fo Curve');
    %legend({[master_ec50(1,index).label, ' (EC50: ', num2str(real(master_ec50(1,index).ec50)*10^6), ' uM)']});
    %legend('ADP',[],'U46619',[],'CVX',[],'SFLLRN',[],'AYPGKF',[],'Iloprost',[]);
    index=index+1;
end
