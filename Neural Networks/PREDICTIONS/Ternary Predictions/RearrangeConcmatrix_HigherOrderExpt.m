function [concmatrix_higherorder,predictedData,actualData] = RearrangeConcmatrix_HigherOrderExpt(concmatrix_higherorder,predictedData,actualData)

% This script simply rearranges the order of the rows of the two matrices
% to look nicer and comply with previous codes


% If more than single combo, remove and put aside for later
for i = 1:size(concmatrix_higherorder,1)
    for j = 1:size(concmatrix_higherorder,2)
        if concmatrix_higherorder(i,j) > -1
            a(i,j) = 1;
        else
            a(i,j) = 0;
        end
    end
    b(i) = sum(a(i,:));
end

b=b';

[Y,I] = sort(b);

concmatrix_new = concmatrix_higherorder(I,:);
concmatrix_higherorder = concmatrix_new;

predictedData_new = predictedData(I,:);
predictedData = predictedData_new;

actualData_new = actualData(I,:);
actualData = actualData_new;









