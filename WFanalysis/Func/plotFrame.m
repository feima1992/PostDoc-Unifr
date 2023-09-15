function plotFrame(frameData, varargin)
    % parse inputs
    p = inputParser;
    p.addRequired('frameData', @isnumeric);
    p.addOptional('ax', gca, @ishandle);
    p.addParameter('cmap', polarmap);
    p.addParameter('clim', []);
    p.addParameter('title', '');
    p.addParameter('colorbar', true, @islogical);
    p.addParameter('colorbarLabel', '\DeltaF/F');
    parse(p, frameData, varargin{:});
    frameData = p.Results.frameData;
    ax = p.Results.ax;
    cmap = p.Results.cmap;
    clim = p.Results.clim;

    if isempty(clim)
        clim = [min(frameData(:)), max(frameData(:))];
        clim = max(abs(clim)) * [-1, 1];
    end

    titleStr = p.Results.title;
    colorbarFlag = p.Results.colorbar;
    colorbarLabel = p.Results.colorbarLabel;

    % plot the frame
    imagesc(ax, frameData, clim);
    colormap(ax, cmap);
    axis(ax, 'image');
    axis(ax, 'off');

    if ~isempty(titleStr)
        title(ax, titleStr);
    end

    if colorbarFlag
        cBar = colorbar(ax, 'Location', 'eastoutside');
        cBar.Label.String = colorbarLabel;
    end

    % plot the ABMtemplate
    atlas = imread(Param().path.abmTemplate);
    % get brain outline with pixels value 0
    brainOutline = atlas == 0;
    % the brain outline should be a single line use bwskel to get the skeleton
    brainOutline = bwskel(brainOutline);
    % convert to double
    brainOutline = double(brainOutline);
    hold on;
    contour(brainOutline, [0.5 0.5], 'Color', 'k', 'LineWidth', 0.05);
    hold off;

end
