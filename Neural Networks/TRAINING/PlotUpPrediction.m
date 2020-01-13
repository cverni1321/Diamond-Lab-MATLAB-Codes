function [h] = PlotUpPrediction(CellArrayToPlotUp,titlelegend)

% Plots up the output given a cell array of dynamic outputs
% CellArrayToPlotUp - UsableData or outputs or yc
% title- What do we call this plot

h = figure;

for i=1:size(CellArrayToPlotUp{1},2) % For every curve
    dummy=[];
    for j=1: size(CellArrayToPlotUp,2) % For every time instant
        superdummy=CellArrayToPlotUp{j}; % All the data at this time instant
        dummy(end+1)=superdummy(i); % The data for the curve I am actually interested in at this time instant
    end
    plot(dummy); hold on
    clear dummy
    clear superdummy
end

title(titlelegend)
ylim([0 1])
end

