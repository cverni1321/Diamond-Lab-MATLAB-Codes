function [data,maxdata,mindata,times,rawdata] = AF_normalizedata(rawdata,maxdata,times,expt)

% Normalizes calcium fluorescence data and does other calculations on
% rawdata to gain important information from it

data = rawdata;
mindata = min(data, [], 5);
maxdata = max(maxdata, [], 5);
mindata(mindata == 0) = NaN;
maxdata(maxdata == 0) = NaN;

maxdata = max(maxdata, max(data, [], 5)); % Make sure that we actually have the maximum value

if ~isfield(expt, 'normtype')
    expt.normtype = 'well';
end

if strcmpi(expt.normtype, 'well')
    % If this case is true, don't do anything because we want to handle the
    % normalization on a well-by-well basis
elseif strcmpi(expt.normtype, 'plate') % Normalize to the maximum value across the plate
    maxvalue = max(maxdata(:)-mindata(:));
    maxdata = maxvalue+mindata;
end

firstpoints = data(:,:,:,:,1);
for i = 1:size(data,5)
    data(:,:,:,:,i) = data(:,:,:,:,i)./firstpoints;
end

data = squeeze(data);
times = squeeze(times);
rawdata = squeeze(rawdata);

end
