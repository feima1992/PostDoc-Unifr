function propers = calIMcorrProperties(IMcorr)
    % validate inputs
    arguments
        IMcorr (:, :) double
    end

    % replace NaNs with zeros
    IMcorr(isnan(IMcorr)) = 0;

    % get grayscale image
    IMcorrGray = mat2gray(IMcorr);

    % determine connected components
    CC = bwconncomp(IMcorrGray);

    % determine properties of connected components
    propers = regionprops('table', CC, IMcorrGray, 'Area', 'WeightedCentroid', 'MeanIntensity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation');

    % keep only the largest connected component
    [~, idx] = max(propers.Area);
    propers = propers(idx, :);

    % IMcorrGrayLargest
    IMcorrGrayLargest = zeros(size(IMcorrGray));
    IMcorrGrayLargest(CC.PixelIdxList{idx}) = 1;

    % get edge of the largest connected component after filling holes
    IMcorrGrayLargest = imfill(IMcorrGrayLargest, 'holes');
    IMcorrGrayLargestEdge = bwperim(IMcorrGrayLargest);
    propers.Edge = {IMcorrGrayLargestEdge};

end
