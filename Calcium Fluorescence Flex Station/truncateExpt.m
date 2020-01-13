function expt = truncateExpt(expt)

% Use this script to easily truncate ends of calcium traces if you don't
% want to keep a certain dispense or something like that

for i=1:length(expt.samewells)
    expt.samewells(i).data=expt.samewells(i).data(1:67,:);
    expt.samewells(i).rawdata=expt.samewells(i).rawdata(1:67,:);
    expt.samewells(i).time=expt.samewells(i).time(1:67,:);
    expt.samewells(i).totalrawdata=expt.samewells(i).totalrawdata(1:67,:);
    expt.samewells(i).totaltimes=expt.samewells(i).totaltimes(1:67,:);
    expt.samewells(i).datamean=expt.samewells(i).datamean(1:67,:);
    expt.samewells(i).datastd=expt.samewells(i).datastd(1:67,:);
    expt.samewells(i).totaltimemean=expt.samewells(i).totaltimemean(1:67,:);
    expt.samewells(i).totaltimestd=expt.samewells(i).totaltimestd(1:67,:);
    expt.samewells(i).timemean=expt.samewells(i).timemean(1:67,:);
    expt.samewells(i).timestd=expt.samewells(i).timestd(1:67,:);
end

end