function ActRoi_PlotMaskRaw(obj, ax, options)

    % Validate input arguments
    arguments
        obj
        ax (1, 1) matlab.graphics.axis.Axes = axes('Parent', gcf);
        options.fill (1, 1) logical = true;
        options.RoiId (1,:) double = 1:size(obj.ActRoi.mask.raw.centerXy,1)
    end

    obj.RegCall(mfilename);
    obj.Flow_CallMethod({'ActRoi_SetMaskRaw'});

    %% Plot the ROI

    % if ax is provided, plot on it
    if ~isempty(ax)
        axes(ax);
    end

    % extract the X and Y coordinates of the strip centers, as well as the strip width and height
    stripCenterX = obj.ActRoi.mask.raw.centerXy(options.RoiId, 1);
    stripCenterY = obj.ActRoi.mask.raw.centerXy(options.RoiId, 2);
    xWidth = obj.ActRoi.mask.raw.parameters.xWidth;
    yHeight = obj.ActRoi.mask.raw.parameters.yHeight;

    % load the ABM template image and set the Bregma coordinates
    abmTemplate = imread(obj.P.path.abmTemplate);
    abmTemplateBregmaXy = [256, 256];
    mm2pixel = 1/0.019; pixels2mm = 0.019;

    % plot the ABM template image
    imshow(abmTemplate);

    % get a set of face colors for the strips
    faceColorSetColor = jet(length(stripCenterX));
    faceColorSetGrey = repmat([0.5, 0.5, 0.5], length(stripCenterX), 1);
    faceAlpha = 0.7;
    faceColorSetColor(:, 4) = faceAlpha;
    faceColorSetGrey(:, 4) = faceAlpha;

    % plot the strips
    hold on;

    for j = 1:length(stripCenterX)
        xStripCenter = (stripCenterX(j) - 0) * mm2pixel + abmTemplateBregmaXy(1);
        yStripCenter = abmTemplateBregmaXy(2) - (stripCenterY(j) - 0) * mm2pixel;

        switch options.fill
            case 1
                rectangle('Position', [xStripCenter - xWidth / 2 * mm2pixel, yStripCenter - yHeight / 2 * mm2pixel, xWidth * mm2pixel, yHeight * mm2pixel], 'Curvature', 0.5, 'EdgeColor', 'none', 'FaceColor', faceColorSetColor(j, :));
                plot(xStripCenter, yStripCenter, 'k+');
            case 0
                rectangle('Position', [xStripCenter - xWidth / 2 * mm2pixel, yStripCenter - yHeight / 2 * mm2pixel, xWidth * mm2pixel, yHeight * mm2pixel], 'Curvature', 0.5, 'EdgeColor', 'r', 'FaceColor', faceColorSetGrey(j, :));
                plot(xStripCenter, yStripCenter, 'r+');
        end

    end

    hold off;
    % set the axis, minor grid, major grid on
    axis image; axis on; grid on;
    set(get(gca, 'Title'), 'String', ['ROI: Strips ', sprintf('(W=%g, H=%d)', xWidth, yHeight)]);
    % set axis tick labels to mm, abmTemplateBregmaXy should be 0, 0 mm
    xTicks = 1:1:512;
    xTickLabels = round((xTicks - abmTemplateBregmaXy(1)) * pixels2mm, 1);
    yTicks = 1:1:512;
    yTickLabels = round((abmTemplateBregmaXy(2) - yTicks) * pixels2mm, 1);
    set(gca, 'XTick', xTicks(1:39:end), 'XTickLabel', xTickLabels(1:39:end), 'YTick', yTicks(1:39:end), 'YTickLabel', yTickLabels(1:39:end));
    % set the axis label
    xlabel('ML (mm)'); ylabel('AP (mm)');

end
