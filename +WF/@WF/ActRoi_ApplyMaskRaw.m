function ActRoi_ApplyMaskRaw(obj)

    % register method call
    obj.RegCall(mfilename);

    % call dependent methods
    obj.Flow_CallMethod({'ActMap_GetFileList'; 'ActMap_GetBregmaXy'; 'ActRoi_SetMaskRaw'});

    % for each obj.ActRoi.raw file, apply strip obj.ActRoi.mask.raw to get average fluorescence in each strip rectangle
    for i = progress(1:height(obj.ActRoi.raw), 'Title', '   Apply mask raw')
        % load deltaFoverF
        load(obj.ActRoi.raw.path{i}, 'deltaFoverF')
        % initialize F to store masked deltaFoverF, size: [X,Y,frames,strips]
        F = nan([size(deltaFoverF), size(obj.ActRoi.mask.raw.rectangleXy, 1)]);
        % for each strip rectangle, apply obj.ActRoi.mask.raw to deltaFoverF
        for j = 1:size(obj.ActRoi.mask.raw.rectangleXy, 1)
            rectangleMask = obj.ActRoi.raw.X{i} >= obj.ActRoi.mask.raw.rectangleXy(j, 1) & obj.ActRoi.raw.X{i} <= obj.ActRoi.mask.raw.rectangleXy(j, 2) & obj.ActRoi.raw.Y{i} >= obj.ActRoi.mask.raw.rectangleXy(j, 3) & obj.ActRoi.raw.Y{i} <= obj.ActRoi.mask.raw.rectangleXy(j, 4);
            rectangleMask = repmat(rectangleMask, 1, 1, size(deltaFoverF, 3));
            deltaFoverFCopy = deltaFoverF;
            deltaFoverFCopy(~rectangleMask) = nan;
            F(:, :, :, j) = deltaFoverFCopy;
        end

        % average over all pixels in each strip rectangle, resulting in [frames,strips]
        obj.ActRoi.raw.avgF{i} = squeeze(nanmean(F, [1, 2]));

        % find the frame id with the maximum average fluorescence in each strip rectangle
        [~, obj.ActRoi.raw.maxAvgFid{i}] = max(obj.ActRoi.raw.avgF{i}, [], 1);
    end

end
