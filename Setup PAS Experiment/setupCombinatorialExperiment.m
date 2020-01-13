function [plate, exitflag, option] = setupCombinatorialExperiment(species, states, option)

% Set up the concentration map for a combinatorial reagent experiment (e.g.
% PAS). Buffer is always assumed to be a control in the first well. Files
% will be outputted to the current directory by default.
%
% Output file names have the format:
%   "option.FileStart"_"dd_mmm_yyyy"_"plateNumber".xlsx/csv
%
% option.FileStart may contain a path name, (e.g. C:\Data\filestring) but should not contain a file extension.
% 
% Example, if option.FileStart = C:\Data\myExperiment and if 
% option.method = 'auto', then the three files outputted would be (if the 
% experiment fits on one plate and the experiment was done on 3/22/2014):
%       C:\Data\myExperiment_ELH_22-Mar-2014_plate_1.xlsx
%       C:\Data\myExperiment_22-Mar-2014_labels_plate_1.csv
%       C:\Data\myExperiment_22-Mar-2014_plate_1.csv
%
% The new variable, option.effectivePlateSize, will force each agonist 
% plate to use fewer than the number of physical wells. This is useful in
% allowing for multiple repeats of conditions on a single read plate when 
% there are a large number of experimental conditions spread over multiple 
% plates (but PAS experiments will only require one plate).
%
% If using multiple stocks for a particular species, you must provide a
% stock for each state. 
%
%   INPUTS:     species - 1xn cell array {} containing the species names
%               states  - Matrix [] containing the final concentrations you
%                         want to use for each species. Columns correspond
%                         to different species and rows correspond to
%                         different concentrations. Concentrations of 0 are
%                         ignored and thus you can use 0 as a placeholder
%                         for when different species have different numbers
%                         of states.
%
%   OPTION STRUCTURE: (optional input)
%               k       - Combination size (default:2 for pairwise expt)
%               kend    - Minimum combination size (default:1)
%               stock   - Matrix containing the concentration of stock
%                         solution used to make each species/state pair. If
%                         defined, must be the same size as states, but you
%                         can use the same concentration in multiple rows
%                         which will tell the program to make those states
%                         from the same stock concentration. By default,
%                         all states are made from one stock.
%                         (default:empty)
%               method  - Method for assigning the species and state
%                         combinations to wells. 'auto' just places
%                         the well types onto a plate in a column-wise
%                         fashion, 'manual' outputs the well types as a
%                         column vector which can then be copied/pasted
%                         into an excel file. Setting this to 'converter' 
%                         will cause the program to use the
%                         options.converter structure to go from the
%                         automatically generated well list to an arranged
%                         one.
%                         When set to 'manual' no files are written to
%                         disk; the well list is passed as the output.
%                         
%
%   OUTPUTS:    plate   - Structure containing info about the well plate.
%                         The information it contains varies depending on
%                         the inputs to setuppasexperiment.
%               exitflag - 0 : no files written
%                        - 1 : one or more xlsx or csv files written to the
%                              current directory


% Determine which directory the program resides in so we so where to find
% the default Janus setup file template used to build an intermediate xlsx
% file
temp = mfilename('fullpath');
slash_index = regexp(temp, filesep);
temp = temp(1:slash_index(end)-1);

% Get platform so we know how to use the xlsx or csv files
if ispc
    extension = '.xlsx'; % Assume MS Excel 2007 or later is installed
else
    extension = '.csv';
end

