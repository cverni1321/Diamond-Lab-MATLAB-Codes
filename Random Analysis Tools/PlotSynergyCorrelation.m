
% Use this script to calculate the synergy scores for a healthy PAS and the
% predicted values from a NN trained on the data.

% First must load the healthy expt structure as well as the NN output file

[P,T,p,t,pred_s,pred_s_normalized] = GetSynergyScoresNNPrediction(expt,yc,'plot');

Actual_Scores_Array = gcf;
%filename = 'Predicted Synergy';
%print(h1, '-dpdf', filename)  

[P,T,p,t,actual_s,actual_s_normalized] = GetSynergyScores(expt,'plot');

Predicted_Scores_Array = gcf;
%filename = 'Actual Synergy';
%print(h2, '-dpdf', filename) 

figure
plot(actual_s_normalized,pred_s_normalized,'ok','MarkerSize',10,'LineWidth',1)

hold on

% Plot best fit line
[p,S] = polyfit(actual_s_normalized,pred_s_normalized,1);

y_fit = p(1)*actual_s_normalized + p(2);

plot(actual_s_normalized, y_fit, '-r','LineWidth',2 )

set(gca,'XLim',[-1 1])
set(gca,'YLim',[-1 1])
xlabel('Measured Synergy','FontSize', 20)
ylabel('NN Predicted Synergy','FontSize', 20)
legend('Data Points', 'Best Linear Fit','Location','NorthWest')

hold on

% Plot 45 degree line
x_45 = -1:0.1:1;
y_45 = -1:0.1:1;

plot(x_45,y_45,'-k','LineWidth',0.5 )

set(gca, 'FontSize', 18)

h = gcf;
hold off
%filename = 'Synergy Correlation';
% print(h, '-dpdf', filename) 

R = corrcoef(actual_s_normalized,pred_s_normalized)


% Plot heatmap of synergy scores in vector form (have to add the value 1 to
% each vector of scores to get the colors right -- just crop that row off)
load('C:\Users\Chris\Desktop\MATLAB Codes\Random Analysis Tools\cmap_br');
figure
Actual_Scores_Heatmap = heatmap([actual_s_normalized;1]);
colormap(cmap_br)
colorbar

figure
Predicted_Scores_Heatmap = heatmap([pred_s_normalized;1]);
colormap(cmap_br)
colorbar




