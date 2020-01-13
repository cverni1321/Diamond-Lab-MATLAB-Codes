function expt = AF_plotsamewells(expt, varargin)

% Plot the normalized signal from the samewells 
%
% OPTIONS: yrange - Can specify if it comes from user (default is [NaN, NaN])
%          xrange - Can specify if it comes from user (default is [NaN, NaN])

option.yrange = [NaN NaN];
option.xrange = [NaN NaN];
option = setopt(option, varargin{:});

subplotrows = floor(sqrt(length(expt.samewells)));
subplotcols = ceil(length(expt.samewells)/subplotrows);

if isfield(expt, 'timeunits')
    timeunits = expt.timeunits;
else
    timeunits = 'Minutes';
end

xlabel = ['Time (' timeunits ')'];
ylabel = 'Relative Fluorescence Units (RFU)';

% Input data into figure
figure
for i = 1:length(expt.samewells)
    subplot(subplotrows, subplotcols, i);
    subplottitle = title(expt.samewells(i).label);
    fixfonts('handle', subplottitle, 'size', 8);
    hold on
    legends = {};
    for j = 1:size(expt.samewells(i).data, 2) % For each set of wells plot out the individual curves
        h_line = plot(expt.samewells(i).time(:,j), expt.samewells(i).data(:,j), ...
            getplottype(j,6,1));
        legends(j) = {sprintf('%d, %d', ...
            expt.samewells(i).positions(j,1), expt.samewells(i).positions(j,2))};
    end
    
    % Decide if we want to show the x and y labels
    showlabels(subplotrows, subplotcols, i, ...
        length(expt.samewells), xlabel, ylabel); % See below for 'showlabels' code
    set(gca, 'tickdir', 'out', 'ticklength', [0.00 0.00])
end

% Set an overall title
annh = annotation('textbox', [0.1 0.925 0.8 0.075]);
set(annh, 'HorizontalAlignment', 'center', 'String', expt.title, ...
    'fontsize', 20, 'LineStyle', 'none');

% Give it aesthetic beauty
set(findall(gcf, 'Type', 'line'), 'Marker', 'none');
set(findall(gcf, 'Type', 'line'), 'LineStyle', '-');
set(findall(gcf, 'Type', 'axes'), 'Box', 'on','LineWidth',1.5);
fixfonts();
filename = strcat(expt.datadir,'\individual RFU');
fixfigure('savedir', filename);

% Set all the axis limits to be the same
ax_handles = findobj(gcf, 'type', 'axes');
for i = 1:length(ax_handles)
    xlims(i,:) = get(ax_handles(i), 'xlim');
    ylims(i,:) = get(ax_handles(i), 'ylim');
end

xlims = [min(xlims(:,1)) max(xlims(:,2))];
ylims = [min(ylims(:,1)) max(ylims(:,2))];

% Set the limits to the user settings if requested
if ~isnan(option.xrange(1))
    xlims(1) = option.xrange(1);
end
if ~isnan(option.xrange(2))
    xlims(2) = option.xrange(2);
end
if ~isnan(option.yrange(1))
    ylims(1) = option.yrange(1);
end
if ~isnan(option.yrange(2))
    ylims(2) = option.yrange(2);
end

set(ax_handles, 'xlim', xlims, 'ylim', ylims);

%%% End Plotting %%%



function showlabels(sr, sc, i, maxi, xlb, ylb)

% Function which decides whether to show labels and ticks
[plotcol, plotrow] = ind2sub([sc sr], i);
% The nomenclature for columns and rows is reversed because subplot
% moves across the row while ind2sub moves down the column first.

xl = 0; % Show xlabel?
xt = 0; % Show xtick?
yl = 0;
yt = 0;

if ( ( (plotrow == sr) || (plotrow == sr - 1) )...
        && ((i+sc) > maxi)  ...
        ) % Last row or incomplete last row
    xt = 1;
    if (plotcol == ceil(sc/2))
        xl = 1;
    end
end
if (plotcol == 1)
    yt = 1;
    if (plotrow == ceil(1*sr/2))
        yl = 1;
    end
end

if (xt == 0)
    set (gca, 'xtick', []);
end
if (yt == 0)
    set (gca, 'ytick', []);
end

if xl
    xlabelh = xlabel(xlb);
    fixfonts('handle', xlabelh, 'size', 15);
end
if yl
    % only show the label on the central plot (rounding down)
    ylabelh = ylabel(ylb);
    fixfonts('handle', ylabelh, 'size', 15);
end
        
        
        