% Set the default options
default.k = 2; % Max number of agonist plate species combinations
default.kend = 1; % Min number of agonist plate species combinations
default.stock = states*10; % Stock concentrations, each column may contain duplicates so that multiple states can be drawn from one stock
default.method = 'auto'; % Plate setup option ('auto', 'manual', or 'converter')
default.converter = []; % Converter structure which specifies how to arrange the agonist place species combinations
default.readconverter = []; % Converter structure which specifies how to arrange the read place species combinations
default.platesize = 384; % Size of read and agonist plates
default.platetype = 'agonist'; % Either 'agonist' or 'read'
default.effectiveplatesize = 384; % Only use a maximum of this number of wells in making each plate
default.type = {'PRP'}; % 1xn cell array of blood types being tested
default.typeconc = []; % Matrix of final blood concentrations (percentage units)
default.typestock = [20]; % Blood "stock" concentrations
default.readplatespecies = {}; % 1xn cell array of read plate species (optional)
default.readplateconcs = []; % Matrix of final read plate concentrations (similar to states matrix)
default.readstock = []; % Read plate stock concentrations
default.krstart = 2; % Upper range of read plate species combinations
default.krend = 1; % Lower range of read plate species combinations
default.writeagonistplate = 1; % Set to 1 to write out agonist plate to Janus Excel files
default.writereadplate = 0; % Set to 1 to also write out a label file for the read plate
default.filestart = 'janus_setup_plate'; % Main string for files to be written
default.date = date; % Today's date in the format dd-mmm-yyyy
default.overwrite = 1; % Set to 0 to ensure existing xlsx or csv files are never overwritten
default.nreps = 1; % Repeat the well list this number of times when making the plate
default.wellvol = 60; % Volume in the wells on the agonist plate (uL)
default.placement = 'rotate'; 
default.dispenseone = 20; % First dispense volume (uL)
default.dispensetwo = 0; % Second dispense volume (uL)
default.dispensethree = 0; % Third dispense volume (uL)
default.initialbloodvol = 30; % Initial blood volume in read plate (uL)
default.dispensemap = '1,2,3'; % '1,2,3' means first dispense taken from column 1, second dispense from column 2
default.writefile = [temp filesep 'janus_setup_template' extension];
default.readfile = [temp filesep 'janus_setup_template' extension]; % Location of template file used to build the Janus setup file
default.rowstart = 1; 
default.rangestart = 'A1';
default.rangeend = 'C17';
default.altvol = 2; % How to calculate final Janus dispense volumes
default.sheet = 'Settings'; % Which sheet to read the concentrations from
default.optwell = 0; % Optimize well order, keep this off because it was messing with the protocol
default.fill = 0; 

% If 'getopt' is the only input option argument, output the default options and
% end program
if nargin == 3 && strcmp('getopt', option)
    plate = default;
    return
end

% Combine the default options with user-given options
option = setstructfields(default, option);

% Reassign options to individual variables
k = option.k;
kend = option.kend;
stock = option.stock;
method = option.method;
typeconc = option.typeconc;
converter = option.converter;
platesize = option.platesize;
type = option.type;
readplatespecies = option.readplatespecies;
readplateconcs = option.readplateconcs;
krstart = option.krstart;
readconverter = option.readconverter;
krend = option.krend;
readstock = option.readstock;
typestock = option.typestock;
writeagonistplate = option.writeagonistplate;
writereadplate = option.writereadplate;

typecount = length(type);

if isempty(typeconc)
    typeconc = typestock*option.initialbloodvol/(option.dispenseone+option.dispensetwo+option.dispensethree+option.initialbloodvol);
else
    typestock = typeconc*(option.dispenseone+option.dispensetwo+option.dispensethree+option.initialbloodvol)/option.initialbloodvol;
end

% Check for errors
option.filestart((strfind(option.filestart, '.'):end)) = []; % option.filestart should not contain a file extension

if ~iscell(species)
    error('List of species must be in cell format.')
end

if k > length(species)
    error ('The size of the combinations is greater than the number of species.')
end

if nargin < 2
    error('SCE:ArgChk', 'A species list (cell array vector, first input) and a concentration matrix (second input) are required.')
end

if any(states == 0)
    warning('States that are defined as zero are being ignored.')
end

if any(any(stock == 0))
    error('None of the stocks can have zero concentration of species.')
end

if strcmp(method, 'converter') && isempty(converter)
    error('Agonist plate converter structure not defined.')
end

if strcmp(method, 'converter') && ~isempty(type) && isempty(readconverter)
    error('Read plate converter structure not defined.')
end

if typecount > length(typeconc)
    error('Not all of the blood type concentrations have been specified.')
end

if typecount < length(typeconc)
    error('Too many blood concentrations have been given.')
end

if k < kend
    error('Max number of combinations (k) must be greater than or equal to the min number of combinations (kend).')
end

if option.effectiveplatesize > platesize || option.effectiveplatesize <= 0
    option.effectiveplatesize = platesize;
    warning('SCE:ArgChk','Setting option variable ''effectiveplatesize'' equal to physical plate size of %d wells.',platesize)
end


readmap = [];
stock = sort(stock, 1, 'descend');
states = sort(states, 1, 'descend');

