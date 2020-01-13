function sameplaces = findsame(labels)

% Finds positions that have the same value in a cell array and returns a 2D
% array within a structure, here called 'sameplaces'. Eventually this will
% become the main structure expt.samewells which will be used for most of
% the remainder of the calculations and plotting.
%
% labels     - the values that may be the same
% sameplaces - structure with the format:
%                   sameplaces(i).label     - the label found
%                   sameplaces(i).positions - all positions with that label
%                                             [row col]
%                   sameplaces(i).map       - all positions with that label
%                                             (in array form)


cleared = cellfun(@isempty, labels);
i = 0;

while sum(cleared(:)) < numel(labels)
    i = i+1; % Get a new string
    uncleared = find(cleared == 0, 1);
    sameplaces(i).label = labels(uncleared);
    sameplaces(i).label = sameplaces(i).label{1}; % Turn it into a string
    thesame = strcmp(labels, sameplaces(i).label); 
    cleared = cleared | thesame; % Clear the label from the list we are looking at
    [row, col] = find(thesame);
    sameplaces(i).positions = [row, col];
    sameplaces(i).map = thesame;
end

end 