function optstruct = setopt(varargin)

% Set options into a structure for a variable number of inputs
%
% defaults  - (optional) a structure containing the default options to
%             integrate the rest of the options into.
% option    - the name of the option to set.
% value     - the value of the option to set.
%
% optstruct - the structure containing the set options.  for empty input,
%             it will return an empty output.
%
% Note: If you're wanting to use a varargin from one function and directly
% pass it in here, you probably want to use varargin{:} to split up the
% arguments.  Otherwise it will look like a single cell here and you will
% get an error for an 'Invalid number of options'.

optstruct = struct();
startpos = 1;

if (isempty(varargin))
    return;
end

% Put in defaults if necessary
if (isstruct(varargin{1}))
    optstruct = varargin{1};
    startpos = 2;
end

% Validate the input
if mod((length(varargin) - startpos), 2) ~= 1
    error('Invalid number of options');
end

for i = startpos:2:length(varargin)
    if ~ ischar(varargin{i})
        error('Option names must be strings');
    end
    optstruct.(varargin{i}) = varargin{i+1};
end

end