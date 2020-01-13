function [avgnetareas,avgpercentcontrol,stdpercentcontrol,results] = TraumaPPPHealthyWP(expt)

% Use this script for the experiments in which healthy washed platelets are
% isolated and then reconstituted with either (1) buffer, (2) healthy PPP
% or (3) trauma PPP. We want to see if there is a platelet silencing effect
% of PPP with higher FDP-concentrations.

% Outputs: avgnetareas - average area under of curve of each condition with buffer AUC
%                        subtracted out
%          stdnetareas - standard deviation of all runs of one condition

netareas = cell(length(expt.samewells)-1,1);
avgnetareas = zeros(length(expt.samewells)-1,1);
percentcontrol = cell(length(expt.samewells)-1,1);
avgpercentcontrol = zeros(length(expt.samewells)-1,1);
stdpercentcontrol = zeros(length(expt.samewells)-1,1);

% Check to make sure a Buffer control condition is present
if strcmpi(expt.samewells(1).label,'Buffer')==0
    error('No buffer control condition');
end

for i = 2:length(expt.samewells)
    netareas{i-1} = expt.samewells(i).integratedarea.values - expt.samewells(1).integratedarea.integratedarea;
    avgnetareas(i-1) = mean(netareas{i-1});
    percentcontrol{i-1} = netareas{i-1}/avgnetareas(1)*100;
    avgpercentcontrol(i-1) = mean(percentcontrol{i-1});
    stdpercentcontrol(i-1) = std(percentcontrol{i-1});
end

results = horzcat(avgnetareas,avgpercentcontrol,stdpercentcontrol);

end