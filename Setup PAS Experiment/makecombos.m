function [map] = makecombos(species, states, k, kend, platesize)

% Make the different combinations for a PAS experiment. Can add onto this
% when doing ternary and higher-order combinatorial experiments.

if platesize == 384
    rows = 16;
    cols = 24;
elseif platesize == 96
    rows = 8;
    cols = 12;
else
    error('The plate must have either 96 or 384 wells.')
end

% Concatenate species and states into proper form, while also converting
% concentration units (from states) into more ideal format (e.g. uM, nM,
% etc)
speciesandstates = {};
index = 1;
for i = 1:length(species)
    for j = 1:size(states,1)
        if states(j,i) >= 1e-6
            speciesandstates{index} = strcat(species{i}, '|', num2str(10^6*states(j,i)), ' uM');
        elseif states(j,i) < 1e-6 && states(j,i) >= 1e-9
            speciesandstates{index} = strcat(species{i}, '|', num2str(10^9*states(j,i)), ' nM');
        elseif states(j,i) < 1e-9
            speciesandstates{index} = strcat(species{i}, '|', num2str(10^12*states(j,i)), ' pM');
        end
        index = index+1;
    end
end
speciesandstates = speciesandstates';

% Calculate the number of distinct combinations of conditions for the given
% combination size (k)
numberofcombinations = nchoosek(numel(states), k);

% Start making the string of combinations
combos = combntns(speciesandstates, k);

% MATLAB won't know that we don't want combinations of the same species, so
% we will manually delete them
if k == 2
    combos = combos([3:17,19:48,51:62,64:87,90:98,100:117,120:125,127:138,141:143,145:150],:);
end

if k > 2
    for i = 1:length(combos)
        for j = 1:k
            ags{i,j} = combos{i,j}(1);
        end
    end
    
    index = 1;
    for i = 1:length(ags)
        if strcmp(ags{i,1},ags{i,2})
            combos(index,:) = []; % If delete a row, index is still the same because everything moves up to replace it
            continue
        elseif strcmp(ags{i,2},ags{i,3})
            combos(index,:) = [];
            continue
        elseif strcmp(ags{i,1},ags{i,3})
            combos(index,:) = [];
            continue
        else
            index = index+1;
        end
    end
end

% Concatenate the combinations
mapcell = {};
count = 1;
if k == 2
    for i = 1:(numberofcombinations-18)
        mapcell{count} = strcat(combos{i,1}, ',', combos{i,2});
        count = count+1;
    end
end
if k == 3
    for i = 1:length(combos)
        mapcell{i} = strcat(combos{i,1},',',combos{i,2},',',combos{i,3});
    end
end
if k == 4
    for i = 1:length(combos)
        mapcell{i} = strcat(combos{i,1},',',combos{i,2},',',combos{i,3},',',combos{i,4});
    end
end
if k == 5
    for i = 1:length(combos)
        mapcell{i} = strcat(combos{i,1},',',combos{i,2},',',combos{i,3},',',combos{i,4},',',combos{i,5});
    end
end
if k == 6 % Probably won't have more than 6 combos
    for i = 1:length(combos)
        mapcell{i} = strcat(combos{i,1},',',combos{i,2},',',combos{i,3},',',combos{i,4},',',combos{i,5},',',combos{i,6});
    end
end
    
mapcell = mapcell';
map = mapcell;

% Tag on the single conditions at the end
if k == 2
    combos1 = combntns(speciesandstates, (k-1));
    timer = numel(map)+1;
    for i = 1:length(combos1)
        map{timer} = combos1{i};
        timer = timer+1;
    end
else
end

% Sort the map to reflect the order that Mei used in her work
if k ==2
    mapcounter = [1:3,16:18,31:33,4:6,19:21,34:36,7:9,22:24,37:39,10:12,25:27,...
        40:42,13:15,28:30,43:45,46:48,58:60,70:72,49:51,61:63,73:75,52:54,...
        64:66,76:78,55:57,67:69,79:81,82:84,91:93,100:102,85:87,94:96,103:105,...
        88:90,97:99,106:108,109:111,115:117,121:123,112:114,118:120,124:126,...
        127:153];
    mapcounter = mapcounter';
    map_correct = map(mapcounter);
    map = map_correct;
else
end

end
