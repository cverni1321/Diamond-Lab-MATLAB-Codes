function [P,T,p,t,s,s_normalized] = GetSynergyScoresNNPrediction(expt,yc,flag,varargin)

% Use this script to calculate synergy scores predicted by neural networks
% trained on PAS experiment data. Need to load original expt structure for
% setup purposes

% Mei wrote all this:
% % % maxsyn of original women-men dataset is 103.0003
% % % [P, T, p, t, s] = GetCorrectSynergyScoresReally(expt,'plot','maxsyn',103.0003);
% % % [P, T, p, t, s]  = GetCorrectSynergyScoresReally(expt,'noplot','scaletojustthisdonor',1);
% % % 5-29-2013 problem found: did Scaletojustthisdonor takes maxsyn as 1, i.e.
% % % no normalization at all
% % % Scale to just this donor only means raw synergy scores
% % % flag: 'plot' or 'noplot'

num_wells = length(expt.samewells);

% Specify the agonists used
cmps = {'A','U','C','SFL','AYP','Ilo'}; % Use this for abridged PAS
%cmps = {'A','C','T','U','I','G'}; % Use this for full PAS


P = zeros(length(cmps),num_wells);

for i = 1:num_wells
    for j = 1:length(cmps)
         P(j,i) = getfield(expt.samewells(1,i).conc, cmps{j});
    end
end

% Find longest time interval spanned by all runs
min_time = min(expt.samewells(1).time(end,:));
for i = 2:num_wells
   if min_time > min(expt.samewells(i).time(end,:));
      min_time = min(expt.samewells(i).time(end,:));
   end
end

% Adjust time units, if necessary
timescale = 1;
t = 1:1:ceil(min_time*timescale);

T = zeros(length(t),num_wells);
for i = 1:length(t)
    T(i,:) = yc{i+131}; %% This is the big part of this code that differs from the other one
end

% Normalize T (subtract baseline too)
T = T - T(:,1)*ones(1,num_wells);
f_max = max(max(T));
f_min = T(1,1);
T = (T-f_min)/(f_max-f_min);

% Map input concentrations to (-1,+1)
P = P./(max(P,[],2)*ones(1,num_wells));
P((P==0))=0.001;
P = log10(P);
if find(isnan(P))
   warning('Found NaNs in P. Converting to zeros.');
   P(isnan(P))=0;
end
P = mapminmax(P);

% Create sequential p
p = cell(1,size(T,1));
for i = 1:19
   p{i} = -1*ones(size(P));
end
for i=20:length(p)
   p{i} = P;
end

% Create sequential t
t = cell(1,size(T,1));
for i=1:length(p)
   t{i} = T(i,:);
end

%% Get synergy scores starts here!!

X = P;
Y = T;

% options.scaletojustthisdonor = 0;%if you want to scale to just this donor
% options.maxsyn = 1;%Maxsyn is used only to plot  if you want to scale everything to all the donors
% options = setopt(options, varargin{:});

if size(X,2) ~= size(Y,2)
    error('X and Y are not compatible');
end

% Check for uniqueness
N = size(X,2); % Number of conditions (Full PAS=154; Abridged PAS=31)
len_x = size(X,1); % Number of agonists tested (Usually 6)
len_y = size(Y,1); % Number of time points

z = [];
s = [];
t = [];

% Maximum order
max_order = 0;

% Subtract minimum from Y
%Y = Y - min(min(Y))*ones(size(Y));

