function expt = AF_setconcs(expt)

% Set the concentrations for each well type as a way to sort the data
%
% Make a structure that has the following fields:
% - .conc = actual concentration value (a number)
% - .unit = concentration unit (e.g. molarity, percent, etc)
% - .spc = species name


for i = 1:length(expt.samewells)
    matches = regexp(expt.samewells(i).label, '(?<spc>\w+)\|(?<conc>[0-9.]+)\ (?<unit>[fpnum]?M)', 'names');
        % NOTE: No blanks allowed in the species name. Each species name
        % must be followed by a comma immediately after (i.e. '5 uM ADP,' is
        % allowed but '5 uM ADP ,' is not allowed)
        
    for j = 1:length(matches) % For each compound found in the label
        switch matches(j).unit(1)
            case {'f'} % femtomolar (fM)
                mxplier = 1e-15;
            case {'p'} % picomolar (pM)
                mxplier = 1e-12;
            case {'n'} % nanomolar (nM)
                mxplier = 1e-9;
            case {'u'} % micromolar (uM)
                mxplier = 1e-6;
            case {'m'} % millimolar (mM)
                mxplier = 1e-3;
            case {'M' 'g'} % molar (M)
                mxplier = 1;
            case {'%'}
                mxplier = 1e-2;
            otherwise
                error('Unknown units %s', matches(j).unit);
        end
        
        % Set the concentration to the correct value (apply multiplier)
        expt.samewells(i).conc.(matches(j).spc) = mxplier*str2double(matches(j).conc);
        
        % Set the units used on the current species
        if mxplier == 1;
            unitname = matches(j).unit;
        else
            unitname = matches(j).unit(2:end);
        end
        
        expt.samewells(i).units.(matches(j).spc) = unitname;
    end
    
    % Match the blood dilution factor (not sure what this does exactly)
    dfmatches = regexp(expt.samewells(i).label, ...
        '(?<blooddf>[0-9.]+)x (diluted blood|dilution)', 'names');
    if ~isempty(dfmatches)
        expt.samewells(i).conc.blooddf = str2double(dfmatches.blooddf);
    end
    
    stockmatches = regexp(expt.samewells(i).label, '(?<stock>[0-9]+)x stock', 'names');
    if ~isempty(stockmatches)
        expt.samewells(i).conc.bloodstock = str2double(stockmatches.stock);
    end
    
end

end
    

