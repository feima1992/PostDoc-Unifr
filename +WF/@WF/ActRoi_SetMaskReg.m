function ActRoi_SetMaskReg(obj, roiParam)

    arguments
        obj
        %roiParam = {26, 62, 23, 52, 30, 55, 25, 64, 29, 54, 27, 44, 15, 67, 13, 69, 14, 66, 9, 75, 5, 80, 22, 58}
        roiParam = {[25, 26, 30]}
    end

    obj.RegCall(mfilename);

    if ~iscell(roiParam)
        roiParam = {roiParam};
    end

    for i = 1:length(roiParam)

        if ~(isvector(roiParam{i}) && isnumeric(roiParam{i}))
            error('roiParam must be a numeric vector or a cell array of numeric vectors');
        end

    end

    % Load and set the mask

    % read the ABM template image
    abmTemplate = imread(obj.P.path.abmTemplate);

    % get outline of cortex modules from the ABM template image
    moduleOutline = double(bwskel(abmTemplate == 0));

    % label the modules in the ABM template image
    moduleLabel = bwlabel(~moduleOutline, 4);

    obj.ActRoi.mask.reg = struct('moduleMask', [], 'selectLabel', []);

    for i = 1:length(roiParam)
        thisRoiParam = roiParam{i};
        % generate module mask for modules specified
        obj.ActRoi.mask.reg(i).moduleLabel = moduleLabel;
        obj.ActRoi.mask.reg(i).moduleMask = ismember(moduleLabel, thisRoiParam);
        obj.ActRoi.mask.reg(i).selectLabel = thisRoiParam;
    end

end
