function expt = flowcyt_setupexperiment(expt, query)

% Setup an experiment for use with Accuri C6 with the following
% values.
%
% 'expt' is an optional input and output with the following fields (all
% fields are optional as well):
%
% FIELDNAME         DESCRIPTION
%
% datadir           Directory with the file(s) in it (expt: '')
% xlsfile           Excel file containing the data (expt: '')                 
% labelfile         Name of the file (csv) or sheet within the xlsfile that
%                   contains the labels (expt: 'Labels')
% nwells            Number of wells in the plate (expt: 96)
% sortfield         Field within the samewells structure to sort. Wells 
%                   are sorted in ascending order with highest priority 
%                   given to the first field. This may be pipe ('|') 
%                   separated to sort by multiple fields.(expt: 'label')
% title             Title for the plots (expt: '')
% startcol          Defines which column in the plate the reader starts
%                   with (expt: '1')
% endcol            Defines which column in the plate the reader ends with
%                   (expt: '12')

if nargin < 2
    query = 0;
end

if query == 0
    askflag = 1; % ie start afresh and ask for all the defaults again
    % if askflag = 0 then there is no need to ask the questions again
else
    askflag = 0;
end

% Define the default values. These get overwritten by anything existing
% in the expt structure if it is already present
    expt.datadir = '';
    expt.xlsfile = '';
    expt.labelfile = '';
    expt.nwells = '96';
    expt.sortfield = 'conc.A|conc.U|conc.C|conc.SFL|conc.AYP|conc.Ilo';  
    % Can change sortfield depending on which agonists are being used  
    expt.title = '';
    expt.startcol = '1';
    expt.endcol = '12';

prompts = {'What directory are we working in?', ...
    'What is the filename to analyze (.xls)?', ...
    'What file contains the labels (.csv)?', ...
    'How many wells were there in the well plate?',...
    'How would you like to sort the data?', ...
    'What would you like to title the plot?', ...
    'Which column would you like to start with?',...
    'Which column would you like to end with?',...
    };

% Fill in the prompts with the default answers indicated above
defans = {expt.datadir, ...
    expt.xlsfile, ...
    expt.labelfile, ...
    expt.nwells,...
    expt.sortfield, ...
    expt.title, ...
    expt.startcol, ...
    expt.endcol, ...
    };

% Get data from the user
if askflag
    defans = inputdlg(prompts, 'General Settings for Fluorescence Analysis', 2, defans);
    expt.datadir = defans{1};
    expt.xlsfile = defans{2};
    expt.labelfile = defans{3};
    expt.nwells = str2double(defans{4});
    expt.sortfield = defans{5};
    expt.title = defans{6};
    expt.startcol = str2double(defans{7});
    expt.endcol = str2double(defans{8});
end

% Save everything up to this point
savefile = fullfile(expt.datadir, 'matlab.mat');

if isempty(expt.xlsfile)
    % If the .xlsfile is left blank, then it will load previous values
    % of the experimental setup from the matlab.mat file in the datadir.
    disp('Loading configuration')
    load(savefile)
    % Convert from the old variable format to the new format  
    % This is needed to load old data, but it is not currently used
    expt.xlsfile = xlsfile;
    expt.datasheet = datasheet;
    expt.title = mytitle;
    expt.nwells = nwells;
    expt.labelfile = labelfile;
    expt = mergestructs(expt, default); 
    
else
    % Setup the filename to come from the data directory (this will most
    % often be the case since the Excel file will be different for each
    % experiment)
    [d, f, e] = fileparts(expt.xlsfile);
    
    if (~ isempty(expt.xlsfile))
        % Keep the directory name from the beginning for the xlsfile
        expt.xlsfile = fullfile(expt.datadir, f, e);
    end

    % Add the data directory path to the label file if it doesn't come from
    % the excel file.
    if isempty(strfind(expt.labelfile, expt.datadir)) && (~ isempty(expt.labelfile)) && ...
            (~ isempty(strfind(expt.labelfile, '.txt')))
        expt.labelfile = fullfile(expt.datadir, expt.labelfile);
    end

    % Setup the filename of 'labelfile'
    [d, f, e] = fileparts(expt.labelfile);
    if strcmpi(d, expt.datadir) && (~ isempty(expt.labelfile))
        % Remove the directory name from the beginning for the labelfile
        expt.labelfile = [f, e];
    end
    if strcmpi(e,'')
        % If no extension is given, give it a .csv extension
        expt.labelfile = [f '.csv'];
    end  
end

disp('Saving configuration')
save(savefile, 'expt')

end 