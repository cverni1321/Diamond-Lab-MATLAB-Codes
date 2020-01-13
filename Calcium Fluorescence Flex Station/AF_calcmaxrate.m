function retval = AF_calcmaxrate(varargin)

% Calculate the maximum rate from the normalized data

if iscell(varargin{1})
    retval = AF_calcmaxrate_ext(varargin{:});
else
    retval = AF_calcmaxrate_int(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function retval = AF_calcmaxrate_int(data, times) % Find the point where the data is maximum

diffs = diff(data, 1, 1);
retval.value = max(diffs);
retval.time = times(find(retval.value == diffs, 1)); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function maxrate = AF_calcmaxrate_ext(results) % Calculate the final values

times = nan(size(results));
values = times;
for i = 1:length(results)
    if ~isempty(results{i})
        times(i) = results{i}.time;
        values(i) = results{i}.value;
    end
end

maxrate.time = nanmean(times);
maxrate.error = nanstd2(times);
maxrate.times = times;
maxrate.values = values;

