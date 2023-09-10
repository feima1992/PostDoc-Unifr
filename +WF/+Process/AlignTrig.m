function filesWfBpod = AlignTrig(filesWf, filesBpod, P)
    fprintf('▶  Aligning widefield with bpod\n')

    % filesWf sessionID is 'yymmdd' while filesBpod sessionID is 'yyyymmdd'
    filesWf.sessionIDforPairing = filesWf.sessionID + 20000000;
    % inner join filesWf and filesBpod based on mouseID, sessionID and trialID
    filesWfBpod = innerjoin(filesBpod, filesWf, 'LeftKeys', {'mouseID', 'sessionID', 'trialID'}, 'RightKeys', {'mouseID', 'sessionIDforPairing', 'trialID'});
    % sort filesBpod by stimType, mouse and session
    filesWfBpod = sortrows(filesWfBpod, {'stimType_filesWf', 'mouseID', 'sessionID_filesWf'});
    % create file path for ACTmap
    filesWfBpod.actPath = cellfun(@(X, Y)fullfile(P.dir.actMap.raw, [X, '_', Y(3:end), '_ACT.mat']), filesWfBpod.mouse_filesWf, filesWfBpod.session_filesWf, 'UniformOutput', false);
    % remove trials that the duration of wf and bpod not match
    filesWfBpod.trialDurDiff = filesWfBpod.trialDur - filesWfBpod.trialDurWF;
    % display the mouse, session and trial information that the duration of wf and bpod not match
    filesUnmatch = filesWfBpod(abs(filesWfBpod.trialDurDiff) > 0.1, :);

    if sum(abs(filesWfBpod.trialDurDiff) > 0.1) > 0
        fprintf('   \nWarning: %d trials with duration difference (WF,Bpod) > 0.1s\n', sum(abs(filesWfBpod.trialDurDiff) > 0.1));
        disp(filesUnmatch(:, {'mouse_filesWf', 'session_filesWf', 'trialID', 'trialDur', 'trialDurWF', 'trialDurDiff'}));

        for i = 1:height(filesUnmatch)
            movefile(filesUnmatch.path_filesWf{i}, P.dir.bk)
        end

    end

    % keep only trials with difference < 0.1s
    filesWfBpod = filesWfBpod(abs(filesWfBpod.trialDurDiff) < 0.1, :);

    % if filesWfBpod is empty
    if height(filesWfBpod) == 0
        fprintf('  No good widefield tifs was found !\n')
        return
    end

    % select trials based on trialOutcome, moveDirection and randomNtrial
    filesWfBpod = SelectTrials(filesWfBpod, P);

    % for each mouseID and sessionID, align wf with bpod
    mouseIDs = unique(filesWfBpod.mouse_filesWf); sessionIDs = unique(filesWfBpod.session_filesWf);

    for i = 1:length(mouseIDs)

        for j = 1:length(sessionIDs)
            % get filesWfBpod for this mouseID and sessionID
            dataThis = filesWfBpod(ismember(filesWfBpod.mouse_filesWf, mouseIDs{i}) & ismember(filesWfBpod.session_filesWf, sessionIDs{j}), :);
            % skip if no filesWfBpod for this mouseID and sessionID
            if height(dataThis) == 0
                continue
            end

            % align with the trigger
            AlignWFwithTrigger(dataThis, P);
        end

    end

end

%% SelectTrials
function filesWfBpod = SelectTrials(filesWfBpod, P)

    switch filesWfBpod.stimType_filesWf{1}
        case 'passiveMovement'
            % select trials based on trialOutcome
            filesWfBpod = filesWfBpod(ismember(filesWfBpod.outcomeIdx, P.select.trial.proprioception.outcome), :);
            % select trials based on moveDirection
            filesWfBpod = filesWfBpod(ismember(filesWfBpod.mvtDir, P.select.trial.proprioception.mvtDir), :);
            % select random n trials if specified
            if ~isempty(P.select.trial.proprioception.randomNtrial)

                filesWfBpodNtrials = table();
                groupIDs = findgroups(filesWfBpod(:, {'mouse_filesWf', 'session_filesWf'}));
                groupID = unique(groupIDs);

                for i = 1:length(groupID)
                    thisFilesWfBpod = filesWfBpod(groupIDs == groupID(i), :);

                    if P.select.trial.proprioception.randomNtrial > height(thisFilesWfBpod)

                        switch P.select.trial.proprioception.ActionLessThanRandomNtrial
                            case 'resample'
                                nRepeat = ceil(P.select.trial.proprioception.randomNtrial - height(thisFilesWfBpod));
                                idxRepeat = randsample(height(thisFilesWfBpod), nRepeat);
                                thisFilesWfBpod = [thisFilesWfBpod; thisFilesWfBpod(idxRepeat, :)];
                            case 'skip'
                                thisFilesWfBpod = thisFilesWfBpod(1:0, :);
                        end

                    else
                        idx = randsample(height(thisFilesWfBpod), P.select.trial.proprioception.randomNtrial);
                        thisFilesWfBpod = thisFilesWfBpod(idx, :);
                    end

                    filesWfBpodNtrials = [filesWfBpodNtrials; thisFilesWfBpod];
                end

                filesWfBpod = filesWfBpodNtrials;
            end

        case 'vibration'
            filesWfBpod = filesWfBpod(filesWfBpod.outcomeIdx >= 3, :);
    end

    % sort filesWfBpod by trialID
    filesWfBpod = sortrows(filesWfBpod, 'trialID');
