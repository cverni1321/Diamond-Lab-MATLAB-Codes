function [T_healthy,T_trauma,T_converted,healthyAUCs,traumaAUCs,convertedAUCs,ratio,rvalue] = TransformHealthy2Trauma(expt1,expt2)

% In order to model a trauma patient hemostatic response, we need to send
% trained NN's to the multiscale model. However, since trauma patients are
% known to have a coagulopathic phenotype, it is tough to train models on
% the obtained data. We want to modify the data obtained from a healthy
% donor so that it mimics the trauma patient response. To do this we will
% try to dial down the healthy data with a multiplicative factor.

% Inputs:   expt1 = healthy PAS
%           expt2 = trauma PAS


num_wells1 = length(expt1.samewells);
num_wells2 = length(expt2.samewells);

if num_wells1 == num_wells2
    num_wells = num_wells1;
else
    error('The two expt structures have different conditions')
end

% Find longest time interval spanned by all runs
min_time = min(expt1.samewells(1).time(end,:));
for i = 2:num_wells
   if min_time > min(expt1.samewells(i).time(end,:));
      min_time = min(expt1.samewells(i).time(end,:));
   end
end

% Adjust time units, if necessary
timescale = 1;
t = 1:1:ceil(min_time*timescale);
T_healthy = zeros(length(t),num_wells);
T_trauma = zeros(length(t),num_wells);
T_converted = zeros(length(t),num_wells);

for i = 1:num_wells
   time = expt1.samewells(i).time*timescale;
   data = expt1.samewells(i).data;
   num_rep = size(data,2);
   c = zeros(length(t),num_rep);
   for j = 1:num_rep
      c(:,j) = interp1(time(:,j),data(:,j),t,...
         'linear','extrap'); % Interpolate the data at 1-second intervals
   end
   T_healthy(:,i) = mean(c,2);
end

for i = 1:num_wells
   time = expt2.samewells(i).time*timescale;
   data = expt2.samewells(i).data;
   num_rep = size(data,2);
   c = zeros(length(t),num_rep);
   for j = 1:num_rep
      c(:,j) = interp1(time(:,j),data(:,j),t,...
         'linear','extrap'); % Interpolate the data at 1-second intervals
   end
   T_trauma(:,i) = mean(c,2);
end

% Subtract baseline
T_healthy = T_healthy - T_healthy(:,1)*ones(1,num_wells);
f_max = max(max(T_healthy));
f_min = T_healthy(1,1);
T_healthy = (T_healthy-f_min)/(f_max-f_min);
T_healthy(T_healthy<0)=0;

T_trauma = T_trauma - T_trauma(:,1)*ones(1,num_wells);
T_trauma = (T_trauma-f_min)/(f_max-f_min);
T_trauma(T_trauma<0)=0;

% Apply multiplicative factor to dial response down (find areas under curve
% and then calculate the ratio for each condition for healthy and trauma)
healthyAUCs = zeros(1,size(T_healthy,2)); 
traumaAUCs = zeros(1,size(T_trauma,2));
convertedAUCs = zeros(1,size(T_converted,2));
ratio = zeros(1,size(T_healthy,2)); 

for i = 1:length(healthyAUCs)
    healthyAUCs(i) = trapz(T_healthy(:,i));
end

for i = 1:length(traumaAUCs)
    traumaAUCs(i) = trapz(T_trauma(:,i));
end

for i = 1:length(healthyAUCs)
    ratio(i) = traumaAUCs(i)/healthyAUCs(i);
end

for i = 1:size(T_healthy,2)
    T_converted(:,i) = T_healthy(:,i)*ratio(1,i);
end

T_converted(isnan(T_converted)) = 0; % Convert NaN to 0 for plotting purposes

for i = 1: size(T_converted,2)
    convertedAUCs(i) = trapz(T_converted(:,i));
end


% Compare T_trauma to T_converted to see how well we have mimicked the
% response
T1 = [T_healthy,T_trauma];
figure
h1 = heatmap(T1');
title('Healthy vs Trauma')

T2 = [T_healthy,T_converted];
figure
h2 = heatmap(T2');
title('Healthy vs Converted')

rvalue = corr2(T_trauma,T_converted);


