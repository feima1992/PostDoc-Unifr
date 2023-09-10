function ActRoi_PlotMask(obj)

    obj.RegCall(mfilename);
    obj.Flow_CallMethod({'ActRoi_SetMaskRaw';'ActRoi_SetMaskReg'});

    figH1 = figure('Color', 'w', 'Position', [658, 72, 975, 872]);
    obj.ActRoi_PlotMaskRaw();
    exportgraphics(figH1, fullfile(fileparts(obj.P.dir.actRoi.raw), 'rawRoi.png'), 'Resolution', 300);
    close(figH1);

    figH2 = figure('Color', 'w', 'Position', [658, 72, 975, 872]);
    obj.ActRoi_PlotMaskReg();
    exportgraphics(figH2, fullfile(fileparts(obj.P.dir.actRoi.reg), 'regRoi.png'), 'Resolution', 300);
    close(figH2);

end