end

%% AlignWFwithTrigger
function AlignWFwithTrigger(filesWfBpod, P)

    tiralInfo = filesWfBpod;

    % return if filesWfBpod is empty
    if height(filesWfBpod) == 0
        return
    end

    % get session information
    mouse = filesWfBpod.mouse_filesWf{1}; session = filesWfBpod.session_filesWf{1}; stimType = filesWfBpod.stimType_filesWf{1};
    matSavePath = fullfile(P.dir.actMap.raw, [mouse, '_', session, '_ACT.mat']);
    tifSavePath = fullfile(P.dir.actMap.raw, [mouse, '_', session, '_ACT.tif']);

    % skip already been processed
    if isfile(matSavePath) && isfile(tifSavePath)
        fprintf('   Skip aligned: %s %s\n', mouse, session)
        return
    end

    % get image width and height
    imAvgInfo = imfinfo(filesWfBpod.path_filesWf{1});
    imAvgWidth = imAvgInfo(1, 1).Width;
    imAvgHeight = imAvgInfo(1, 1).Height;

    % get image time and number of frames
    imAvgTimeInterval = 1 / P.wf.frame.frq;
    imAvgTimes = [P.wf.align.win(1):imAvgTimeInterval:-imAvgTimeInterval, 0, imAvgTimeInterval:imAvgTimeInterval:P.wf.align.win(2)]';
    t = imAvgTimes;
    imAvgNframesPre = sum(imAvgTimes < 0);
    imAvgNframesPost = sum(imAvgTimes > 0);
    imAvgNframes = imAvgNframesPre + imAvgNframesPost + 1;

    % preallocate average images for imAvgBlue and imAvgViolet
    imAvgBlue = zeros(imAvgWidth, imAvgHeight, imAvgNframes);
    imAvgViolet = zeros(imAvgWidth, imAvgHeight, imAvgNframes);

    % load filesWfBpod frame by frame
    for i = progress(1:height(filesWfBpod), 'Title', ['   ', mouse, ' ', session])
        % file information
        imFile = filesWfBpod.path_filesWf{i};
        imInfo = imfinfo(imFile);
        imWidth = imInfo(1, 1).Width;
        imHeight = imInfo(1, 1).Height;
        imNframes = size(imInfo, 1);
        imData = zeros(imWidth, imHeight, imNframes, 'uint16');
        imTimes = zeros(imNframes, 1);

        for cFrame = 1:imNframes
            imData(:, :, cFrame) = imread(filesWfBpod.path_filesWf{i}, 'Index', cFrame);
            imTimes(cFrame, 1) = str2double(regexp(imInfo(cFrame, 1).ImageDescription, '(?<=Relative time = )\S*', 'match', 'once'));
        end

        imTimes(:, 1) = imTimes(:, 1) - imTimes(1, 1);
        % get blue and violet frames
        indBlue = 1:2:imNframes;
        indViolet = 2:2:imNframes;
        imBlue = double(imData(:, :, indBlue));
        imViolet = double(imData(:, :, indViolet));
        imTimesBlue = imTimes(indBlue);
        imTimesViolet = imTimes(indViolet);
        imTimesEqual = 0:imAvgTimeInterval:numel(imTimesBlue) * imAvgTimeInterval - imAvgTimeInterval;
        clear imData

        % interpolate violet and blue frames to equally spaced timepoints
        imBlue = shiftdim(imBlue, 2);
        imBlue = interp1(imTimesBlue, imBlue, imTimesEqual);
        imBlue = shiftdim(imBlue, 1);
        imViolet = shiftdim(imViolet, 2);
        imViolet = interp1(imTimesViolet, imViolet, imTimesEqual);
        imViolet = shiftdim(imViolet, 1);

        % align with the trigger
        switch stimType
            case 'passiveMovement'

                switch P.select.stim
                    case 1
                        [~, frIDalignTrigger] = min(abs(imTimesBlue - filesWfBpod.t1stMvt(i)));
                    case 2
                        [~, frIDalignTrigger] = min(abs(imTimesBlue - filesWfBpod.t2ndMvt(i)));
                end

            case 'vibration'
                [~, frIDalignTrigger] = min(abs(imTimesBlue - filesWfBpod.tStim(i)));
            case 'whisker'
                [~, frIDalignTrigger] = min(abs(imTimesBlue - filesWfBpod.tStim(i)));
        end

        imBlue = imBlue(:, :, frIDalignTrigger - imAvgNframesPre:frIDalignTrigger + imAvgNframesPost);
        imViolet = imViolet(:, :, frIDalignTrigger - imAvgNframesPre:frIDalignTrigger + imAvgNframesPost);

        imAvgBlue = imAvgBlue + imBlue / height(filesWfBpod);
        imAvgViolet = imAvgViolet + imViolet / height(filesWfBpod);
    end

    % flip images vertically and horizontally
    imAvgBlue = imAvgBlue(end:-1:1, end:-1:1, :);
    imAvgViolet = imAvgViolet(end:-1:1, end:-1:1, :);

    % regress violet from blue
    imAvgVioletREG = imAvgViolet;
    Nfr = size(imAvgBlue, 3);

    for m = 1:imAvgWidth
        outSig = zeros(Nfr, 1);
        inSig = zeros(Nfr, 1);

        for n = 1:imAvgHeight
            outSig(:, 1) = imAvgBlue(m, n, :);
            inSig(:, 1) = imAvgViolet(m, n, :);
            B = regress(outSig, [ones(Nfr, 1) inSig]);
            imAvgVioletREG(m, n, :) = imAvgViolet(m, n, :) * B(2) + B(1);
        end

    end

    % reference of baseline
    F0 = mean(imAvgBlue(:, :, 1:imAvgNframesPre), 3);
    IMblue = bsxfun(@minus, imAvgBlue, F0);
    IMblue = bsxfun(@rdivide, IMblue, F0);
    F0 = mean(imAvgVioletREG(:, :, 1:imAvgNframesPre), 3);
    IMviolet = bsxfun(@minus, imAvgVioletREG, F0);
    IMviolet = bsxfun(@rdivide, IMviolet, F0);

    % correct blue from violet
    IMcorr = IMblue - IMviolet;
    F0 = mean(IMcorr(:, :, 1:imAvgNframesPre), 3);
    IMcorr = bsxfun(@minus, IMcorr, F0); % normalize to baseline

    % smooth corrected frames
    order = 2;
    win = 9;

    for m = 1:imAvgWidth

        for n = 1:imAvgHeight
            IMcorr(m, n, :) = sgolayfilt(IMcorr(m, n, :), order, win);
        end

    end

    % generate activation map
    IMcorrNorm = (IMcorr - min(IMcorr(:))) / (max(IMcorr(:)) - min(IMcorr(:)));
    IMcorrNorm = imgaussfilt(IMcorrNorm, 2);
    % apply masks
    if P.flag.align.reuseMask
        load(P.path.roiMaskForAlignTrig, 'imMask');
    else
        close all;
        imREF = imread(fullfile(P.dir.refImage, [mouse, '_', session, '_REF.tif']));
        imREF = imREF(end:-1:1, end:-1:1);
        f0 = figure();
        imshow(imREF);
        hF = drawpolygon();
        imMask = createMask(hF);
        close(f0);
        save(P.path.roiMask, 'imMask');
    end

    IMcorrNorm(~repmat(imMask, [1 1 size(IMcorrNorm, 3)])) = nan;
    peakFrame = IMcorrNorm(:, :, 28);
    threshold = mean(peakFrame, "all", "omitnan") + 1.96 * std(peakFrame, 0, "all", "omitnan");
    peakFrame(peakFrame < threshold) = nan;
    im = ind2rgb(im2uint8(peakFrame), fire(256));

    switch stimType
        case 'passiveMovement'

            switch P.select.stim
                case 1
                    save(matSavePath, 'P', 'imAvgBlue', 'imAvgViolet', 'IMcorr', 'imMask', 't', 'tiralInfo');
                    imwrite(im, tifSavePath, 'tif', 'Compression', 'none', 'WriteMode', 'overwrite');
                case 2
                    save(strrep(matSavePath, 'ACT.mat', 'ACT_Stim2.mat'), 'P', 'imAvgBlue', 'imAvgViolet', 'IMcorr', 'imMask', 't', 'tiralInfo');
                    imwrite(im, strrep(tifSavePath, 'ACT.tif', 'ACT_Stim2.tif'), 'tif', 'Compression', 'none');
            end

        case 'vibration'
            save(matSavePath, 'P', 'imAvgBlue', 'imAvgViolet', 'IMcorr', 'imMask', 't', 'tiralInfo');
            imwrite(im, tifSavePath, 'tif', 'Compression', 'none', 'WriteMode', 'overwrite');

        case 'whisker'
            save(matSavePath, 'P', 'imAvgBlue', 'imAvgViolet', 'IMcorr', 'imMask', 't', 'tiralInfo');
            imwrite(im, tifSavePath, 'tif', 'Compression', 'none', 'WriteMode', 'overwrite');
    end

    % save filesWfBpod to mat file
    fprintf('   Save file: %s %s\n', mouse, session);

end
