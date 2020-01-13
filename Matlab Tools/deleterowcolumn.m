function array = deleterowcolumn(array, num, dim)

% Delete a row or column of data from a 2D array
%
% array - the array of data
% num   - the row or column number to delete
% dim   - dimension:  1 to delete a row, 2 to delete a column
%
% e.g.  starting from
%   a = [ 1 2 3;
%         4 5 6;
%         7 8 9 ]
%
%   delrow(a,2,1)
%
%   ans = [ 1 2 3;
%           7 8 9 ]
%
%   delrow(a,2,2)
%
%   ans = [ 1 3;
%           4 6;
%           7 9 ]

if dim == 1
    array = array';
end

if length(size(array)) > 2
    error('delrow only works on 2D arrays');
end

if num == size(array,2)
    array = array(:,1:num-1);
elseif num == 1
    array = array(:,2:size(array,2));
elseif num > 0 && num < size(array,2)
    array = [array(:,1:num-1) array(:,num+1:size(array,2))];
else
    error('Number out of bounds for array');
end

if dim == 1
    array = array';
end

end