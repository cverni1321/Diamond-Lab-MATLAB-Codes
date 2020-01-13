% Script to plot the blood products administered to trauma patients binned
% by time ranges
clear
clc

intakeoutput_file = 'C:\Users\Chris\Desktop\Chris PhD Research\Updates\U01 Trauma - TrICI\13 patient EPIC files\Blood Products Data';

[~,~,raw] = xlsread(intakeoutput_file,2);
out = raw(any(cellfun(@(x)any(~isnan(x)),raw),2),:);
out(1,:) = [];
out(:,70:72) = [];
out(:,44:45) = [];
out(:,1) = [];

raw_matrix = cell2mat(out);
bins = {'0-3','3-6','6-12','12-24','24-48','48-120'};

pt014 = vec2mat(raw_matrix(1,:),6)';
figure
a = bar(pt014,'FaceColor','flat');
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 014')

pt019 = vec2mat(raw_matrix(2,:),6)';
figure
b = bar(pt019);
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 019')

pt020 = vec2mat(raw_matrix(3,:),6)';
figure
c = bar(pt020);
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 020')

pt025 = vec2mat(raw_matrix(4,:),6)';
figure
d = bar(pt025);
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 025')

pt027 = vec2mat(raw_matrix(5,:),6)';
figure
bar(pt027)
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 027')

pt028 = vec2mat(raw_matrix(6,:),6)';
figure
bar(pt028)
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 028')

pt036 = vec2mat(raw_matrix(7,:),6)';
figure
bar(pt036)
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 036')

pt038 = vec2mat(raw_matrix(8,:),6)';
figure
bar(pt038)
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 038')

pt044 = vec2mat(raw_matrix(9,:),6)';
figure
bar(pt044)
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 044')

pt055 = vec2mat(raw_matrix(10,:),6)';
figure
bar(pt055)
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 055')

pt068 = vec2mat(raw_matrix(11,:),6)';
figure
bar(pt068)
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 068')

pt075 = vec2mat(raw_matrix(12,:),6)';
figure
l = bar(pt075);
legend([l(1),l(2),l(3),l(4),l(5),l(6),l(7),l(8),l(9),l(10),l(11)],'pRBC','FFP','Platelets','Cell Saver/Autotransfusion','Whole Blood','Crystalloids (Saline)','Oral-NGT-GT Intake','Urine','Oral-NGT-GT Output','Drains','Blood Loss')
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 075')

pt078 = vec2mat(raw_matrix(13,:),6)';
figure
m = bar(pt078);
legend([m(1),m(2),m(3),m(4),m(5),m(6),m(7),m(8),m(9),m(10),m(11)],'pRBC','FFP','Platelets','Cell Saver/Autotransfusion','Whole Blood','Crystalloids (Saline)','Oral-NGT-GT Intake','Urine','Oral-NGT-GT Output','Drains','Blood Loss')
set(gca,'xticklabel',bins)
xlabel('Hours since admission')
ylabel('Volume (mL)')
title('Patient 078')