for i = 1:N % Poll every well
    x = X(:,i); % Get the concentration vector for this well
    [I,J,V] = find(x~=-1); % Because concentrations are scaled between -1 and +1, a 0 value of concentration corresponds to -1
    num_inputs = length(I); % Number of nonzero inputs that went into this well
    % Must have 2 or more nonzero inputs to calculate a synergy
    max_order = max(max_order,num_inputs);

    if num_inputs >= 2 
        % Initialize storage for inidivual x and y columns
        xi = [];
        yi = [];
        % Find individual components
        for j = I'
            % Construct individual vector
            xj = ones(len_x,1)*-1; % Nothing to start off with
            xj(j) = x(j); % What concentration was it -1 (0), -0.33 (0.1x EC50), 0.33 (1x EC50) and 1 (10xEC50)
            % The rest of the species are still all 0, so this is a vector
            % with a single non 0 concentration (look for it)
            for k = 1:N
                if X(:,k) == xj % Columns that contain just this species
                    xi = cat(2,xi,xj); % The concentrations of the things that went into this well, cat of 2 6*1 vectors
                    yi = cat(2,yi,Y(:,k)); % First column is curve for A and second column is curve for B
                    break;
                end
            end
        end
        
        % Calculate synergy ratio
        z = cat(2,z,x); % What concs makes up this well
        num = trapz(Y(:,i)); % num is AUC of AB, Y(:,i) is curve for AB because we are still in the num_inputs>=2 regime
        
        %den = trapz(yi);
        %den = sum(den);
        
        if any(yi<0)
            'Haram jada'
        end
        yi(yi<0)= 0; % Force negative values to be equal to 0 for synergy calculations

        den = trapz(yi); % 1X2 column, first column is AUC of A, second column is AUC of B
        if any(den<0)
            'ban Chod'
        end
        den = sum(den(den>0)); % Summed additive response: AUC of A+B

        % If areas are too small, set synergy to 0 ????
        t = cat(2,t,Y(:,i)-sum(yi,2));% ?????????
        %if den < 0,
        %   s = cat(1,s,1);
        %else
        s = cat(1,s,num-den); % SYNERGY
        %          if num-den > 10
        %             ans = [];% ????? not really used
        %          end
        %end
    end
end

synergylimits = max(abs(s)); % Find the maximum magnitude synergy for normalizing purposes
s_normalized = s/synergylimits;

% Plot synergy heat map if max_order == 2
% 05-28-13 this plot is for normalizing to this experiment itself only. 
if max_order == 2 && ~strcmp(flag,'noplot')
figure
load('C:\Users\Chris\Desktop\MATLAB Codes\Random Analysis Tools\cmap_br.mat');
for i = 1:len_x % 6 agonists
    for j = (i+1):len_x % All other 5 agonists
        % Pairwise synergy
        zij = z([i,j],:); % 1st and 2nd agonist, 1st and 3rd, and so on
        sij = s';
        tij = t';
        [I,J,V] = find(zij==-1); % Where none of these two agonists exist or either one exists
        zij(:,J) = []; % Throw out these columns and synergy scores
        sij(:,J) = []; 
        for ii = 1:size(zij,2) % Scale synergy value to color scale
                c = ceil((32+sij(ii)*(32/synergylimits))+eps); % 32 is the color white
                %c = ceil((sij(ii)+86.5)*((64-eps)/(2*86.5))+eps);
                rectangle('Position',...
                    [i+0.50*zij(1,ii),j+0.50*zij(2,ii),0.30,0.30],...
                    'FaceColor',cmap_br(c,:),...
                    'EdgeColor',[0.9 0.9 0.9]);
                %text('Position',...
                    %[i+0.35*zij(1,ii),j+0.35*zij(2,ii)],...
                    %'String',num2str(sij(ii),'%0.1f'),...
                    %'FontSize',6); % Include this for the actual synergy scores to be displayed                            
        end
    end
end

end

axis off
h = gcf;
%filename = 'Synergy - no normalization';
%saveas(h,filename,'fig')
%saveas(h,filename,'pdf')

% Sort by synergy
%[s,i] = sort(s,'descend');
%z = z(:,i);

% % if  options.scaletojustthisdonor == 1
% % %     s = s/synergylimits;
% %     s = s/1; % scale later (6/21/2013) do this
% % elseif options.scaletojustthisdonor == 0
% %     if options.maxsyn == 1
% %         error('You want to scale synergy to all donors, but maxsyn is still 1');
% %     end
% %     s = s/options.maxsyn;% return the scaled synergies to maxsyn
% % else
% % end


%if  flag == 0
%    s = s/1; % scale later (6/21/2013) do this
%elseif flag == 1
%    s = s/synergylimits;
%elseif flag == 2
%    if maxsyn == 1
%        error('You want to scale synergy to all donors, but maxsyn is still 1');
%    end
%    s = s/maxsyn;% return the scaled synergies to maxsyn
%else

end







