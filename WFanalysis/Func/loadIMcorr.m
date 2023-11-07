function fileTable = loadIMcorr(fileTable, varargin)

    fileTable.IMcorr = cellfun(@loadIMcorrHelper, fileTable.path, 'UniformOutput', false);

end

function result = loadIMcorrHelper(filePath, varargin)
    % parse inputs
    p = inputParser;
    p.addRequired('filePath', @ischar);
    p.addParameter('frameIdx', 28, @isnumeric);
    parse(p, filePath, varargin{:});
    filePath = p.Results.filePath;
    frameIdx = p.Results.frameIdx;

    % load data
    try
        load(filePath, 'IMcorrREG', 'imMaskREG');
        im = IMcorrREG(:, :, frameIdx);
        im = imgaussfilt(im, 2);
        im(~imMaskREG) = NaN;
    catch
        load(filePath, 'IMcorr', 'imMask');
        im = IMcorr(:, :, frameIdx);
        im = imgaussfilt(im, 2);
        im(~imMask) = NaN;
    end

    % normalize im
    threshold = mean(im, "all", "omitnan") + 1.96 * std(im, 0, "all", "omitnan");
    im(im < threshold) = nan;
    highLimIm = max(im(:));
    result = (im - threshold) / (highLimIm - threshold);
end
