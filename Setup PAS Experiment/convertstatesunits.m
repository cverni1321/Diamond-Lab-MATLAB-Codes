function [tmp, num, units] = convertstatesunits(states)

% Convert the states values into units that are in a more ideal format (e.g
% uM, nM, etc). This was basically done in makecombos.m but the output was
% not saved.

convertedstates = {};
num = {};
units = {};
for i = 1:size(states,1)
    for j = 1 % The blood type/concentration
        convertedstates{i,j} = num2str(states(i,j));
        % convertedstates{i,j} = strcat(num2str(states(i,j)), '%');
        num{i,j} = convertedstates{i,j};
        units{i,j} = '%';
    end
end

for i = 1:size(states,1)
    for j = 2:length(states)
        if states(i,j) >= 1e-6
            convertedstates{i,j} = num2str(states(i,j)*10^6); % Converting to uM
            % convertedstates{i,j} = strcat(num2str(states(i,j)*10^6), ' uM');
            num{i,j} = convertedstates{i,j};
            units{i,j} = ' uM';
        elseif states(i,j) < 1e-6 && states(i,j) >= 1e-9
            convertedstates{i,j} = num2str(states(i,j)*10^9); % Converting to nM
            % convertedstates{i,j} = strcat(num2str(states(i,j)*10^9), ' uM');
            num{i,j} = convertedstates{i,j};
            units{i,j} = ' nM';
        elseif states(i,j) < 1e-9
            convertedstates{i,j} = num2str(states(i,j)*10^12); % Converting to pM
            % convertedstates{i,j} = strcat(num2str(states(i,j)*10^12), ' uM');
            num{i,j} = convertedstates{i,j};
            units{i,j} = ' pM';
        else
            error('One or more of the states values is less than the pM range.')
        end
    end
end

tmp = convertedstates;

end