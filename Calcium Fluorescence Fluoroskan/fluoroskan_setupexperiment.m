function expt = fluoroskan_setupexperiment(expt, query)

% Setup an experiment for use with fluoroskan with the following
% values.
%
% 'expt' is an optional input and output with the following fields (all
% fields are optional as well):
%
% FIELDNAME         DESCRIPTION
%
% datadir           Directory with the file(s) in it (expt: '')
% textfile          Text file containing the data (expt: '')
%                   This is an MS-Excel file for Fluoroskan data, but
%                   should be in .txt format for FlexStation data
% labelfile         Name of the file (csv) or sheet within the xlsfile that
%                   contains the labels (expt: 'Labels')
% fluorescentreader Fluorescent reader used to read the data ('fluoroskan'
%                   'Flex' or 'envision') (expt: 'flex')
% nwells            Number of wells in the plate (expt: 384)
% sortfield         Field within the samewells structure to sort. Wells 
%                   are sorted in ascending order with highest priority 
%                   given to the first field. This may be pipe ('|') 
%                   separated to sort by multiple fields.(expt: 'label')
% title             Title for the plots (expt: '')
% startcol          Defines which column in the plate the reader starts
%                   with (expt: '1')
% endcol            Defines which column in the plate the reader ends with
%                   (expt: '12')
% dye               Identifies which type of fluorescent Ca dye is used
%                   (expt: 'Fluo4') 


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
    expt.textfile = '';
    expt.labelfile = '';
    expt.nwells = '384';
    expt.sortfield = '';  
    % Can change sortfield depending on which agonists are being used  
    expt.title = '';
    expt.startcol = '1';
    expt.endcol = '24';
    expt.normalize = '';
    expt.dispensecorrection = '';
    expt.seconddispensetime = '';
    expt.addpredispensebaseline = '';

    
% The following fields were included in Mei's version of the code, though
% it looks like she decided not to use them after all. Activate them if
% necessary.
% 
% datasheet         Sheet name within the excel file containing the data
%                   (expt: 'Data')
% maxfile           Name of the file (csv) or sheet within the xlsfile that
%                   contains the (possibly) maximum values for each well
%                   (default: 'Max')
% discardflatlined  Discard flatlined data (default: 'n')
% flatlinepercent   Percentage a sample must pass to be considered
%                   non-flatlined
% initpercent       Percentage that is considered initialization (default:
%                   0.05)
% pts2chuck         The number of points you want to chuck after the dispense  (default 2)
%                   (used for Flexstation -Fura2)
%
% 
% plot.
%   individual.
%     normalized    Plot normalized individual data (default: 'n')
%     raw           Plot raw individual data (default: 'y')
%     subplotrows   Number of rows to use in the subplot (default: 8)
%     subplotcols   Number of columns to use in the subplots (default: [])
%     nmarkers      Number of markers on each plot (default: 20)
%     ncategories   Number of categories (for coloration) in each plot
%                   (default: 6)
%     sorted        Plot the sorted data (default: 'y')
%
% timeadj           An n x 2 cell array with a string to match to a label
%                   (using strfind) in column 1 and an amount of time to
%                   adjust the time for that set of wells by in column 2.
%                   This is not settable in the GUI.
%
% normalizationlabel     The label that is used for the max file on the envision
% plateletlabel          The label that is used for the data collection
% plateletpump           Pump used to dispense platelets
% normalizationpump      Pump used to dispense the normalizing chemical on the
%                        envision (used for Flexstation - Fura2)
% 
% 
% plots
%     expt.plot.individual.normalized = 'n';
%     expt.plot.individual.raw = 'y';
%     expt.plot.individual.subplotrows = 8;
%     expt.plot.individual.subplotcols = [];
%     expt.plot.nmarkers = 20;
%     expt.plot.ncategories = 4;
%     expt.plot.sorted = 'y';
%     
%     expt.initsetmaxtime = 1;
%     expt.normtype = 'well';
%     advancedoptions = 'n';

prompts = {'What directory are we working in?', ...
    'What is the filename to analyze (.xlsx)?', ...
    'What file contains the labels (.csv)?', ...
    'How many wells were there in the well plate?',...
    'How would you like to sort the data?', ...
    'What would you like to title the plot?', ...
    'Which column would you like to start with?',...
    'Which column would you like to end with?',...
    'Do you want to normalize the data by the first point?',...
    'Do you want to correct for the crazy jump/discontinuity after second agonist dispense?',...
    'If yes to dispense correction, what is the time of second agonist dispense?',...
    'Do you want to add a pre-dispense baseline of 20 sec to mimic the Flex Station?',...
    };

% Fill in the prompts with the default answers indicated above
defans = {expt.datadir, ...
    expt.textfile, ...
    expt.labelfile, ...
    expt.nwells,...
    expt.sortfield, ...
    expt.title, ...
    expt.startcol, ...
    expt.endcol, ...
    expt.normalize,...
    expt.dispensecorrection,...
    expt.seconddispensetime,...
    expt.addpredispensebaseline,...
    };

% Get data from the user
if askflag
    defans = inputdlg(prompts, 'General Settings for Fluorescence Analysis', 2, defans);
    expt.datadir = defans{1};
    expt.textfile = defans{2};
    expt.labelfile = defans{3};
    expt.nwells = str2double(defans{4});
    expt.sortfield = defans{5};
    expt.title = defans{6};
    expt.startcol = str2double(defans{7});
    expt.endcol = str2double(defans{8});
    expt.normalize = defans{9};
    expt.dispensecorrection = defans{10};
    expt.seconddispensetime = defans{11};
    expt.addpredispensebaseline = defans{12};
end

% Save everything up to this point
savefile = fullfile(expt.datadir, 'matlab.mat');

if isempty(expt.textfile)
    % If the .textfile is left blank, then it will load previous values
    % of the experimental setup from the matlab.mat file in the datadir.
    disp('Loading configuration')
    load(savefile)
    % Convert from the old variable format to the new format  
    % This is needed to load old data, but it is not currently used
    expt.textfile = textfile;
    expt.datasheet = datasheet;
    expt.title = mytitle;
    expt.nwells = nwells;
    expt.labelfile = labelfile;
    expt = mergestructs(expt, default); 
    
else
    % Setup the filename to come from the data directory (this will most
    % often be the case since the Excel file will be different for each
    % experiment)
    [d, f, e] = fileparts(expt.textfile);
    
    if (~ isempty(expt.textfile))
        % Keep the directory name from the beginning for the xlsfile
        expt.textfile = fullfile(expt.datadir, f, e);
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