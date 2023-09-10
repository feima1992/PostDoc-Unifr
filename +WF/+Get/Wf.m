function wfInfo = Wf(p)
    fprintf('▶  Get WF tif files information\n')
    % scan the widefield folder to find all the files
    fielsWf = findFile(p.dir.wf, '.tif', {}, 'table_output', true);
    fielsWf = fielsWf(~ismember(fielsWf.folder, p.dir.bk), :);
    % add mouse and session info to fielsWf
    FindMouse = @(X)regexp(X, '[a-zA-Z]\d{4}(?=_)', 'match', 'once');
    FindSession = @(X)regexp(X, '(?<=_)2[3-9][0-1][0-9][0-3][0-9](?=_)', 'match', 'once');
    FindTrial = @(X)regexp(X, '(?<=_)\d{4}$', 'match', 'once');
    fielsWf.mouse = cellfun(@(X)FindMouse(X), fielsWf.name, 'UniformOutput', false);
    fielsWf.session = cellfun(@(X)FindSession(X), fielsWf.name, 'UniformOutput', false);
    fielsWf.trial = cellfun(@(X)FindTrial(X), fielsWf.name, 'UniformOutput', false);
    fielsWf.mouseID = cellfun(@(X)str2double(X(2:end)), fielsWf.mouse);
    fielsWf.sessionID = cellfun(@(X)str2double(X), fielsWf.session);
    fielsWf.trialID = cellfun(@(X)str2double(X), fielsWf.trial);
    % filter selected type of recording, mouse and session
    fielsWf = SelectSession(fielsWf, p);
    % get the path of large files
    largeFiles = fielsWf.path(fielsWf.sizeMB > 1024);
    % move the large files to the backup folder
    for i = 1:length(largeFiles)
        movefile(largeFiles{i}, p.dir.bk);
        fprintf('   LARGE File (>1Gb) %s moved to %s\n', largeFiles{i}, p.dir.bk);
    end

    fielsWf = fielsWf(fielsWf.sizeMB <= 1000, :);
    % check WF tif files are not corrupted and get trial duration
    wfInfo = CheckTifs(fielsWf);
end

%% SelectSession
function filesList = SelectSession(fielsWf, p)
    % preallocate
    filesList = table();
    % process for each type of recording

    % proprioceptionPM
    if p.select.stimType.proprioception
        mouse = p.select.animal.proprioception;

        if ~isempty(mouse)
            filesListTemp = fielsWf(ismember(fielsWf.mouse, mouse), :);
        else
            filesListTemp = fielsWf;
        end

        sessionID = p.select.session.proprioception;

        if ~isempty(sessionID)
            filesListTemp = filesListTemp(ismember(filesListTemp.sessionID, sessionID), :);
        else
            filesListTemp = filesListTemp;
        end

        filesListTemp.stimType = repmat({'passiveMovement'}, height(filesListTemp), 1);
        filesList = [filesList; filesListTemp];
    end

    % vibration
    if p.select.stimType.vibration
        mouse = p.select.animal.vibration;

        if ~isempty(mouse)
            filesListTemp = fielsWf(ismember(fielsWf.mouse, mouse), :);
        else
            filesListTemp = fielsWf;
        end

        sessionID = p.select.session.vibration;

        if ~isempty(sessionID)
            filesListTemp = filesListTemp(ismember(filesListTemp.sessionID, sessionID), :);
        else
            filesListTemp = filesListTemp;
        end

        filesListTemp.stimType = repmat({'vibration'}, height(filesListTemp), 1);
        filesList = [filesList; filesListTemp];
    end

    % whisker
    if p.select.stimType.whisker
        mouse = p.select.animal.whisker;

        if ~isempty(mouse)
            filesListTemp = fielsWf(ismember(fielsWf.mouse, mouse), :);
        else
            filesListTemp = fielsWf;
        end

        sessionID = p.select.session.whisker;

        if ~isempty(sessionID)
            filesListTemp = filesListTemp(ismember(filesListTemp.sessionID, sessionID), :);
        else
            filesListTemp = filesListTemp; %#ok<*ASGSL>
        end

        filesListTemp.stimType = repmat({'whisker'}, height(filesListTemp), 1);
        filesList = [filesList; filesListTemp];
    end

end

%% CheckTifs
function fielsWf = CheckTifs(fielsWf)
    % check WF tif files are not corrupted and get trial duration

    % checkResults.txt to store the check results
    checkResultsPath = fullfile('Z:\users\Fei\DataAnalysis\Utilities', 'checkResults.txt');

    if exist(checkResultsPath, 'file')
        checkResults = readtable(checkResultsPath, 'Delimiter', '\t');
    else
        checkResults = fielsWf(:, 'path');
        checkResults.corruptedTif = NaN(height(fielsWf), 1);
        checkResults.trialDurWF = NaN(height(fielsWf), 1);
        writetable(checkResults, checkResultsPath, 'Delimiter', '\t')
    end

    % outer join checkResults and fielsWf
    fielsWf = outerjoin(fielsWf, checkResults, 'Keys', 'path', 'MergeKeys', true, 'Type', 'Left');
    warning('off', 'all')

    for i = progress(1:height(fielsWf), 'Title', '   Check WF tifs')
        % check if the tif file is already checked
        checkStatus = isnan(fielsWf.corruptedTif(i));

        if checkStatus
            % check if the tif file is corrupted
            try
                fielsWf.trialDurWF(i) = length(imfinfo(fielsWf.path{i})) / 40;
                fielsWf.corruptedTif(i) = 0;
            catch
                fielsWf.trialDurWF(i) = NaN;
                fielsWf.corruptedTif(i) = 1;
            end

            % update checkResults if fielsWf.path{i} is in checkResults.path
            if ismember(fielsWf.path{i}, checkResults.path)
                checkResults.corruptedTif(ismember(checkResults.path, fielsWf.path{i})) = fielsWf.corruptedTif(i);
                checkResults.trialDurWF(ismember(checkResults.path, fielsWf.path{i})) = fielsWf.trialDurWF(i);
            else
                checkResults = [checkResults; fielsWf(i, {'path', 'corruptedTif', 'trialDurWF'})]; %#ok<*AGROW>
            end

            % update checkResults.txt
            writetable(checkResults, checkResultsPath, 'Delimiter', '\t')
        else
            continue
        end

    end

    warning('on', 'all')
end
