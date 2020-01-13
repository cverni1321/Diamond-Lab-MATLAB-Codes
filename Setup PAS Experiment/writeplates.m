function [labels_plate, stocks_plate, dispense_plate, exitflag] = writeplates(plate, option)

% Take all the plate information and export it into Excel spreadsheets that
% can be easily linked to liquid handler protocol

% First, create the labels file that can be used by 'analyzecalciumfluorescence' MATLAB code.
if option.platesize == 384
    rows = 16;
    cols = 24;
elseif option.platesize == 96
    rows = 8;
    cols = 12;
else
    error('The plate must have either 96 or 384 wells.')
end

labels_plate = {};
index = 1;
for j = 1:cols
    for i = 1:rows
        labels_plate{i,j} = plate.welllist{index};
        index = index+1;
    end
end
for k = 1:numel(labels_plate)
    if isnan(labels_plate{k})
        labels_plate{k} = 'Blank';
    end
end
filename1 = 'janus_setup_labels_plate.csv';
xlswrite(filename1, labels_plate);

% Next, create the plate that contains the finalwellmap with stock concentrations.
stocks_plate = {};
stocks_plate = plate.finalmap;
filename2 = 'janus_setup_stocks_plate.xlsx';
xlswrite(filename2, stocks_plate);

% Last, make a plate that can be used as direction for the liquid handler,
% with dispense volumes for each well (here I will just assume all single
% and pairwise combinations, but I will add other levels at a later time).
if option.k == 2
    numberofcombinations = nchoosek(numel(plate.states)-3, option.k);
%elseif option.k == 3 
 %   numberofcombinations = nchoosek(size(plate.states,2)-1, option.k)*2^option.k; % This is for ternary PAS experiments (only using 2 concentrations of each agonist -- total combos = 160)
else 
    numberofcombinations = nchoosek(numel(plate.states)-size(plate.states,1), option.k);
    %error('You are trying to prepare a higher order experiment. Change code to reflect this.')
end

dispense_plate = {}; % First start with the skeleton of the plate
dispense_plate{1,1} = 'Plate Name'; dispense_plate{1,2} = 'Well Number'; dispense_plate{1,22} = 'Buffer'; dispense_plate{1,23} = 'Well Label';
for i = 2:(numberofcombinations+2)
    dispense_plate{i,1} = option.platename;
    dispense_plate{i,2} = i-1;
    dispense_plate{i,23} = plate.welllist{(i-1),1};
    dispense_plate{i,24} = ' ';
end
for i = 1:length(plate.stocklabels)
    dispense_plate{1,(i+2)} = plate.stocklabels{1,i};
end

filename3 = 'janus_setup_dispense_plate.csv';
xlswrite(filename3, dispense_plate);

% Now fill in the dispense volumes appropriately
dispense_plate_body = {};
for i = 1:(numberofcombinations+1)
    if nnz(plate.wellmap(i,:)) == 1 % This is the buffer well
        bloodvol = 150; % Not sure why Mei used 150 uL for PRP but it doesn't really matter
        agonistdispvol = 0;
        dispense_plate_body{i,20} = option.wellvol;
    elseif nnz(plate.wellmap(i,:)) == 2 % This is a single agonist well
        bloodvol = 150; 
        agonistdispvol = 0.25*option.wellvol;
        dispense_plate_body{i,20} = 0.75*option.wellvol;
    elseif nnz(plate.wellmap(i,:)) == 3 % This is a binary combination (2 agonists)
        bloodvol = 150; 
        agonistdispvol = 0.25*option.wellvol;
        dispense_plate_body{i,20} = 0.50*option.wellvol;
    elseif nnz(plate.wellmap(i,:)) > 3 % This is for higher order experiments
        bloodvol = 150;
        agonistdispvol = 0.25*option.wellvol;
        dispense_plate_body{i,numel(plate.states)+2} = option.wellvol-(agonistdispvol*option.k);
    end
    locations = find(plate.wellmap(i,:)); % Find the wells that need to be filled
    for j = 1:length(locations)
        dispense_plate_body{i,locations(j)} = agonistdispvol;
    end
    for j = 1:(numberofcombinations+2) % Overwrite the blood wells (which aren't even really important)
        dispense_plate_body{j,1} = bloodvol;
    end
end

for i = 1:numel(dispense_plate_body)
    if isempty(dispense_plate_body{i})
        dispense_plate_body{i} = 0;
    end
end

if option.k == 2
    xlswrite(filename3, dispense_plate_body, 'C2:V155');
elseif option.k == 3
    xlswrite(filename3, dispense_plate_body, 'C2:V162');
end

exitflag = 1;


end