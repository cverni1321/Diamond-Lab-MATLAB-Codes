function varargout = SBplot_for_flex(varargin)

% SBplot - plots given data.
%
% USAGE:
% ======
% [] = SBplot(time,data)
% [] = SBplot(time,data,names)
% [] = SBplot(time,data,names,name)
% [] = SBplot(time,data,names,legendtext,name)
% [] = SBplot(time,data,names,legendtext,marker,name)
% [] = SBplot(time,data,names,errorindices,minvalues,maxvalues,legendtext,marker,name)
%
% [] = SBplot(datastruct1)
% [] = SBplot(datastruct1,datastruct2)
% [] = SBplot(datastruct1,datastruct2, ..., datastructN)
%
% The datastructures are created most easily using the function
% createdatastructSBplotSB.
%
% time: column vector with time information
% data: matrix with data where each row corresponds to one time point and
%   each column to a different variable
% names: cell-array with the names of the data variables
% legendtext: cell-array of same length as names with text to be used for
%   the legend.
% marker: marker and line style for plot
% errorindices: indices of the data for which errorbounds are available
% minvalues: error bounds for data ... to be shown by error bars
% maxvalues: error bounds for data ... to be shown by error bars
% name: name describing the datastruct
%
% datastruct: datastructure with all the plotting data (allows for
%   displaying several datastructs at a time in the same GUI).
%
% DEFAULT VALUES:
% ===============
% names: the plotted variables obtain the name 'x1', 'x2', ...
% legendtext: same as names
% marker: '-'
% min/maxvalues: no errorbars shown

% Information:
% ============
% Copyright (C) 2008 Henning Schmidt, henning@sbtoolbox2.org
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
% USA.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SBplot_OpeningFcn, ...
                   'gui_OutputFcn',  @SBplot_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before SBplot is made visible.
function SBplot_OpeningFcn(hObject, eventdata, handles, varargin)

% Check if data structure or normal data as input
if ~isstruct(varargin{1}), % Assume normal input arguments
    runcmd = 'datastruct = createdatastructSBplotSB(';
    for k = 1:nargin-3,
        runcmd = sprintf('%s varargin{%d},',runcmd,k);
    end
    runcmd = runcmd(1:end-1);
    runcmd = [runcmd ');'];
    eval(runcmd);
    handles.dataSets = {datastruct};
else % Each argument is assumed to correspond to one datastructure
    handles.dataSets = varargin; % Save all datastructs in handles
end
handles = switchDataSet(handles,1); % Switch to first datastruct

% Initialize datastructs pulldown menu
datastructnames = {};
for k = 1:length(handles.dataSets),
    datastructnames{k} = handles.dataSets{k}.name;
end
set(handles.datastructs,'String',datastructnames);

% Select plottype to start with
handles.dataPlotType = 'plot';  

% Initialize export figure handle
handles.exportFigureHandle = [];
handles.grid = 0;

% Doing a first plot
doPlot(handles);

% Choose default command line output for SBplot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
interactivemouse on
return

% --- Executes just before SBplot is made visible.
function Exit_Callback(hObject, eventdata, handles, varargin)
clear global doRemoveZeroComponentFlag
closereq
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SWITCH GIVEN DATASTRUCTS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [handles] = switchDataSet(handles,indexDataSet)
dataSet = handles.dataSets{indexDataSet};
% Set all the plot data also in the handles structure to be accessed by 
% all callback functions
% get number of yaxisdata in old plot
if isfield(handles,'dataNames'),
    ynumberold = length(handles.dataNames);
else
    ynumberold = 0;
end

handles.time = dataSet.time;
handles.data = dataSet.data;
handles.dataNames = dataSet.datanames;
handles.legentext = dataSet.legendtext;
handles.marker = dataSet.marker;
handles.errorindices = dataSet.errorindices;
handles.minvalues = dataSet.minvalues;
handles.maxvalues = dataSet.maxvalues;
handles.name = dataSet.name;
handles.skipThese = dataSet.skipthese;
handles.colorvector = dataSet.colorvector;

