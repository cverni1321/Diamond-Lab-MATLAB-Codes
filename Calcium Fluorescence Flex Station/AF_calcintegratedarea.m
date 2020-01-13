function retval = AF_calcintegratedarea(varargin)

% Calculate the integrated area under the curves

if iscell(varargin{1})
    retval = AF_calcintegratedarea_ext(varargin{:});
else
    retval = AF_calcintegratedarea_int(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function retval = AF_calcintegratedarea_int(data, times)

pointtostart = 1; % Can also try to neglect first few points to correct for jump at dispense;
                  % Mei was wondering if there was a better way to detect
                  % this automatically        
data = data(pointtostart:end);
times = times(pointtostart:end)-times(pointtostart);
area = trapz(data); % Trapezoidal numerical integration function
retval = area;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function area = AF_calcintegratedarea_ext(results) % Calculate the final values and the errors

areas = nan(size(results));
for i = 1:length(results)
    if ~isempty(results{i})
        areas(i) = results{i};
    end
end

area.integratedarea = nanmean(areas);
area.error = nanstd2(areas);
area.values = areas;