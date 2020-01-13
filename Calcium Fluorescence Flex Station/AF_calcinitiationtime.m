function retval = AF_calcinitiationtime(varargin)

% Calculate the initiation time of blood clotting by determining the
% time at which the data goes above its baseline by some percent.  If 2D data 
% is given, the times should proceed down the rows and the
% different datasets should be in different columns.
%
% OPTIONS
% NAME          DESCRIPTION
% percent       Percent that the data must rise above (default: 0.05)
% usederivative Use the second derivative instead of the percentage
%               (default: 0)
% setmax        Set the maximum time as the initiation time if the well
%               does not initiate. (default: 0)

if iscell(varargin{1})
    retval = AF_calcinitiationtime_ext(varargin{1});
else
    retval = AF_calcinitiationtime_int(varargin{:});
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function retval = AF_calcinitiationtime_int(data, times, varargin) % Calculate the initiation time for each well

option.percent = 0.05; % For an experiment with RNase, Scott wanted Mei to calculate the time
                       % to half maximum clotting, so she used 0.5 here                       
option.usederivative = 0;
option.setmax = 0;
option = setopt(option, varargin{:});

if option.usederivative
    if length(data)>5
        diffs = smooth(diff(smooth(data, 20, 'loess'), 2), 30); % 'loess' creates a quadratic fit for second derivative
        dummytimes = times(2:end-1);
        point = find(diffs == max(diffs), 1); % Find the point where the maximum second derivative occurs
        retval = dummytimes(point);
        position = find(times == retval);
        
        if data(position)>option.percent % Check if the data point is above the preset conversion threshold
        end
        
    else
        retval = NaN;
    end
    
else
    point = find(data>option.percent, 1);
    if isempty(point)
        retval = NaN;
    else
        retval = times(point);
    end
end

if isnan(retval) && option.setmax
    retval = times(end);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function retval = AF_calcinitiationtime_ext(results)

times = nan(size(results));
for i = 1:length(results)
    if ~isempty(results{i})
        times(i) = results{i};
    end
end

retval.time = nanmean(times);
retval.error = nanstd2(times);
retval.times = times;
retval.percent = mean(~isnan(times));

    
        

