function concmatrix = RearrangeConcmatrix_AbridgedPAS(concmatrix)

% This script simply rearranges the order of the rows of the two matrices
% to look nicer and comply with previous codes

% First rearrange CONCMATRIX (and remap the Iloprost concs) 
for i = 1:size(concmatrix,1)
    for j = size(concmatrix,2)
        if concmatrix(i,j) == 1
            concmatrix(i,j) = 1/3;
        else
        end
    end
end

% If more than single combo, remove and put aside for later
for i = 1:size(concmatrix,1)
    for j = 1:size(concmatrix,2)
        if concmatrix(i,j) > -1
            a(i,j) = 1;
        else
            a(i,j) = 0;
        end
    end
    b(i) = sum(a(i,:));
end

b=b';

count = 0;
for i = 1:length(b)
    if b(i) > 1
        count = count+1;
        concmatrix2(count,:) = concmatrix(i,:);
    else
    end
end

delRows = find(b > 1);
concmatrix(delRows,:) = [];

concmatrix = [concmatrix;concmatrix2];








