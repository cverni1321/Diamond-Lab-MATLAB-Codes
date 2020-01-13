function [data, rawdata, times, mindata, maxdata, skipped, expt, totalrawdata, totaltimes] = AF_readdata(expt, varargin)

% Read the data from a calcium fluorescence experiment

% Choose the function to read the data from the fluorescent reader (Mei
% added this)
expt.datasheet = 'Data';
expt.dyename = 'Fluo4';

readeroptions = {'sheet', expt.datasheet};

    readfluorescence = @AF_readfluorescence;
    % The @ symbol basically calls a function and assigns it as a variable
    % (here it assigns the FA_readfluorescence_flextrial function to the
    % 'readfluorescence' variable which appears a few lines below
    readeroptions(end+1:end+2) = {'dye', expt.dyename};
    readeroptions(end+1:end+2) = {'dispensetime',expt.dispensetime};
    readeroptions(end+1:end+2) = {'dispensecorrection',expt.dispensecorrection};

% Read the data
volnormchoice = 0; volnormfactor = 1; % No volume normalization occurs for the FlexStation data
[rawdata, times, skipped] = ...
        readfluorescence(fullfile(expt.datadir, expt.textfile), expt.nwells, readeroptions{:});
    
maxdata = max(rawdata, [], 5); % The array has five dimensions (see the data and times variables from FA_readfluorescence)
maxtimes = times(:, :, :, :, end)+1; % Assume that the max times is the first reading after the data

totalrawdata = rawdata;
totaltimes = times;

squeeze(totalrawdata);
squeeze(totaltimes);

% Take the raw data and normalize it
[data,maxdata,mindata,times,rawdata] = AF_normalizedata(rawdata,maxdata,times,expt);

end