% Update selection menu
set(handles.xaxisselection,'String',{'TIME',dataSet.datanames{:}});
set(handles.yaxisselection,'String',dataSet.datanames);
set(handles.xaxisselection,'Value',1);

% Change selection only if unequal numbers of data in the sets
if ynumberold ~= length(handles.dataNames),
    set(handles.yaxisselection,'Value',1);
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATASTRUCTS SELECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function datastructs_Callback(hObject, eventdata, handles)
dataSetIndex = get(handles.datastructs,'Value');
handles = switchDataSet(handles,dataSetIndex);
switch handles.dataPlotType,
    case 'fourier',
        fourier_Callback(hObject, eventdata, handles);
    case 'autocorrelation',
        autocorrelation_Callback(hObject, eventdata, handles);
    otherwise,
        doPlot(handles);
end

% Update handles structure
guidata(hObject, handles);
return

% --- Outputs from this function are returned to the command line.
function varargout = SBplot_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
return

% --- Executes on button press in zoombutton.
function zoombutton_Callback(hObject, eventdata, handles)
% Toggle the zoom in the figure
zoom
return

% --- Executes on selection change in xaxisselection.
function xaxisselection_Callback(hObject, eventdata, handles)
% Check if time in xaxis ... then enable fourier and autocorrelation
if get(handles.xaxisselection,'Value') == 1,
    set(handles.fourier,'Enable','on');
    set(handles.autocorrelation,'Enable','on');
else
    set(handles.fourier,'Enable','off');
    set(handles.autocorrelation,'Enable','off');
    set(handles.buttongroup,'SelectedObject',handles.plot);
    handles.dataPlotType = 'plot';  
end    
try
    switch handles.dataPlotType,
        case 'fourier',
            fourier_Callback(hObject, eventdata, handles);
        case 'autocorrelation',
            autocorrelation_Callback(hObject, eventdata, handles);
        otherwise,
            doPlot(handles);
    end
catch
    errordlg('This selection is not possible.','Error','on');               
end

% Update handles structure
guidata(hObject, handles);
interactivemouse on
return

% --- Executes on selection change in yaxisselection.
function yaxisselection_Callback(hObject, eventdata, handles)
% Check if time in xaxis ... then enable fourier and autocorrelation
if get(handles.xaxisselection,'Value') == 1,
    set(handles.fourier,'Enable','on');
    set(handles.autocorrelation,'Enable','on');
else
    set(handles.fourier,'Enable','off');
    set(handles.autocorrelation,'Enable','off');
    set(handles.buttongroup,'SelectedObject',handles.plot);
    handles.dataPlotType = 'plot';
end    
try
    switch handles.dataPlotType,
        case 'fourier',
            fourier_Callback(hObject, eventdata, handles);
        case 'autocorrelation',
            autocorrelation_Callback(hObject, eventdata, handles);
        otherwise,
            doPlot(handles);
    end
catch
    errordlg('This selection is not possible.','Error','on');               
end

% Update handles structure
guidata(hObject, handles);
interactivemouse on
return

% --- Executes on button press in gridbutton.
function gridbutton_Callback(hObject, eventdata, handles)
% Toggle the grid in the figure
grid
if handles.grid == 1,
    handles.grid = 0;
else
    handles.grid = 1;
end

% Update handles structure
guidata(hObject, handles);
return

% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
handles.dataPlotType = 'plot';

% Update handles structure
guidata(hObject, handles);
doPlot(handles);
return

% --- Executes on button press in semilogx.
function semilogx_Callback(hObject, eventdata, handles)
handles.dataPlotType = 'semilogx';

% Update handles structure
guidata(hObject, handles);
doPlot(handles);
return

% --- Executes on button press in semilogy.
function semilogy_Callback(hObject, eventdata, handles)
handles.dataPlotType = 'semilogy';

