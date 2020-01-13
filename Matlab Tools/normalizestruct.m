function item = normalizestruct(item, field, missingvalue)

% Normalize the specified structure to have all the same fields, adding
% missing fields as necessary with 'missingvalue'.

if ~ischar(field)
    error('Field name must be a string');
elseif ~isstruct(item)
    error('First argument must be a structure');
elseif ~isfield(item, field)
    error('The second argument must be a field of the first argument');
end

subfields = {};
for i = 1:length(item)
    if isempty(item(i).(field)) % If there is nothing in the well
        fields = {};
    else 
        fields = fieldnames(item(i).(field)); % If there is something in the well, find its name
    end
    subfields = unique({subfields{:} fields{:}});
end

for i = 1:length(item)
    for j = 1:length(subfields)
        if ~isfield(item(i).(field), subfields{j})
            item(i).(field).(subfields{j}) = missingvalue;
        end
    end
end

end
        