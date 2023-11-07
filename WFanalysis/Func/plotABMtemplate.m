function plotABMtemplate(ax, lineColor)
    % default black line color
    if nargin <2
        lineColor = 'k';
    end
    % activate the axis
    axes(ax);
    % plot the ABMtemplate
    atlas = imread(Param().path.abmTemplate);
    % get brain outline with pixels value 0
    brainOutline = atlas == 0;
    % the brain outline should be a single line use bwskel to get the skeleton
    brainOutline = bwskel(brainOutline);
    % convert to double
    brainOutline = double(brainOutline);
    hold on;
    contour(brainOutline, [0.5 0.5], 'Color', lineColor , 'LineWidth', 0.05);
    hold off;
end