% Update handles structure
guidata(hObject, handles);
doPlot(handles);
return

% --- Executes on button press in loglog.
function loglog_Callback(hObject, eventdata, handles)
handles.dataPlotType = 'loglog';

% Update handles structure
guidata(hObject, handles);
doPlot(handles);
return

% --- Executes on button press in fourier.
function fourier_Callback(hObject, eventdata, handles)
global doRemoveZeroComponentFlag
if isempty(doRemoveZeroComponentFlag),
    % other functions can set this flag to 0 if they want to show the zero
    % component. For example for SBPDanalzeresiduals this is useful.
    doRemoveZeroComponentFlag = 1;
end
handles.dataPlotType = 'fourier';
try
    time = handles.time;
    data = handles.data;
    dataNames = handles.dataNames;
    indexY = get(handles.yaxisselection,'Value');
    yvariables = data(:,indexY);
    yvariablesNames = dataNames(indexY);
    % Determine the one-sided ffts for all components
    Yfft = [];
    freq = [];
    for k=1:size(yvariables,2),
        % Get the time data for single component
        y1 = yvariables(:,k);
        if size(time,2) == 1,
            t1 = time;
        else
            t1 = time(:,k);
        end
        % Resample the timedata
        % Determine first the desired sampling interval (half the min size for
        % finer resolution)
        dt2 = min(t1(2:end)-t1(1:end-1)) / 2;
        [y2,t2] = resampleSB(t1,y1,dt2,'linear');
        % Remove the 0 freq component from data (by setting it to zero)
        if doRemoveZeroComponentFlag,
            y2 = y2-mean(y2);
        end        
        % Determine the one sided fft
        [Yfftk,freqk] = positivefftSB(y2,1/dt2);
        Yfft = [Yfft Yfftk(:)];
        freq = [freq freqk(:)];
    end
    stem(freq,abs(Yfft),'-');
    xlabel('Frequency')
    if doRemoveZeroComponentFlag,
        ylabel('|FFT(data)| (zero frequency value set to 0)')
        title([handles.name ' (zero frequency component set to zero)']);
    else
        ylabel('|FFT(data)|')
        title(handles.name);
    end
    % Build the legend
    ltext = handles.legentext(indexY);
    for k=1:length(ltext),
        ltext{k} = ['FFT of ' ltext{k}];
    end
    legend(ltext);
catch
    errordlg('This selection is not possible.','Error','on');               
end

% Update handles structure
guidata(hObject, handles);
return

% --- Executes on button press in autocorrelation.
function autocorrelation_Callback(hObject, eventdata, handles)
handles.dataPlotType = 'autocorrelation';
try
    time = handles.time;
    data = handles.data;
    dataNames = handles.dataNames;
    indexY = get(handles.yaxisselection,'Value');
    yvariables = data(:,indexY);
    yvariablesNames = dataNames(indexY);
    % Determine autocorrelations of residuals
    YRxx = [];
    Ylag = [];
    indexNaNlater = [];
    for k=1:size(yvariables,2),
        % Get values to resample and analyze
        y1 = yvariables(:,k);
        if size(time,2) == 1,
            t1 = time;
        else
            t1 = time(:,k);
        end
        % Resample the timedata
        % Determine first the desired sampling interval (half the min size for
        % finer resolution)
        dt2 = min(t1(2:end)-t1(1:end-1)) / 2;
        [y2,t2] = resampleSB(t1,y1,dt2,'linear');
        % Determine the autocorrelation
        y2 = y2-mean(y2);
        [YRxxk,Ylagk] = xcorrSB(y2,y2,length(y2)-1,'coeff');
        Ylag = [Ylag Ylagk(:)];
        YRxx = [YRxx YRxxk(:)];
    end
    stem(Ylag,YRxx,'-');
    xlabel('Lag')
    ylabel('Rxx (mean free data)')
    title([handles.name ' (removed mean)']);
    % Build the legend
    ltext = handles.legentext(indexY);
    for k=1:length(ltext),
        ltext{k} = ['Rxx of ' ltext{k}];
    end
    legend(ltext);
