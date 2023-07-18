function GetBpodInfo(obj)
    fprintf('>>> Get Bpod files information\n')
    % scan the bpod folder to find all the files
    filesBpod = WF.Helper.FindFiles(obj.p.dir.bp,'.mat',{'DefaultSettings','LimbReachGrasp','FakeSubject'},'table_output',true);
    % add mouse and session info to filesBpod
    FindMouse = @(X)regexp(X,'[a-zA-Z]\d{4}(?=_)','match','once');
    FindSession = @(X)regexp(X,'(?<=_)202[3-9][0-1][0-9][0-3][0-9](?=_)','match','once');
    filesBpod.mouse = cellfun(@(X)FindMouse(X),filesBpod.name,'UniformOutput',false);
    filesBpod.session = cellfun(@(X)FindSession(X),filesBpod.name,'UniformOutput',false);
    filesBpod.mouseID = cellfun(@(X)str2double(X(2:end)),filesBpod.mouse);
    filesBpod.sessionID = cellfun(@(X)str2double(X),filesBpod.session);

    % filter selected type of recording, mouse and session
    filesBpod = SelectSession(filesBpod,obj.p);
    % process sessions with multipul recordings
    filesBpod = RemoveDuplicate(filesBpod);
    % load bpod files
    BpodInfo = table();
    for i = 1:height(filesBpod)
        WF.Helper.Progress(i,height(filesBpod),'Loading Bpod files')
        dataBpod = LoadBpodData(filesBpod.path{i},'stimType', filesBpod.stimType{i});
        filesBpodExtended = repmat(filesBpod(i,:),height(dataBpod),1);
        BpodInfo = [BpodInfo;[filesBpodExtended, dataBpod]]; %#ok<*AGROW>
    end
    obj.BpodInfo = BpodInfo;
end
%% SelectSession
function filesList = SelectSession(filesBpod,p)
    % preallocate
    filesList = table();
    % process for each type of recording

    % proprioceptionPM
    if p.select.stimType.proprioception
        mouse = p.select.animal.proprioception;
        if ~isempty(mouse)
            filesListTemp = filesBpod(ismember(filesBpod.mouse,mouse),:);
        else
            filesListTemp = filesBpod;
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
            filesListTemp = filesBpod(ismember(filesBpod.mouse,mouse),:);
        else
            filesListTemp = filesBpod;
        end
        sessionID = p.select.session.vibration;
        if ~isempty(sessionID)
            filesListTemp = filesListTemp(ismember(filesListTemp.sessionID,sessionID),:);
        else
            filesListTemp = filesListTemp; %#ok<*ASGSL>
        end
        filesListTemp.stimType = repmat({'vibration'},height(filesListTemp),1);
        filesList = [filesList;filesListTemp];
    end

    % whisker
    if p.select.stimType.whisker
        mouse = p.select.animal.whisker;
        if ~isempty(mouse)
            filesListTemp = filesBpod(ismember(filesBpod.mouse,mouse),:);
        else
            filesListTemp = filesBpod;
        end
        sessionID = p.select.session.whisker;
        if ~isempty(sessionID)
            filesListTemp = filesListTemp(ismember(filesListTemp.sessionID,sessionID),:);
        else
            filesListTemp = filesListTemp;
        end
        filesListTemp.stimType = repmat({'whisker'},height(filesListTemp),1);
        filesList = [filesList;filesListTemp];
    end
end

function filesBpod = RemoveDuplicate(filesBpod)
    stimType = unique(filesBpod.stimType);
    for i = 1:length(stimType)
        stimTypeBpodFiles = filesBpod(strcmp(filesBpod.stimType,stimType{i}),:);
        mouse = unique(stimTypeBpodFiles.mouse);
        for j = 1:length(mouse)
            mouseBpodFiles = stimTypeBpodFiles(strcmp(stimTypeBpodFiles.mouse,mouse{j}),:);
            session = unique(mouseBpodFiles.session);
            for k = 1:length(session)
                sessionBpodFiles = mouseBpodFiles(strcmp(mouseBpodFiles.session,session{k}),:);
                if height(sessionBpodFiles) > 1
                    % sort by 'name' and keep only the last one
                    sessionBpodFiles = sortrows(sessionBpodFiles,'name','descend');
                    sessionBpodFilesPathToRemove = sessionBpodFiles(2:end,:).path;
                    % remove rows with the same path from filesBpod
                    filesBpod = filesBpod(~ismember(filesBpod.path,sessionBpodFilesPathToRemove),:);
                end
            end
        end
    end
end

function result = LoadBpodData(bpodFile,options)
% LoadBpodData loads data from Bpod file
%   result = LoadBpodData(bpodFile,options)
%   INPUTS
%       bpodFile: path to Bpod file
%       options: structure with fields
%           stimType: 'proprioception' or 'vibration' or 'whisker'

