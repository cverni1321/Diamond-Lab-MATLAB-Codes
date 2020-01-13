function expt = AF_collectdata(expt, data, times, rawdata, mindata, maxdata, totalrawdata,totaltimes)

% Collect the data into the expt.samewells structure.  This does some
% simple calculations to find the max, min, etc of each well.

for i = 1:length(expt.samewells)
    for j = 1:size(expt.samewells(i).positions,1)
        tmprow = expt.samewells(i).positions(j,1);
        tmpcol = expt.samewells(i).positions(j,2);
        
        % Put the min and max into the samewell data
        expt.samewells(i).min(j) = mindata(tmprow, tmpcol);
        expt.samewells(i).max(j) = maxdata(tmprow, tmpcol);

        % Put the averaged fluorescent readings and the averaged times into
        % the expt.samewells

        % Squeeze is necessary so that Matlab will allow an nx1 vector to
        % be filled by a 1x1xn vector
        expt.samewells(i).data(:,j) = squeeze(data(tmprow,tmpcol,:));
        expt.samewells(i).rawdata(:,j) = squeeze(rawdata(tmprow,tmpcol,:));
        expt.samewells(i).time(:,j) = squeeze(times(tmprow,tmpcol,:));
        expt.samewells(i).totalrawdata(:,j) = squeeze(totalrawdata(tmprow,tmpcol,:));
        expt.samewells(i).totaltimes(:,j) = squeeze(totaltimes(tmprow,tmpcol,:));
    end
end

if ischar(expt.dispensetime)
    expt.dispensetime = str2double(expt.dispensetime);
end

% If you want to correct for the crazy jump when using Fluo4 on the Flex
% Station.

% expt.whereiscontrol may not always have position 1. Find the
% well with the well name 'Buffer'

TF = zeros(length(expt.samewells),1);

for i = 1:length(expt.samewells)
    TF(i,1) = strcmpi(expt.samewells(1,i).label,'Buffer');
end

expt.whereiscontrol = find(TF);

if strcmp(expt.dispensecorrection,'y') % One dispense during experiment
    buffer = expt.whereiscontrol;
    timenow = (mean(expt.samewells(buffer).time,2) > expt.dispensetime);
    avgfirst = nanmean(expt.samewells((buffer)).data(~timenow,:)); % Find the first average value of the control 
    numAfterDisp = sum(timenow);
    avglast = nanmean(expt.samewells((buffer)).data(end:-1:floor(end - numAfterDisp*0.5),:)); % Find the last average value of the control
            
    avgfirst = nanmean(avgfirst);
    avglast = nanmean(avglast);
            
    for i = 1:length(expt.samewells)
        for j = 1:size(expt.samewells(i).positions,1)
            timenow=(expt.samewells(i).time(:,j) > expt.dispensetime);
            expt.samewells(i).data(:,j) = expt.samewells(i).data(:,j)+(avgfirst-avglast)*timenow; % Add the difference between the first and last control values
        end
    end

% Mei had a bunch of other stuff commented out here but I assume it was
% just testing out other methods of doing the above tasks (look back at her
% code if need be)

elseif strcmp(expt.dispensecorrection,'yy') % Two dispenses during experiment
    for i = 1:length(expt.samewells)
        for j = 1:size(expt.samewells(i).positions,1)
            timenow = (expt.samewells(i).time(:,j) > expt.dispensetime);
            timenow2 = (expt.samewells(i).time(:,j) > expt.dispensetime2);           
            iAfterDisp1 = find(timenow == 1, 1 ); % Find the first time where timenow = 1
            iAfterDisp2 = find(timenow2 == 1, 1 ); % Find the first time where timenow2 = 1
            
            avgfirst = expt.samewells(i).data(iAfterDisp1-3:iAfterDisp1-1,j);
            avglast1 = expt.samewells(i).data(iAfterDisp1+1:iAfterDisp1+3,j);
            avglast11 = expt.samewells(i).data(iAfterDisp2-3:iAfterDisp2-1,j);
            avglast2 = expt.samewells(i).data(iAfterDisp2+1:iAfterDisp2+3,j);
      
            avgfirst = nanmean(avgfirst);
            avglast1 = nanmean(avglast1);
            avglast11 = nanmean(avglast11);
            avglast2 = nanmean(avglast2);
   
            expt.samewells(i).data(:,j) = expt.samewells(i).data(:,j)+(avgfirst-avglast1)*timenow + (avglast11-avglast2)*timenow2;
        end
    end
    
elseif strcmp(expt.dispensecorrection,'yyy') % Three dispenses during experiment
    for i = 1:length(expt.samewells)
        for j = 1:size(expt.samewells(i).positions,1)
        timenow1 = (expt.samewells(i).time(:,j) > expt.dispensetime);
        timenow2 = (expt.samewells(i).time(:,j) > expt.dispensetime2);           
        timenow3 = (expt.samewells(i).time(:,j) > expt.dispensetime3); 
                   
        iAfterDisp1 = find(timenow1 == 1, 1 ); % Find the first time where timenow = 1
        iAfterDisp2 = find(timenow2 == 1, 1 ); % Find the first time where timenow2 = 1
        iAfterDisp3 = find(timenow3 == 1, 1 ); % Find the first time where timenow2 = 1
        
        avgfirst1 = expt.samewells(i).data(iAfterDisp1-3:iAfterDisp1-1,j);
        avglast1 = expt.samewells(i).data(iAfterDisp1+1:iAfterDisp1+3,j);
        avgfirst2 = expt.samewells(i).data(iAfterDisp2-3:iAfterDisp2-1,j);
        avglast2 = expt.samewells(i).data(iAfterDisp2+1:iAfterDisp2+3,j);
        avgfirst3 = expt.samewells(i).data(iAfterDisp3-3:iAfterDisp3-1,j);
        avglast3 = expt.samewells(i).data(iAfterDisp3+1:iAfterDisp3+3,j);
                  
        avgfirst1 = nanmean(avgfirst1);
        avglast1 = nanmean(avglast1);
        avgfirst2 = nanmean(avgfirst2);
        avglast2 = nanmean(avglast2);
        avgfirst3 = nanmean(avgfirst3);
        avglast3 = nanmean(avglast3);
   
        expt.samewells(i).data(:,j) = expt.samewells(i).data(:,j)+(avgfirst1-avglast1)*timenow1 + (avgfirst2-avglast2)*timenow2 + (avgfirst3-avglast3)*timenow3;
        end
    end
end

end

