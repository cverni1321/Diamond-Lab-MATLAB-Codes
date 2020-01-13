function [plottype] = getplottype(num, varargin)

% Give a different plot style for all the different plots.
%
% num       - the line number
% lastcolor - the number of color variations to allow (1-6)
% lasttype  - the number of marking variations to allow (1-12)

lastcolor = [];
if length(varargin) > 0
    lastcolor = varargin{1};
    if lastcolor > 6
        warning('getplottype:input', 'lastcolor must be <= 6')
    end
end
if isempty(lastcolor)
    lastcolor = 6;
end

lasttype = [];
if length(varargin) > 0;
    lasttype = varargin{2};
    if lasttype > 12
        warning('getplottype:input', 'lasttype must be <= 12')
    end
end
if isempty(lasttype)
    lasttype = 12;
end

if (num < 1) || (lastcolor < 1) || (lasttype < 1)
    error('All arguments must be positive')
end

plotcolor = 'bgrcmk';
plotcolor = plotcolor(1:lastcolor);
plottypes = 'ox+*sdv^<>ph';
plottypes = plottypes(1:lasttype);
linetype = {'-' ':' '-.' '--' ' '};

num = num - 1;

typesmod = mod(num, length(plottypes));
num = (num-typesmod)/length(plottypes);

colormod = mod(num, length(plotcolor));
num = (num-colormod)/length(plotcolor);

linemod = mod(num, length(linetype));

plottype = strcat(plotcolor(colormod+1), plottypes(typesmod+1), linetype{linemod+1});

end
