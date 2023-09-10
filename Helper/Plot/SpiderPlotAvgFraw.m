function SpiderPlotAvgFraw(avgFraw, options)
% validate input
arguments
    avgFraw double
    options.AxesLimits (1, 2) double = [min(avgFraw(:)), max(avgFraw(:))]
    options.AxesLabels (1, :) cell = {'1', '2', '3', '4', '5', '6', '7', '8'}
    options.title (1, :) char = ''
    options.plotType (1, :) char {mustBeMember(options.plotType, {'multiple', 'meanSem'})} = 'multiple'
    options.legend(1,:) cell = {}
end

% reshape avgFraw to be a row vector if it is a column vector
if size(avgFraw, 2) == 1
    avgFraw = avgFraw';
end

% find the min and max of the activity
minLim = repmat(options.AxesLimits(1), 1, 8);
maxLim = repmat(options.AxesLimits(2), 1, 8);

% for each Roi plot the raw activity
switch options.plotType
    case 'multiple'
        spider_plot(avgFraw, ....
            'AxesLimits', [minLim; maxLim], ....
            'AxesWebType', 'circular', ....
            'Direction', 'counterclockwise', ....
            'AxesLabels', options.AxesLabels, ....
            'AxesLabelsEdge', 'none', ....
            'AxesDisplay', 'one',....
            'Color',distinguishable_colors(length(options.legend)))
        legend(options.legend, 'Location', 'westoutside')
        % add title
        title(options.title);
    case 'meanSem'
        % calculate the mean and sem of the activity
        avgFrawMean = mean(avgFraw, 1);
        avgFrawSem = std(avgFraw, 0, 1) / sqrt(size(avgFraw, 1));
        axes_shaded_limits = {[avgFrawMean - avgFrawSem; avgFrawMean + avgFrawSem]};
        
        % plot the mean and sem
        spider_plot(avgFrawMean, ....
            'AxesShaded', 'on',...
            'AxesWebType', 'circular', ....
            'AxesLimits', [minLim; maxLim], ....
            'Direction', 'counterclockwise', ....
            'AxesLabels', options.AxesLabels, ....
            'AxesLabelsEdge', 'none', ....
            'AxesDisplay', 'one', ....
            'AxesShadedLimits', axes_shaded_limits,....
            'AxesShadedColor', 'r',...
            'AxesShadedTransparency', 0.5)
        legend(options.legend, 'Location', 'southoutside')
        % add title
        title(options.title);
end


end
