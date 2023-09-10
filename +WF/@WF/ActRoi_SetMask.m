function ActRoi_SetMask(obj, options)

    %% Validate input
    arguments
        obj
        options.rawStrip = [-3.5, 0.5, 3.5, 0.5, 0.5, 2] %[xOrigin1, xStep, xOrigin2, xWidth, yOrigin, yHeight]
        options.regModule = {26, 62, 23, 52, 30, 55, 25, 64, 29, 54, 27, 44, 15, 67, 13, 69, 14, 66, 9, 75, 5, 80, 22, 58};
    end

    obj.RegCall(mfilename);

    %% Get the rawStrip ROI for RAW ACT map
    obj.ActRoi_SetMaskRaw(options.rawStrip);

    %% Get the rawStrip ROI for Reg ACT map
    obj.ActRoi_SetMaskReg(options.regModule);

end
