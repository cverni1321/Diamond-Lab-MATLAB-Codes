function datanew = RenormalizeData(data)

% Use this script when comparing trauma to healthy data and need to get
% data on same normalized scale. This is similar to what is done in
% GetBasicResults

meanbaseline = data(1,:); % baseline = buffer response

% Subtract the meanbaseline off of every curve
for i = 1:length(data)
    datanew(i,:) = data(i,:)-meanbaseline;
end

% Throw out the stuff which is below the mean baseline 
datanew(datanew<0) = 0;

% Find cell containing maximum value
maxvalue = max(max(datanew));

% Normalize all points by max value (and set all predispense data to 0)
datanew = datanew/maxvalue;
for i = 1:length(datanew)
    datanew(i,1:7) = 0;
end

% Check that all values are between 0,1
check = datanew(datanew<0 & datanew>1); 
if numel(check) > 0
    error('All values are not [0,1]')
end