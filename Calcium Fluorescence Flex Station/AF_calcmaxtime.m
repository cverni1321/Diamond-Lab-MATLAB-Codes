function retval = AF_calcmaxtime(varargin)

% Calculate the maximum time from the normalized data

if iscell(varargin{1})
    retval = AF_calcmaxtime_ext(varargin{:});
else
    retval = AF_calcmaxtime_int(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function retval = AF_calcmaxtime_int(data, times) % Find the point where the time is maximum

retval = times(find(data == max(data), 1)); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function maxtime = AF_calcmaxtime_ext(results) % Calculate the final values

times = nan(size(results));
for i = 1:length(results)
    if ~isempty(results{i})
        times(i) = results{i};
    end
end

maxtime.time = nanmean(times);
maxtime.error = nanstd2(times);
maxtime.times = times;

