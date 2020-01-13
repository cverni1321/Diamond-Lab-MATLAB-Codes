function [varargout] = plotCategoricalScatterplot(varargin)

% Set the varargin as: varargin(1)=healthy, varargin(2)=trauma. They are
% both just vectors of the individual D-Dimer concentration points that are
% to be plotted (can also do this on GraphPad much easier)

numCategories = numel(varargin);
means = zeros(numCategories,1);
stdevs = zeros(numCategories,1);

for i = 1:numCategories % Plot each dataset separately because they will probably be different sizes
    [r,~] = size(varargin{i});
    xdata = zeros(r,1);
    xdata(:) = i;
    ydata = varargin{i};
    means(i) = mean(ydata);
    stdevs(i) = std(ydata);
    
    scatter(xdata(:),ydata(:),'r','filled','jitter','on','jitterAmount',0.05);
    xlim([0 numCategories+1])
    hold on
    plot([xdata(1,:)-0.15; xdata(1,:)+0.15], repmat(means(i),2,1), 'k-')
end

labels = {strcat('Healthy (n=',num2str(length(varargin{1})),')'),strcat('Trauma (n=',num2str(length(varargin{2})),')')};
labels = {[],[],labels{1},[],labels{2},[],[]};
varargout{1} = means;

set(gca,'xticklabel',labels(:))
ylabel('D-Dimer Concentration (nM)')

end