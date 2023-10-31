function vidOutput = videoDownSample(vidInput, spatialFactor, temporalFactor)
    %% function to downsample video both spatially and temporally
    % vidInput: input video, path to video
    % spatialFactor: factor to downsample spatially
    % temporalFactor: factor to downsample temporally
    % vidOutput: output video, path to video

    %% validate inputs
    P = inputParser;
    addRequired(P, 'vidInput', @(x) ischar(x));
    addRequired(P, 'spatialFactor', @(x) isnumeric(x) && x > 0);
    addRequired(P, 'temporalFactor', @(x) isnumeric(x) && x > 0);
    parse(P, vidInput, spatialFactor, temporalFactor);
    vidInput = P.Results.vidInput;
    spatialFactor = P.Results.spatialFactor;
    temporalFactor = P.Results.temporalFactor;

    %% read video and downsample
    if exist(vidInput, 'file')

        % get input video name and extension
        [vidInputDir, vidInputName, vidInputExt] = fileparts(vidInput);
        vidOutput = fullfile(vidInputDir, [vidInputName, '_downsampled', vidInputExt]);

        if strcmp(vidInputExt, '.tif') % stacked tif file
            imInfo = imfinfo(vidInput);
            keepFrameId = 1:temporalFactor:length(imInfo); % downsample temporal resolution

            for i = 1:length(keepFrameId)
                frame = imread(vidInput, keepFrameId(i));
                frame = imresize(frame, 1 / spatialFactor); % downsample spatial resolution

                if i == 1
                    imwrite(frame, vidOutput, 'tif', 'Compression', 'none');
                else
                    imwrite(frame, vidOutput, 'tif', 'Compression', 'none', 'WriteMode', 'append');
                end

            end

        else % video file
            vidInputObj = VideoReader(vidInput);
            vidOutputObj = VideoWriter(vidOutput, 'MPEG-4');
            vidOutputObj.FrameRate = vidInputObj.FrameRate / temporalFactor; % downsample temporal resolution
            open(vidOutputObj);

            while hasFrame(vidInputObj)
                frame = readFrame(vidInputObj);
                frame = imresize(frame, 1 / spatialFactor); % downsample spatial resolution
                writeVideo(vidOutputObj, frame);
            end

            close(vidOutputObj);
        end

    else
        error('Input video does not exist!');
    end

end
