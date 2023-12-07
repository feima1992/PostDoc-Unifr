classdef Frames
    %% Properties
    properties
        frameData
        frameSize
        framePeakId
        framePeak
        frameTime
        frameProps
    end

    %% Methods
    methods
        %% Constructor
        function obj = Frames(frameData, varargin)
            p = inputParser;
            addRequired(p, 'frameData', @isnumeric);
            addOptional(p, 'frameTime', [], @isnumeric);
            parse(p, frameData, varargin{:});
            frameData = p.Results.frameData;
            frameTime = p.Results.frameTime;
            % check frameData dimensions, if 2D, add a third dimension
            if ismatrix(frameData)
                obj.frameData = reshape(frameData, [size(frameData), 1]);
            else
                obj.frameData = frameData;
            end

            % check frameTime, if empty, set to 1:1:size(frameData, 3)
            if isempty(frameTime)
                obj.frameTime = 1:1:size(frameData, 3);
            else

                if length(frameTime) ~= size(frameData, 3)
                    error('frameTime must have the same length as the third dimension of frameData')
                else
                    obj.frameTime = frameTime;
                end

            end

        end

        %% Apply Gaussian filter to the frameData
        function obj = ApplyGaussFilter(obj, sigma, isDim3)

            arguments
                obj Frames
                sigma (1, 1) {mustBeNumeric}
                isDim3 (1, 1) {mustBeNumericOrLogical} = true
            end

            if isDim3 % 3D filtering for volumic images
                obj.frameData = imgaussfilt3(obj.frameData, sigma);
            else % 2D filtering for each frame of the volumic images

                for i = 1:obj.frameSize(3)
                    obj.frameData(:, :, i) = imgaussfilt(obj.frameData(:, :, i), sigma);
                end

            end

        end

        %% Apply mask to the frameData
        function obj = ApplyMask(obj, mask)

            arguments
                obj Frames
                mask (:, :, :) {mustBeNumericOrLogical}
            end

            obj.frameData = obj.frameData .* logical(mask);
        end

        %% Apply threshold to the frameData
        function obj = ApplyThreshold(obj, threshold, withNaN)

            arguments
                obj Frames
                threshold (1, 1) {mustBeNumeric}
                withNaN (1, 1) {mustBeNumericOrLogical} = true
            end

            % set all values below threshold to NaN
            if withNaN
                obj.frameData(obj.frameData < threshold) = NaN;
            else
                obj.frameData(obj.frameData < threshold) = 0;
            end

        end

        %% Apply time window to the frameData
        function obj = ApplyTimeWin(obj, timeWin)

            arguments
                obj Frames
                timeWin (1, 2) {mustBeNumeric}
            end

            % get frame indices within the time window
            frameId = find(obj.frameTime >= timeWin(1) & obj.frameTime <= timeWin(2));
            % get frameData within the time window
            obj.frameData = obj.frameData(:, :, frameId);
            % get frameTime within the time window
            obj.frameTime = obj.frameTime(frameId);
        end

        %% Get properties of the frameData
        function props = CalStatProps(obj, target, isDim3)
            % Get properties of frames
            % validate
            arguments
                obj Frames
                target {mustBeMember(target, {'mean', 'median', 'std', 'min', 'max', 'sum', 'prctile', 'zscore'})}
                isDim3 (1, 1) {mustBeNumericOrLogical} = false
            end

            % get properties

            if isDim3

                switch target
                    case 'mean'
                        props = mean(obj.frameData, 3, 'omitnan');
                    case 'median'
                        props = median(obj.frameData, 3, 'omitnan');
                    case 'std'
                        props = std(obj.frameData, 0, 3, 'omitnan');
                    case 'min'
                        props = min(obj.frameData, [], 3, 'omitnan');
                    case 'max'
                        props = max(obj.frameData, [], 3, 'omitnan');
                    case 'sum'
                        props = sum(obj.frameData, 3, 'omitnan');
                    case 'prctile'
                        props = prctile(obj.frameData, 0:1:100, 3);
                    case 'zscore'
                        props = zscore(obj.frameData, 0, 3);
                end

            else

                switch target
                    case 'mean'
                        props = mean(obj.frameData, [1, 2], 'omitnan');
                    case 'median'
                        props = median(obj.frameData, [1, 2], 'omitnan');
                    case 'std'
                        props = std(obj.frameData, 0, [1, 2], 'omitnan');
                    case 'min'
                        props = min(obj.frameData, [], [1, 2], 'omitnan');
                    case 'max'
                        props = max(obj.frameData, [], [1, 2], 'omitnan');
                    case 'sum'
                        props = sum(obj.frameData, [1, 2], 'omitnan');
                    case 'prctile'
                        props = prctile(obj.frameData, 0:1:100, [1, 2]);
                    case 'zscore'
                        props = zscore(obj.frameData, 0, [1, 2]);
                end

            end

        end

        function obj = CalRegionProps(obj, varargin)

            % validate input
            p = inputParser;
            addRequired(p, 'obj', @(x) isa(x, 'Frames'));
            addOptional(p, 'includeComp', false, @islogical);
            parse(p, obj, varargin{:});
            obj = p.Results.obj;
            includeComp = p.Results.includeComp;

            % get regionprops
            % replace NaNs with zeros
            obj.frameData(isnan(obj.frameData)) = 0;
            framePropsTable = table();
            % for each frame of the frameData calculate regionprops
            for i = 1:obj.frameSize(3)
                % get current frame
                cFrame = obj.frameData(:, :, i);
                % get grayscale image
                cFrameGray = mat2gray(cFrame);
                % determine connected components
                CC = bwconncomp(cFrameGray);
                % determine properties of connected components
                cFrameProps = regionprops('table', CC, cFrameGray, 'Area', 'WeightedCentroid', 'MeanIntensity', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'PixelValues');
                % sort by area descending and add component id
                cFrameProps = sortrows(cFrameProps, 'Area', 'descend');

                % incase empty cFrameProps, add row with all 0s
                if height(cFrameProps) == 0
                    cFrameProps = array2table(zeros(1, width(cFrameProps)), 'VariableNames', cFrameProps.Properties.VariableNames);
                    cFrameProps.WeightedCentroid = [0, 0];
                    cFrameProps.WeightedArea = 0;
                else
                    if isnumeric(cFrameProps.PixelValues)
                        cFrameProps.WeightedArea = sum(cFrameProps.PixelValues);
                    else
                        cFrameProps.WeightedArea = cellfun(@sum, cFrameProps.PixelValues);
                    end
                end
                % remove PixelValues from table
                cFrameProps.PixelValues = [];

                % add component id to the table
                cFrameProps.ComponentId = (1:height(cFrameProps))';
                % add current frame id to the table
                cFrameProps.FrameId = repmat(i, height(cFrameProps), 1);
                % add frame time to the table
                cFrameProps.FrameTime = repmat(obj.frameTime(i), height(cFrameProps), 1);
                % add frame peak to the table
                cFrameProps.FramePeak = repmat(obj.framePeakId == i, height(cFrameProps), 1);


                if includeComp
                    % calculate edge for each connected component

                    for j = 1:height(cFrameProps)
                        % get current connected component mask
                        cComponentMask = zeros(size(cFrameGray));

                        if ~isempty(CC.PixelIdxList)
                            cComponentMask(CC.PixelIdxList{j}) = 1;
                        end

                        % get edge of the current connected component
                        cComponentMaskFilled = imfill(cComponentMask, 'holes');
                        cComponentMaskEdge = bwperim(cComponentMaskFilled);
                        % add edge to the table
                        cFrameProps.Edge{j} = cComponentMaskEdge;
                        % add current connected component to the table
                        cFrameProps.Component{j} = cFrame .* cComponentMask;
                    end

                end

                % add current frame properties to the table
                framePropsTable = [framePropsTable; cFrameProps];
            end

            obj.frameProps = framePropsTable;
        end

        %% Getters

        % get the size of the frameData: size
        function frameSize = get.frameSize(obj)
            frameSize = size(obj.frameData);
        end

        % get the frame with the highest intensity value: framePeakId
        function framePeakId = get.framePeakId(obj)
            [~, framePeakId] = max(mean(obj.frameData, [1, 2], 'omitnan'));
        end

        % get the frame with the highest intensity value: framePeak
        function framePeak = get.framePeak(obj)
            framePeak = obj.frameData(:, :, obj.framePeakId);
        end

        %% Plotting
        % show frameData
        function ImShowFrame(obj, frameId, varargin)

            if nargin == 1
                frameId = 1:obj.frameSize(3);
            end

            % create figure
            figure('color', 'w');
            % determine number of rows and columns keeping the aspect ratio as 16:9 as far as possible
            nRows = ceil(sqrt(length(frameId) * 9/16));
            nCols = ceil(length(frameId) / nRows);
            % plot each frame
            for i = 1:length(frameId)
                subplot(nRows, nCols, i);
                imshowFrame(obj.frameData(:, :, frameId(i)), 'title', sprintf('%.1f s', obj.frameTime(frameId(i))));
            end

        end

        % play frameData
        function ImPlayFrame(obj, rate)
            % validate input
            arguments
                obj Frames
                rate (1, 1) {mustBeNumeric} = 5
            end

            % create figure
            figure('color', 'w');
            % play frames
            imshowFrame(obj.frameData(:, :, 1), 'title', sprintf('%.1f s', obj.frameTime(1)));
            % get current axes and image handle
            axesHandle = gca; % get current axes
            imageHandle = findobj(axesHandle, 'Type', 'Image'); % get image handle

            for i = 1:obj.frameSize(3)
                % update figure every 1/rate seconds
                pause(1 / rate);
                % update image
                imageHandle.CData = imshowFrame(obj.frameData(:, :, i), 'plot', false);
                % update title
                axesHandle.Title.String = sprintf('%.1f s', obj.frameTime(i));
            end

        end

    end

end
