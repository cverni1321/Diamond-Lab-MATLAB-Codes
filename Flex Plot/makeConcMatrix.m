function concmatrix = makeConcMatrix(file)

regularplatelets = load(file);

[~,~,sortfields,sortmatrix] = sortstruct(regularplatelets.expt.samewells,regularplatelets.expt.sortfield);

nSpecies = length(sortfields);

ec_vector_labels = cell(1,nSpecies);
ec_vector = zeros(1,nSpecies);

for i = 1:length(ec_vector)
    temp = sortfields{i};
    ec_vector_labels{i} = temp{2};   
switch ec_vector_labels{i}
    case {'A'}
        ec_vector(i) = 1e-6;
    case {'C'}
        ec_vector(i) = 2e-9; 
    case {'T'}
        ec_vector(i) = 2e-8;
    case {'U'}
        ec_vector(i) = 1e-6;
    case {'Ilo'}
        ec_vector(i) = 0.5e-6;
    case {'I'}
        ec_vector(i) = 0.5e-6; 
    case {'AYP'}
        ec_vector(i) = 300e-6;
    case {'PAR4'}
        ec_vector(i) = 300e-6;
    case {'SFL'}
        ec_vector(i) = 10e-6;
    case {'PAR1'}
        ec_vector(i) = 10e-6;
    case {'G'}
        ec_vector(i) = 7e-6;
    otherwise
        error('Unidentified agonist')   
end
end

sortmatrix = bsxfun(@rdivide,sortmatrix,ec_vector);

% Make sure that the unique values are 0, 0.1, 1, 10 only (in reference to EC50)
sortmatrix = (round(sortmatrix*1000))/1000;

% First check 
unique_vals = unique(sortmatrix);
for i = 1:length(unique_vals)
lia = ismember(unique_vals(i),[0 0.1 1 10]);
    if lia == 0
        sortmatrix(sortmatrix == 0.04) = 0.1;
        sortmatrix(sortmatrix == 0.4) = 1;
        sortmatrix(sortmatrix == 4) = 10;     
        sortmatrix(sortmatrix == 0.25) = 0.1;
        sortmatrix(sortmatrix == 2.5) = 1;
        sortmatrix(sortmatrix == 25) = 10;       
    else
    end
end

% Second check
unique_vals = unique(sortmatrix);
for i = 1:length(unique_vals)
lia = ismember(unique_vals(i),[0 0.1 1 10]);
    if lia == 0       
        error('sortmatrix values is not 0, 0.1, 1 or 10')
    else
    end
end

% Find ternaries
blah = sum(sortmatrix==0,2);
whereare3 = (blah==3);

% Map the concentration to a scale from [-1 to 1] 
sortmatrix = sortmatrix(~whereare3,:);
P = sortmatrix/10;
P(P==0) = 0.001;
P = log10(P);
P = mapminmax(P');%3*37 matrix of concentrations , again this is just to be consistent with what jeremy had done
concmatrix = P';

end