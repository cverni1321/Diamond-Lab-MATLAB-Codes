function [varargout] = well2rowcolumn(well)

% Convert well numbers ('B03') to row and column number notation (2,3).
% If there is one output arguement, the output will be [ row col ] if there
% are two, it will be row, col.
%
% Well can be either a string array or a cell array.
%
% See also: rc2well

well = lower(strvcat(well));

row = well(:,1) - 'a' + 1;
col = str2num(well(:,2:end));

if (nargout == 2)
    varargout{1} = row;
    varargout{2} = col;
elseif (nargout < 2)
    varargout{1} = [row, col];
else
    error('Invalid number of output arguments');
end