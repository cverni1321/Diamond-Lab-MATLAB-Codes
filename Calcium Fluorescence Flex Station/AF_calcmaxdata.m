function retval = AF_calcmaxdata(varargin)

% Calculate the maximum data. If 2D data is given, the times should proceed
% down the rows and the different datasets should be in different columns

if iscell(varargin{1})
    retval = AF_calcmaxdata_ext(varargin{:});
else
    retval = AF_calcmaxdata_int(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function retval = AF_calcmaxdata_int(data, times) % Find the point where the data is maximum

retval = data(find(data == max(data), 1));

% Mei had a comment that said the user should have the option to choose to
% ignore the first few data points if desired


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function maximumdata = AF_calcmaxdata_ext(results) % Calculate the final values

maxdata = nan(size(results));
for i = 1:length(results)
    if ~isempty(results{i})
        maxdata(i) = results{i};
    end
end

maximumdata.meanvalue = nanmean(maxdata);
maximumdata.error = nanstd2(maxdata);
maximumdata.values = maxdata;