catch
    errordlg('This selection is not possible.','Error','on');
end

% Update handles structure
guidata(hObject, handles);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPORT FIGURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function export_Callback(hObject, eventdata, handles)
warning off;
if isempty(handles.exportFigureHandle),
    figH = figure;
    handles.exportFigureHandle = figH;
    % Update handles structure
    guidata(hObject, handles);
else
    figH = handles.exportFigureHandle;
    figure(figH);
end

nrow = str2num(get(handles.nrow,'String'));
ncol = str2num(get(handles.ncol,'String'));
nnumber = str2num(get(handles.nnumber,'String'));
subplot(nrow,ncol,nnumber);
switch handles.dataPlotType,
    case 'fourier',
        fourier_Callback(hObject, eventdata, handles);
    case 'autocorrelation',
        autocorrelation_Callback(hObject, eventdata, handles);
    otherwise,
        doPlot(handles);
end
if handles.grid == 1,
    grid;
end

% Set axes
XLim = get(handles.plotarea,'Xlim');
YLim = get(handles.plotarea,'Ylim');
axis([XLim, YLim]);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REQUEST NEW EXPORT FIGURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newexportfigure_Callback(hObject, eventdata, handles)
handles.exportFigureHandle = [];

% Update handles structure
guidata(hObject, handles);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPlot(handles)
if ~isfield(handles,'skipThese')
    handles.skipThese = 1;
end
warning off;

% Clear the axes before plotting the new set of data
cla                
colorvector = handles.colorvector;
time = handles.time;
data = handles.data;
dataNames = handles.dataNames;
errorindices = handles.errorindices;
xaxis = handles.xaxisselection;
yaxis = handles.yaxisselection;
% Get variable that is chosen for the x-axis
indexX = get(xaxis,'Value');
% Get variables that are chosen for the y-axis
indexY = get(yaxis,'Value');
if indexX == 1,
    if size(time,2) == 1,
        xvariable = time;
    else
        xvariable = time(:,indexY);
    end
else
    xvariable = data(:,indexX-1);
end

yvariables = data(:,indexY);
yvariablesNames = dataNames(indexY);
if ~isempty(handles.maxvalues) && ~isempty(handles.minvalues)
    maxvalues = handles.maxvalues(:,indexY);
    minvalues = handles.minvalues(:,indexY);
end

% Select linewidth
if ~isempty(errorindices),
    % Use wider line in case of data with error bounds
    addOption = sprintf(',''linewidth'',2');
else
    addOption = '';
end

% Plot
set(gcf,'DefaultAxesColorOrder',colorvector)  % Use custom color list to differentiate more than 8 colors
if isempty(errorindices)
    eval(sprintf('feval(handles.dataPlotType,xvariable,yvariables,handles.marker%s);',addOption))
elseif indexX == 1
    colorNumMax = length(colorvector);
    colorNum = 0;
    plots = size(yvariables,2);
    hold on
    for plotIndex = 1 : plots
        colorNum = colorNum + 1;
        % Loop back to the start of the color list when we run out of colors
        if colorNum > colorNumMax
            colorNum = 1;
        end
        h = shadedErrorBar(xvariable(:,plotIndex),yvariables(:,plotIndex),maxvalues(:,plotIndex) - minvalues(:,plotIndex),{'Color',colorvector(plotIndex,:),'linewidth',1.5},1);
        set(get(get(h.patch,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude patch from legend
        set(get(get(h.edge(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude first bound from legend
        set(get(get(h.edge(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); % Exclude second bound from legend
    end
    hold off
end

legend(handles.legentext(indexY)); 
% Write axis labels
if indexX == 1,
    xlabel('Time');
else
    xlabel(dataNames(indexX-1));
end

% Write title (name)
title(handles.name);
return
