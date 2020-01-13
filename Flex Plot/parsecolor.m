function c = parsecolor(s)

% Parse color options from distinguishablecolors.m.

if ischar(s)
    c = colorstr2rgb(s); % See below for 'colorstr2rgb' code
elseif isnumeric(s) && size(s,2) == 3
    c = s;
else
    error('MATLAB:InvalidColorSpec', 'Color specification cannot be parsed.');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function c = colorstr2rgb(c)

% Convert a color string to an RGB value.

rgbspec = [1 0 0; 0 1 0; 0 0 1; 1 1 1; 0 1 1; 1 0 1; 1 1 0; 0 0 0];
cspec = 'rgbwcmyk';
k = find(cspec == c(1));

if isempty(k)
    error('MATLAB:InvalidColorString', 'Unknown color string.');
end

if k~=3 || length(c) == 1
    c = rgbspec(k,:);
elseif length(c) > 2;
    if strcmpi(c(1:3), 'bla')
        c = [0 0 0];
    elseif strcmpi(c(1:3), 'blu')
        c = [0 0 1];
    else
        error('MATLAB:UnknownColorString', 'Unknown color string.');
    end
end

end
