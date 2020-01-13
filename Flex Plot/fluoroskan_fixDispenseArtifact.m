function expt = fluoroskan_fixDispenseArtifact(expt)

% Eliminate the crazy jump in the data due to the second dispense

t_dispense = round(str2num(expt.seconddispensetime)/2.5)+1; % Find the correct row in the time array that corresponds to the dispense time
std_small = 5e-3;

% Fix Average only
for s = 1:numel(expt.samewells)
    [timepts] = numel(expt.samewells(s).timemean);
    total = 0;
    stdev = 0;
    count = 0;
    
    for i = (t_dispense-3):(t_dispense-1)
        total = total + expt.samewells(s).datamean(i);
        stdev = stdev + expt.samewells(s).datastd(i);
        count = count + 1;
        avg = total/count;
        avg_std = stdev/count;
    end
    
    for j = t_dispense:t_dispense+6 % Replace all the points affected by the jump with the average of the original baseline
        expt.samewells(s).datamean(j) = avg;
        expt.samewells(s).datastd(j) = avg_std;
    end
    
    index = t_dispense+6; % Shift curves up to reflect new baseline
    diff = expt.samewells(s).datamean(index+1)-expt.samewells(s).datamean(index);
    if abs(diff) > 0.01
        for k = t_dispense+7:timepts
            expt.samewells(s).datamean(k) = expt.samewells(s).datamean(k)-diff; % Subtract the difference to bring the second data set back down to match the first
        end
    else
    end
end

% Fix everything
for s = 1:numel(expt.samewells)
    [r,c] = size(expt.samewells(s).data);   
    for col = 1:c
        total = 0;
        count = 0;
        for i = (t_dispense-3):(t_dispense-1)
            total = total + expt.samewells(s).data(i,col);
            count = count + 1;
            avg = total/count;
        end

        for j = t_dispense:t_dispense+6 % Replace all the points affected by the jump with the average of the original baseline
            expt.samewells(s).data(j,col) = avg;
        end
    end
end


end