% Get the well combinations
map = makecombos(species, states, k, kend, platesize); % Either get this from Mei or make it myself

% Get well combinations of read plate species if they are given (usually
% won't have these)
if ~isempty(readplatespecies) && ~isempty(readplateconcs)
    readplateconcs = sort(readplateconcs,1);
    if ~strcmp(type,'readplatespecies{1}') && all(readplateconcs ~= typeconc)
        readplatespecies = [type; readplatespecies];
        readplateconcs = [repmat(typeconc,size(readplateconcs,1),1) readplateconcs];
    end
    readmap = makewells(readplatespecies,readplateconcs,krstart,krend,platesize);
    if isempty(readstock)
        readstock = readplateconcs(end,:);
        readstock(typecount + 1 : end) = readstock(typecount + 1 : end) * 10;
        readstock(1 : typecount) = typestock;
    elseif size(readstock,2) ~= typecount + length(species)
        readstock = [repmat(typeconc,size(readstock,1),1) readstock];
    end
end

species = [type; species];
states = [repmat(typeconc, size(states,1), 1) states];
stock = [repmat(typeconc, size(stock,1), 1) stock];

% Sort the wells
if strcmp(method, 'manual')
    exitflag = 0;
    plate.welllist = map;
    plate.readwelllist = readmap;
    return
elseif strcmp(method, 'auto') % This will usually be the case
    platesize = option.effectiveplatesize;
    map = ['Buffer'; map];
    flag = 0;
    if typecount > 1 || ~isempty(readplatespecies)
        sprintf('Read plate species will need to be set up manually. \n The read plate species have been outputted to the first plate.')
        plate(1).readwelllist = readmap;
        flag = 1;
    end
    map = repmat(map, option.nreps, 1);
    conditions = length(map);
    % Extend map over multiple plates if necessary
    if conditions > platesize
        platebounds = 1:platesize:conditions;
        for platecount = 1:length(platebounds)
            plate(platecount).name = [option.filestart '_' int2str(platecount)];
            if platebounds(platecount) + platesize < conditions
                plate(platecount).welllist = map(platebounds(platecount):platebounds(platecount)+platesize-1);
            else
                plate(platecount).welllist = map(platebounds(platecount):end);
            end
        end
        % If only one type of blood is given with no other species,
        % distribute that blood to each well
        if flag == 0
            plate(platecount).readwelllist = repmat(readmap, conditions, 1);
        end
    else
        plate.welllist(1:platesize) = NaN;
        plate.welllist = num2cell(plate.welllist');
        plate.welllist(1:conditions) = map;
        if flag == 0;
            plate.readwelllist = repmat(readmap, conditions, 1);
        end
        plate.name = option.filestart;
    end
    exitflag = 1;
elseif strcmp(method, 'converter') % Use the converter heuristic to arrange combinedwells
    for p = 1:length(converter)
        if isempty(converter(p).ind) % Stop when an empty plate is found
            break
        end
        plate(p).name = strcat(option.filestart, {'_'}, int2str(p));
        for i = 1:length(converter(p).ind)
            plate(p).welllist{converter(p).ind(i), 1} = map{converter(p).iAgonist(i)};
        end
        for i = 1:length(converter(p).iBuffer)
            plate(p).welllist{converter(p).iBuffer(i), 1} = 'Buffer';
        end
        for i = 1:length(converter(p).iNaN)
            plate(p).welllist{converter(p).iNaN(i), 1} = NaN;
        end
        for i = 1:length(readconverter(p).ind)
            plate(p).readwelllist{readconverter(p).ind(i), 1} = readmap{readconverter(p).iAgonist(i)};
        end
        for i = 1:length(readconverter(p).iBuffer)
            plate(p).readwelllist{readconverter(p).iBuffer(i), 1} = 'Buffer';
        end
        for i = 1:length(readconverter(p).iNaN)
            plate(p).readwelllist{readconverter(p).iNaN(i), 1} = NaN;
        end
    end
    exitflag = 1;
else
    exitflag = -1;
    error('The method is incorrectly defined.')
end

% Specify which column each species and state should go in
wellmapcol = ones(size(states,1), length(species));
readwellmapcol = wellmapcol;
dispwellmapcol = repmat(1:length(species), size(states,1), 1);
dispreadwellmapcol = repmat(1:length(readplatespecies), size(readplateconcs,1), 1);

% When a stock matrix is supplied, use it to determine which column of
% wellmap each species/state pair should go into
if size(stock,1) > 1
    uniques = diff(stock);
    uniques(abs(uniques) < 1e-20) = 0; % Fix round-off errors
    numstocks = sum(uniques~=0)+1;
    uniques = [ones(1,length(species)); uniques];
    uniques = abs(uniques);
    for i = 2:numel(stock)
        if uniques(i) > 0
            wellmapcol(i) = wellmapcol(i-1)+1;
        else
            wellmapcol(i) = wellmapcol(i-1);
        end
    end
   
% When no stock matrix is supplied, each species goes into the same column
% of wellmap no matter which state is being used
else
    numstocks = ones(1,length(species));
    wellmapcol = dispwellmapcol;
end

% Do the same as above for the read plate stocks
if size(readstock,1) > 1
    uniques = diff(readstock);
    numreadstocks = sum(uniques~=0)+1;
    uniques = [ones(1,length(readplatespecies)); uniques];
    for i = 2:numel(readstock)
        if uniques(i) > 0
            readwellmapcol(i) = readwellmapcol(i-1)+1;
        else
            readwellmapcol(i) = readwellmapcol(i-1);
        end
    end
else
    numreadstocks = ones(1,length(readplatespecies));
    readwellmapcol = dispreadwellmapcol;
end

% Convert the states/stocks to other molar units so that they match those
% contained in the well lists fields
tmp = convertstatesunits(states); % Make 'states' into string form
tmp2 = convertstatesunits(readplateconcs);
convertedstates = str2double(tmp);
convertedreadstates = str2double(tmp2);

[~, num, units] = convertstatesunits(stock);
stocklabels1 = strcat(num, units);
stockspecies = species';
for i = 1:size(stocklabels1,1)
    for j = 1:length(stockspecies)
        stocklabels2{i,j} = strcat(stockspecies{j}, ' (', stocklabels1{i,j}, ')');
    end
end 
count = 1;
stocklabels = {};
for i = 1:length(stockspecies)
    for j = 1:size(stocklabels1,1)
        stocklabels{count} = stocklabels2{j,i};
        count = count+1;
    end
end
stocklabels = stocklabels(3:end);

[~, num, units] = convertstatesunits(readstock);
readstocklabels1 = strcat(num, units);
readstockspecies = species';
for i = 1:size(readstocklabels1,1)
    for j = 1:length(readstockspecies)
        readstocklabels{i,j} = strcat(readstockspecies{j}, ' (', stocklabels{i,j}, ')');
    end
end

% Main loop for filling out the concentration matrix
for p = 1:length(plate)
    plate(p).wellmap = zeros(length(plate(p).welllist), sum(numstocks));
    plate(p).readwellmap = zeros(length(plate(p).welllist), sum(numreadstocks));
    plate(p).dispwellmap = zeros(length(plate(p).welllist), length(species));
    % Check if we need to make a read plate
    if isempty(plate(p).readwelllist)
        readflag = 0;
        writereadplate = 0;
    else
        readflag = -1;
    end
    if readflag
        for i = 1:length(plate(p).readwelllist) % First do the read plate
            if ~isempty(plate(p).readwellist) && ischar(plate(p).readwelllist{i}) % Separate into the different species in well 'i'
                [start_idx, end_idx, extents, matches, tokens, names, speciesstatespairs] = regexp((plate(p).readwelllist{i}), '\,', 'match');
                for j = 1:length(speciesstatepairs) % Separate the species and states pairs
                    [start_idx, end_idx, extents, matches, tokens, names, speciesandstates] = regexp(speciesstatespairs{j}, '\|', 'match'); 
                    if ~isempty(strmatch(speciesandstates{1}, type)) % Extract the species and states information in well 'i' and distribute it to the well map
                        [start_idx, end_idx, extents, matches, tokens, names, stateandunits] = regexp(speciesandstates{2}, '%', 'match');
                    else
                        [start_idx, end_idx, extents, matches, tokens, names, stateandunits] = regexp(speciesandstates{2}, ' ', 'match'); % Separate the value from the units
                    end
                    column = find(ismember(readplatespecies, speciesandstates{1}) == 1); % Find the species index (ie. which column of wellmapcol)
                    row = find(ismember(convertedrowstates(:,column), str2double(stateandunits{1})) == 1); % Find the state index
                    plate(p).readwellmap(i, readwellmapcol(row,column)) = readplateconcs(row,column);
                    plate(p).dispreadwellmap(i, dispreadwellmapcol(row,column)) = readplateconcs(row,column);
                end
            end
        end
    end
    for i = 1:length(plate(p).welllist) % Next do the agonist plate
        if ischar(plate(p).welllist{i}) % First separate into the different species in well i
            [start_idx, end_idx, extents, matches, tokens, names, speciesstatepairs] = regexp((plate(p).welllist{i}), '\,', 'match');
            if strcmp(speciesstatepairs{1}, 'Buffer') % Is the first well just buffer?
                continue
            end
            for j = 1:length(speciesstatepairs) 
                [start_idx, end_idx, extents, matches, tokens, names, speciesandstates] = regexp(speciesstatepairs{j}, '\|', 'match'); % Separate the species and state pairs
                [start_idx, end_idx, extents, matches, tokens, names, stateandunits] = regexp(speciesandstates{2}, ' ', 'match'); % Separate the value from the units
                % Extract the species and state information in well 'i' and
                % distribute it to the well map (same as above for read
                % plate)
                column = find(ismember(species, speciesandstates{1}) == 1);
                row = find(ismember(convertedstates(:,column), str2double(stateandunits{1})) == 1);
                plate(p).wellmap(i, wellmapcol(row,column)) = states(row,column);
                plate(p).dispwellmap(i, dispwellmapcol(row,column)) = states(row,column);
            end
        end
    end
    
    if typecount == 1
        plate(p).wellmap(:,1) = typeconc; % If only one type of blood exists, fill out the first column of the well map with it
    elseif ~isempty(plate(p).readwelllist)
        plate(p).wellmap(:,1:typecount) = plate(p).readwellmap(:,1:typecount);
    else
        disp('Since there is more than one blood type specified, they need to be manually assigned to wells.');
    end
    
    % Create list of species/stocks present for plate p
    plate(p).dispwellmap = plate(p).dispwellmap(:, length(type)+1:end);
    % Mei had some stuff commented out here
    plate(p).species = species;
    plate(p).stock = stock;
    plate(p).states = states;
    if readflag
        plate(p).readplatespecies = readplatespecies;
        plate(p).readstock = readstock;
        plate(p).readplateconcs = readplateconcs;
    end
    
    % Make well map matrix suitable for color-coded 'barcode' plot
    plate(p).dispwellmap = plate(p).dispwellmap./repmat(states(1,length(type)+1:end), size(plate(p).dispwellmap, 1), 1);
    if readflag
        plate(p).dispreadwellmap = plate(p).dispreadwellmap./repmat(readplateconcs(1,:), size(plate(p).dispreadwellmap, 1), 1);
    end
    
    % Some columns might be empty since not all species may appear on all
    % plates. Remove these. Also combine the stock labels with the wellmap
    plate(p).wellmap = plate(p).wellmap(1:size(plate(p).dispwellmap,1),:);
    if readflag
        plate(p).readwellmap = plate(p).readwellmap(1:size(plate(p).dispreadwellmap,1),:);
    end
    
    plate(p).finalmap = {};
    plate(p).finalmap{1,1} = 'Begin Well Types';
    plate(p).finalmap{platesize+1,1} = 'End Well Types';
    for i = 1:length(stocklabels)
        plate(p).finalmap{1,(i+1)} = stocklabels{1,i};
    end
    for i = 1:size(map,1)
        plate(p).finalmap{(i+1),1} = map{i,1};
    end
    index = 2;
    for j = 1:platesize
        for k = 1:length(stocklabels)
            plate(p).finalmap{index,(k+1)} = plate(p).wellmap(j,k);
        end
        index = index+1;
    end
    plate(p).stocklabels = stocklabels;
    
    % Write the plate info to an Excel file
    if writeagonistplate > 0
        option.platename = ['Plate_' num2str(p)];
        option.platetype = 'Agonist';
        [labels_plate, stocks_plate, dispense_plate, exitflag] = writeplates(plate(p), option);
        % Conditionally write the read plate
        if writereadplate > 0
            option.platetype = 'Read';
            [readlabels_plate, readstocks_plate, readdispense_plate, exitflag] = writeplates(plate(p), option);
        end
    end
end

if exitflag == 0
    return
end

end
                 