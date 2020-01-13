function expt = fixDispenseArtifact1(expt)

% Eliminate the crazy jump in the data due to the first dispense at 20
% seconds and create a baseline signal.

if expt.dispensetime == 20
    t_dispense_1 = 7;     % Choose 7 because that's when t = 20 after normalization
else
    error('Check dispense time in pop-up window for analyzecalciumfluorescence script');
end
std_small = 5e-3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% First Dispense %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fix Average only
for s = 1:length(expt.samewells)
    [timepts] = length(expt.samewells(s).timemean);
    total = 0;
    count = 0;
    
    for i = 1:t_dispense_1-1
        total = total + expt.samewells(s).datamean(i);
        count = count + 1;
        avg = total/count;
    end
    
    for j = 1:t_dispense_1+1 % Replace all the points affected by the jump with the average of the original baseline
        expt.samewells(s).datamean(j) = avg;
        expt.samewells(s).datastd(j) = std_small;
    end
    
    %index = 8; % Shift curves up to reflect new baseline
    slope = (expt.samewells(s).datamean(t_dispense_1+2) - expt.samewells(s).datamean(t_dispense_1+1))/(expt.samewells(s).timemean(t_dispense_1+2) - expt.samewells(s).timemean(t_dispense_1+1));
    if slope < 0
        diff = abs(expt.samewells(s).datamean(t_dispense_1+2) - expt.samewells(s).datamean(t_dispense_1+1));
    else
        diff = 0;
    end
        
    for k = t_dispense_1+2:timepts
        expt.samewells(s).datamean(k) = expt.samewells(s).datamean(k)+diff;
    end
end

% Fix everything
for s = 1:numel(expt.samewells)
    [r,c] = size(expt.samewells(1,s).data);   
    for col = 1:c
        % chose 7 because thats when t = 20
        total = 0;
        count = 0;
        for i = 1:t_dispense_1-1
            total = total + expt.samewells(1,s).data(i,col);
            count = count + 1;
            avg = total/count;
        end

        for k = 1:t_dispense_1+3 % Replace all the points affected by the jump with the average of the original baseline
            expt.samewells(1,s).data(k,col) = avg;
        end
    end
end


end