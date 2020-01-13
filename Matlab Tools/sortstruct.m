function [item, varargout] = sortstruct(item, varargin)

% Sort a structure based on the value of its fields (the fields must be
% numeric or character arrays and they must be the same type). The
% structure is first sorted on 'field1' and then on subsequent fields if
% requested.
%
% item       - A structure vector to be sorted
% fieldN     - The name of the field to be sorted. This may also be a char
%              vector with pipe ('|'), comma (','), or space (' ') separated field
%              names. The field names may also include subfields (i.e.
%              'a.b|c.d' is acceptable).
% idx        - The index of the final matrix relative to the first.
% sortfields - The field names as broken down for sorting.
% sortmatrix - The sorted matrix of values used for sorting.

if ~isvector(item)
    error('The input "item" must be a vector')
end

sortfields = {};
for i = 1:length(varargin)
    thesesortfields = regexp(varargin{i}, '([\w.]+)', 'tokens');
    for j = 1:length(thesesortfields) % Pull subfield names out for use
        fieldcell = regexp(thesesortfields{j}{1}, '(\w+)', 'tokens');
        for k = 1:length(fieldcell) % Remove the unnecessary inner-most cell to just use the string
            fieldcell(k) = fieldcell{k};
        end
        sortfields{end+1} = fieldcell;
    end
end

% Build up the matrix to sort
matrixtosort = [];
nSpecies = length(sortfields);
for i = 1:length(sortfields)
    currentcol = size(matrixtosort, 2) + 1;
    if isnumeric(getfield(item(1), sortfields{i}{:}))
        for j = 1:length(item)
            matrixtosort(j, currentcol) = getfield(item(j), sortfields{i}{:});
        end
    elseif ischar(getfield(item(1), sortfields{i}{:}))
        tmpchar = {};
        for j = 1:length(item)
            tmpchar{j} = getfield(item(j), sortfields{i}{:});
        end
        tmpchar = strvcat(tmpchar);
        matrixtosort(:, currentcol:currentcol+size(tmpchar,2)-1) = tmpchar;
    else
        error('Fields to be sorted must either be numeric or character-based (%s is %s).', ...
            varargin{1}, class(getfield(item(1), sortfields{i}{:})));
    end
end

[matrixtosort, idx] = sortrows(matrixtosort);
item = item(idx); % Switches the rows
if (nargout > 1)
    varargout{1} = idx;
end
if (nargout > 2)
    varargout{2} = sortfields;
end
if (nargout > 3)
    varargout{3} = matrixtosort;
end

end