% validate inputs
    arguments
        bpodFile (1,:) char
        options.stimType (1,:) char {mustBeMember(options.stimType,{'passiveMovement','vibration','whisker'})} = 'passiveMovement'
    end

    % load data
    data = load(bpodFile,'SessionData');
    nTrials = data.SessionData.nTrials;
    switch options.stimType
        case 'passiveMovement'
            trialInfo = cell(nTrials,7); % 1st mvt time, 2nd mvt time, trial outcome, trial outcome idx, mvt direction
            % get trial IDs
            trialInfo(:,1) = num2cell(1:nTrials);
            % get 1st and 2nd movement times relative to camera trigger
            tTriggerCAMLED = cellfun(@(X)X.States.TriggerCAMLED(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            tMoveHomeTarget = cellfun(@(X)X.States.MoveOut(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            tMoveTargetHome = cellfun(@(X)X.States.MoveHome(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            trialInfo(:,2) = num2cell(tMoveHomeTarget - tTriggerCAMLED);
            trialInfo(:,3) = num2cell(tMoveTargetHome - tTriggerCAMLED);
            % get trial outcomes
            trialInfo(:,4) = data.SessionData.trialOutcomes.Outcome(1:nTrials);
            [idx,~] = find(data.SessionData.trialOutcomes.OutcomeIdx');
            trialInfo(:,5) = num2cell(idx);
            % get movement direction
            trialInfo(:,6) = num2cell(data.SessionData.PosTrigTrialHist(1:nTrials,1));
            % get trial duration
            tFinalState = cellfun(@(X)X.States.FinalState(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            trialInfo(:,7) = num2cell(tFinalState - tTriggerCAMLED);
            % table of output
            result = cell2table(trialInfo,'VariableNames',{'trialID','t1stMvt','t2ndMvt','outcome','outcomeIdx','mvtDir','trialDur'});


        case 'vibration'
            trialInfo = cell(nTrials,8);  % stim time, trial outcome, frequency/velocity , amplitude, stim type (1: touch, 2: vib. 3: texture)
            % get trial IDs
            trialInfo(:,1) = num2cell(1:nTrials);
            % get stim time relative to camera trigger
            tTriggerCAMLED = cellfun(@(X)X.States.TriggerCAMLED(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            tStimOn = cellfun(@(X)X.States.StimState(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            trialInfo(:,2) = num2cell(tStimOn - tTriggerCAMLED);
            % get trial outcomes
            trialInfo(:,3) = num2cell(data.SessionData.trialOutcomes.Outcome(1:nTrials));
            [idx,~] = find(data.SessionData.trialOutcomes.OutcomeIdx');
            trialInfo(:,4) = num2cell(idx);
            % get stim type (1: touch, 2: vib. 3: texture)
            trialInfo(:,5) = num2cell(cellfun(@(X)X.StimType,{data.SessionData.TrialSettings.GUI},'UniformOutput',true));
            % get stim frequency/velocity
            try
                trialInfo(:,6) = num2cell(cellfun(@(X)X.Stim_Fr,{data.SessionData.TrialSettings.GUI},'UniformOutput',true));
            catch
                trialInfo(:,6) = num2cell(data.SessionData.TrialSettings(1:nTrials).GUI.Texture_Vel);
            end
            % get stim amplitude
            trialInfo(:,7) = num2cell(cellfun(@(X)X.Stim_Amp,{data.SessionData.TrialSettings.GUI},'UniformOutput',true));
            % get trial duration
            tFinalState = cellfun(@(X)X.States.FinalState(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            trialInfo(:,8) = num2cell(tFinalState - tTriggerCAMLED);
            % table of output
            result = cell2table(trialInfo,'VariableNames',{'trialID','tStim','outcome','outcomeIdx','stimTypeID','stimFreq/Vel','stimAmp','trialDur'});
        case 'whisker'
            trialInfo = cell(nTrials,3);  % stim time
            % get trial IDs
            trialInfo(:,1) = num2cell(1:nTrials);
            % get stim time relative to camera trigger
            tTriggerCAMLED = cellfun(@(X)X.States.StartTrial(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            % get stim time relative to trial start
            tTriggerAirPuff= cellfun(@(X)X.States.AirPuff(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            trialInfo(:,2) = num2cell(tTriggerAirPuff - tTriggerCAMLED);
            % get trial duration
            tFinalState = cellfun(@(X)X.States.GiveReward(1,1),data.SessionData.RawEvents.Trial,'UniformOutput',true);
            trialInfo(:,3) = num2cell(tFinalState - tTriggerCAMLED);
            % table of output
            result = cell2table(trialInfo,'VariableNames',{'trialID','tStim','trialDur'});
    end
end