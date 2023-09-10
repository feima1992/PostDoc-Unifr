function ActRoi_ApplyMaskReg(obj)

    % register method call
    obj.RegCall(mfilename);

    % call dependent methods
    obj.Flow_CallMethod({'ActMap_GetFileList'; 'ActRoi_SetMaskReg'});

    actMapRegNew = table();

    for i = progress(1:height(obj.ActRoi.reg), 'Title', '   Apply mask reg')
        % load deltaFoverF
        load(obj.ActRoi.reg.path{i}, 'deltaFoverF')

        for j = 1:length(obj.ActRoi.mask.reg)
            actMapRegTem = obj.ActRoi.reg(i, :);
            deltaFoverFcopy = deltaFoverF;
            maskNan = repmat(~obj.ActRoi.mask.reg(j).moduleMask, [1, 1, size(deltaFoverFcopy, 3)]);
            deltaFoverFcopy(maskNan) = nan;
            actMapRegTem.avgF{1} = squeeze(nanmean(deltaFoverFcopy, [1, 2]));
            [~, actMapRegTem.maxAvgFid{1}] = max(actMapRegTem.avgF{1});
            actMapRegTem.module{1} = obj.ActRoi.mask.reg(j).selectLabel;
            actMapRegNew = [actMapRegTem; actMapRegNew]; %#ok<AGROW>
        end

    end

    obj.ActRoi.reg = actMapRegNew;

end
