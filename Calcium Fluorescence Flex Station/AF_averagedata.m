function expt = AF_averagedata(expt)

% Average the data acquired from a calcium fluorescence experiment

for i = 1:length(expt.samewells)
    expt.samewells(i).datamean = nanmean(expt.samewells(i).data,2);
    expt.samewells(i).datastd  = nanstd2(expt.samewells(i).data,0,2); % nanstd2 is a modified version of nanstd
    expt.samewells(i).timemean = nanmean(expt.samewells(i).time,2);
    expt.samewells(i).timestd  = nanstd2(expt.samewells(i).time,0,2);
    expt.samewells(i).totaltimemean = nanmean(expt.samewells(i).totaltimes,2);
    expt.samewells(i).totaltimestd  = nanstd2(expt.samewells(i).totaltimes,0,2);
end

end