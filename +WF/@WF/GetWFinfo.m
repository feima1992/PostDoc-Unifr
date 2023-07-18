function GetWFinfo(obj)
    fprintf('>>> Get WF tif files information\n')
    % scan the widefield folder to find all the files
    filesWF = WF.Helper.FindFiles(obj.p.dir.wf,'.tif',{},'table_output',true);
    filesWF = filesWF(~ismember(filesWF.folder,obj.p.dir.bk),:);
    % add mouse and session info to filesWF
    FindMouse = @(X)regexp(X,'[a-zA-Z]\d{4}(?=_)','match','once');
    FindSession = @(X)regexp(X,'(?<=_)2[3-9][0-1][0-9][0-3][0-9](?=_)','match','once');
    FindTrial = @(X)regexp(X,'(?<=_)\d{4}$','match','once');
    filesWF.mouse = cellfun(@(X)FindMouse(X),filesWF.name,'UniformOutput',false);
    filesWF.session = cellfun(@(X)FindSession(X),filesWF.name,'UniformOutput',false);
    filesWF.trial = cellfun(@(X)FindTrial(X),filesWF.name,'UniformOutput',false);
    filesWF.mouseID = cellfun(@(X)str2double(X(2:end)),filesWF.mouse);
    filesWF.sessionID = cellfun(@(X)str2double(X),filesWF.session);
    filesWF.trialID = cellfun(@(X)str2double(X),filesWF.trial);
    % filter selected type of recording, mouse and session
    filesWF = SelectSession(filesWF,obj.p);
    % get the path of large files
    largeFiles = filesWF.path(filesWF.sizeMB > 1024);
    % move the large files to the backup folder
    for i = 1:length(largeFiles)
        movefile(largeFiles{i},obj.p.dir.bk);
        fprintf('LARGE File (>1Gb) %s moved to %s\n',largeFiles{i},obj.p.dir.bk);
    end
    filesWF = filesWF(filesWF.sizeMB <= 1000,:);
    % check WF tif files are not corrupted and get trial duration
    obj.WFinfo = CheckTifs(filesWF,obj.p);
end
%% SelectSession
function filesList = SelectSession(filesWF,p)
% preallocate
filesList = table();
% process for each type of recording

% proprioceptionPM
if p.select.stimType.proprioception
    mouse = p.select.animal.proprioception;
    if ~isempty(mouse)
        filesListTemp = filesWF(ismember(filesWF.mouse,mouse),:);
    else
        filesListTemp = filesWF;
    end
    sessionID = p.select.session.proprioception;
    if ~isempty(sessionID)
        filesListTemp = filesListTemp(ismember(filesListTemp.sessionID,sessionID),:);
    else
        filesListTemp = filesListTemp;
    end
    filesListTemp.stimType = repmat({'passiveMovement'},height(filesListTemp),1);
    filesList = [filesList;filesListTemp];
end

% vibration
if p.select.stimType.vibration
    mouse = p.select.animal.vibration;
    if ~isempty(mouse)
        filesListTemp = filesWF(ismember(filesWF.mouse,mouse),:);
    else
        filesListTemp = filesWF;
    end
    sessionID = p.select.session.vibration;
    if ~isempty(sessionID)
        filesListTemp = filesListTemp(ismember(filesListTemp.sessionID,sessionID),:);
    else
        filesListTemp = filesListTemp;
    end
    filesListTemp.stimType = repmat({'vibration'},height(filesListTemp),1);
    filesList = [filesList;filesListTemp];
end

% whisker
if p.select.stimType.whisker
    mouse = p.select.animal.whisker;
    if ~isempty(mouse)
        filesListTemp = filesWF(ismember(filesWF.mouse,mouse),:);
    else
        filesListTemp = filesWF;
    end
    sessionID = p.select.session.whisker;
    if ~isempty(sessionID)
        filesListTemp = filesListTemp(ismember(filesListTemp.sessionID,sessionID),:);
    else
        filesListTemp = filesListTemp; %#ok<*ASGSL> 
    end
    filesListTemp.stimType = repmat({'whisker'},height(filesListTemp),1);
    filesList = [filesList;filesListTemp];
end
end
%% CheckTifs
function filesWF = CheckTifs(filesWF,p)
    % check WF tif files are not corrupted and get trial duration

    % checkResults.txt to store the check results
    checkResultsPath = fullfile('Z:\users\Fei\DataAnalysis','checkResults.txt');
    if exist(checkResultsPath,'file')
        checkResults = readtable(checkResultsPath,'Delimiter','\t');
    else
        checkResults = filesWF(:,'path');
        checkResults.corruptedTif = NaN(height(filesWF),1);
        checkResults.trialDurWF = NaN(height(filesWF),1);
        writetable(checkResults,checkResultsPath,'Delimiter','\t')
    end
    % outer join checkResults and filesWF
    filesWF = outerjoin(filesWF,checkResults,'Keys','path','MergeKeys',true,'Type','Left');
    warning('off','all')
    for i = 1:height(filesWF)
        WF.Helper.Progress(i,height(filesWF),'Check WF tifs');
        % check if the tif file is already checked
        checkStatus = isnan(filesWF.corruptedTif(i));
        if checkStatus 
            % check if the tif file is corrupted
            try
                filesWF.trialDurWF(i) = length(imfinfo(filesWF.path{i}))/40;
                filesWF.corruptedTif(i) = 0;
            catch
                filesWF.trialDurWF(i) = NaN;
                filesWF.corruptedTif(i) = 1;
            end
            % update checkResults if filesWF.path{i} is in checkResults.path
            if ismember(filesWF.path{i},checkResults.path)
                checkResults.corruptedTif(ismember(checkResults.path,filesWF.path{i})) = filesWF.corruptedTif(i);
                checkResults.trialDurWF(ismember(checkResults.path,filesWF.path{i})) = filesWF.trialDurWF(i);
            else
                checkResults = [checkResults;filesWF(i,{'path','corruptedTif','trialDurWF'})]; %#ok<*AGROW> 
            end
            % update checkResults.txt
            writetable(checkResults,checkResultsPath,'Delimiter','\t')
        else
            continue
        end
    end
    warning('on','all')
end
