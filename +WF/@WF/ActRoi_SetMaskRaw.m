function ActRoi_SetMaskRaw(obj, roiParam)
    % validate input
    arguments
        obj
        roiParam (1, 6) double {mustBeNumeric, mustBeFinite, mustBeReal} = [-3.5, 0.5, 3.5, 0.5, 0.5, 2]
    end

    obj.RegCall(mfilename);

    % set the roiMask
    obj.ActRoi.mask.raw = struct('parameters', [], 'centerXy', [], 'rectangleXy', []);

    % raw parameters, [xOrigin1, xStep, xOrigin2, xWidth, yOrigin, yHeight]
    xOrigin1 = roiParam(1);
    xStep = roiParam(2);
    xOrigin2 = roiParam(3);
    xWidth = roiParam(4);
    yOrigin = roiParam(5);
    yHeight = roiParam(6);

    % raw ROI center coordinates, [x, y]
    roiCenterX = xOrigin1:xStep:xOrigin2; roiCenterY = repmat(yOrigin, 1, length(roiCenterX));

    % raw ROI rectangle coordinates, [x1, x2, y1,y2]
    stripRoi = [roiCenterX - xWidth / 2; roiCenterX + xWidth / 2; roiCenterY - yHeight / 2; roiCenterY + yHeight / 2]';

    obj.ActRoi.mask.raw.parameters.xOrigin1 = xOrigin1;
    obj.ActRoi.mask.raw.parameters.xStep = xStep;
    obj.ActRoi.mask.raw.parameters.xOrigin2 = xOrigin2;
    obj.ActRoi.mask.raw.parameters.xWidth = xWidth;
    obj.ActRoi.mask.raw.parameters.yOrigin = yOrigin;
    obj.ActRoi.mask.raw.parameters.yHeight = yHeight;
    obj.ActRoi.mask.raw.centerXy = [roiCenterX', roiCenterY'];
    obj.ActRoi.mask.raw.rectangleXy = stripRoi;

end
