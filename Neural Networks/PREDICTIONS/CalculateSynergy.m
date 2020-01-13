function [actual_s_normalized,predicted_s_normalized] = CalculateSynergy(actualData,predictedData,ProcessedTimes,concmatrix)

% Need to load the NN output (it contains all the required inputs)
% The structures need to be arranged with single agonist conditions first
% followed by dual agonists (use RearrangeConcmatrix_FullPAS.m if needed)

% First calculate the areas under each curve
actual_areas = zeros(size(actualData,1),1);
for i=1:length(actual_areas)
    actual_areas(i) = trapz(ProcessedTimes,actualData(i,:));
end
actual_areas(actual_areas<0) = 0;


predicted_areas = zeros(size(predictedData,1),1);
for i=1:length(predicted_areas)
    predicted_areas(i) = trapz(ProcessedTimes,predictedData(i,:));
end
predicted_areas(predicted_areas<0) = 0;

% Next run through the concmatrix to find the non-single conditions and start to
% calculate the gross synergies
logical = zeros(size(concmatrix,1),1);
for i=1:size(concmatrix,1)
    numconditions = 0;
    for j=1:size(concmatrix,2)
        if concmatrix(i,j) == -1
            numconditions = numconditions;
        else
            numconditions = numconditions+1;
        end
    if numconditions > 1
        logical(i) = 1;
    else
        logical(i) = 0;
    end
    end
end

actual_s = zeros(sum(logical),1);
predicted_s = zeros(sum(logical),1);
duals = find(logical); % Creates a vector with the indices of the nonzero elements (dual combos)

for index=duals(1):duals(end)
    synergies = zeros(3,1);
    predicted_synergies = zeros(3,1);
    synergies(1) = actual_areas(index);
    predicted_synergies(1) = predicted_areas(index);
    count = 2;
    for condition=1:size(concmatrix,2)
        for k=1:(duals(1)-1)
            if concmatrix(index,condition) == concmatrix(k,condition) && concmatrix(index,condition)~=-1
                synergies(count) = actual_areas(k);
                predicted_synergies(count) = predicted_areas(k);
                count=count+1;
            end
        end
    end
    actual_s(index-(duals(1)-1)) = synergies(1)-(synergies(2)+synergies(3));
    predicted_s(index-(duals(1)-1)) = predicted_synergies(1)-(predicted_synergies(2)+predicted_synergies(3));
end
                

% Find the max synergy and normalize everything by it, then plot data
max_actual_s = max(abs(actual_s));
max_predicted_s = max(abs(predicted_s));

actual_s_normalized = actual_s/max_actual_s;
predicted_s_normalized = predicted_s/max_predicted_s;

figure
plot(actual_s_normalized,predicted_s_normalized,'ok','MarkerSize',10,'LineWidth',1)
xlim([-1 1])
xlabel('Measured Synergy','fontsize',20)
ylim([-1 1])
ylabel('Predicted Synergy','fontsize',20)

hold on

% Plot best fit line
[p,S] = polyfit(actual_s_normalized,predicted_s_normalized,1);

y_fit = p(1)*actual_s_normalized + p(2);

plot(actual_s_normalized,y_fit,'-r','LineWidth',2)

% Plot 45 degree line
x_45 = -1:0.1:1;
y_45 = -1:0.1:1;

plot(x_45,y_45,'-k','LineWidth',0.5)
set(gca,'FontSize',18)

R = corrcoef(actual_s_normalized,predicted_s_normalized)

% Plot heatmap of synergy scores in vector form (have to add the value 1 to
% each vector of scores to get the colors right -- just crop that row off)
load('C:\Users\Chris\Desktop\MATLAB Codes\Random Analysis Tools\cmap_br');
figure
Actual_Scores_Heatmap = heatmap([actual_s_normalized;1]);
title('Measured Synergy Scores')
colormap(cmap_br)
colorbar

figure
Predicted_Scores_Heatmap = heatmap([predicted_s_normalized;1]);
title('Predicted Synergy Scores')
colormap(cmap_br)
colorbar

% Also plot matrix of synergies to better visualize the contributions of
% each agonist
figure
z = concmatrix(duals,:)';
len_x = size(z,1);
for i=1:len_x
    for j=(i+1):len_x
        zij = z([i,j],:);
        sij = actual_s';
        [~,J,~] = find(zij==-1);
        zij(:,J) = [];
        sij(:,J) = [];
        for ii = 1:size(zij,2)
            c = ceil((32+sij(ii)*(32/max_actual_s))+eps);
            rectangle('Position',...
                    [i+0.50*zij(1,ii),j+0.50*zij(2,ii),0.30,0.30],...
                    'FaceColor',cmap_br(c,:),...
                    'EdgeColor',[0.9 0.9 0.9]);
        end
    end
end

axis off


figure
z = concmatrix(duals,:)';
len_x = size(z,1);
for i=1:len_x
    for j=(i+1):len_x
        zij = z([i,j],:);
        sij = predicted_s';
        [~,J,~] = find(zij==-1);
        zij(:,J) = [];
        sij(:,J) = [];
        for ii = 1:size(zij,2)
            c = ceil((32+sij(ii)*(32/max_predicted_s))+eps);
            rectangle('Position',...
                    [i+0.50*zij(1,ii),j+0.50*zij(2,ii),0.30,0.30],...
                    'FaceColor',cmap_br(c,:),...
                    'EdgeColor',[0.9 0.9 0.9]);
        end
    end
end

axis off





