clear
clc

load('C:\Users\SLDLab\Google Drive\Mei Experiments\2015\04-21-15_Aggregation\05-13-15\data')

% H=shadedErrorBar(x,y,errBar,lineProps,transparent)
H_buffer = shadedErrorBar(time,mean(p_buffer_CVX_10min,2),std(p_buffer_CVX_10min,[],2),'k');
hold on
H_T2nM = shadedErrorBar(time,mean(p_T2nM_CVX_10min,2),std(p_T2nM_CVX_10min,[],2),'r');

title('t incubation = 10min','FontSize',18)
h_legend = legend([H_buffer.mainLine H_T2nM.mainLine], 'buffer, CVX','T|2 nM, CVX');
xlabel('Time(s)','FontSize',16)
ylabel('% Aggregation','FontSize',16)
ylim([0 100])
xlim([0 700])
set(gca,'FontSize',14)
% set(YTickLabel,'FontSize',14)

% H = shadedErrorBar(time2,mean(p_T2nM,2),std(p_T2nM,[],2),'k');
% 
% title('T|2 nM','FontSize',18)
% xlabel('Time(s)','FontSize',16)
% ylabel('% Aggregation','FontSize',16)
% ylim([0 100])
% xlim([0 700])
% set(gca,'FontSize',14)
% % set(YTickLabel,'FontSize',14)