function expt = AF_calculations(expt, fieldname, internalcalcfunction, externalcalcfunction, varargin)

% Calculate something, anything.  The internal calcfunction is given the
% cleaned data for each well individually.  It is called as:
%
% result{i} = internalcalcfunction(data, times, options{:});
%
% OPTIONS for calculation
% NAME       DESCRIPTION
% dataset    Which data set should be used ('data' or 'rawdata')
%            default: 'data'
%
% NOTE: The internal function is not called when there is no data available
% and this should be taken into account in the external function (the
% result will be an empty cell for that case).
%
% After that has been run on a set of wells, the external calc function is
% run to combine any necessary values, and it will be called as:
%
% expt.samewells(welltypenum).(fieldname) = externalcalcfunction(result);
%
% The external function should return the result in the way that you want
% it going into the samewells structure (probably a structure that's
% returned).

option.dataset = 'data';
option = setopt(option, varargin{:});

for welltype = 1:length(expt.samewells)
    data = expt.samewells(welltype).(option.dataset);
    
    % Make it show a warning only once for a well
    if ~isfield(expt.samewells(welltype), 'nodata') || ...
            isempty(expt.samewells(welltype).nodata)
        expt.samewells(welltype).nodata = zeros([1 size(data,2)]);
    end
    
    result = cell(1, size(data,2));
    for i = 1:size(data,2)
        thisdata = data(:,i);
        thistime = expt.samewells(welltype).time(:,i);
        
        % Remove data during initial descent
        diffs = diff(thisdata);
        firstpt = find(diffs>0, 1);
        lastpt = length(thisdata);
        
        thisdata = thisdata(firstpt:lastpt);
        thistime = thistime(firstpt:lastpt);
        
        if isempty(thisdata)
            if ~expt.samewells(welltype).nodata(i)
                warning('Fluorescence:calculation', ...
                    'No data between the minimum and maximum value for column %d of\n"%s".', ...
                    i, expt.samewells(welltype).label);
                expt.samewells(welltype).nodata(i) = 1;
                result{i} = NaN;
            end
            
        else
            result{i} = internalcalcfunction(thisdata, thistime, varargin{:});
        end
    end
    
    % Combine the results
    expt.samewells(welltype).(fieldname) = externalcalcfunction(result);
end

end

