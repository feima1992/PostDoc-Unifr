function trialInfoTable = GetSessionInfo(p)
%% GetTrialInfo - get session info from bpod session data
% p - struct of parameters
% trialInfoTable - table of session info
% find filelist
fileList = RGA.GetFileList('BpodRG');
% extract information
% get the mouse ID
mouse = RGA.RegMatch({fileList.name},1);
% mouseID is the number part of the mouse name
mouseID = cellfun(@(x) str2double(x(2:end)), mouse, 'UniformOutput', true);
% get the session ID
session = RGA.RegMatch({fileList.name},2);
sessionID = cellfun(@(x) str2double(x), session);
% combine the mouse ID and session ID
mouseSession = cellfun(@(x,y) [x '-' y], mouse, session, 'UniformOutput', false);
% file
file = {fileList.path}';
% if mouseSession is not unique, keep only the last one
[~,idx] = unique(mouseSession,'last');
mouse = mouse(idx); mouseID = mouseID(idx); session = session(idx); sessionID = sessionID(idx); mouseSession = mouseSession(idx); file = file(idx);
% combine into a table
trialInfoTable = table(mouse,mouseID,session,sessionID,mouseSession,file);
% for each session load the data and extract the trial info
for i = 1:height(trialInfoTable)
    F.Progress(i,height(trialInfoTable),'Loading Bpod data')
    % load the data
    load(trialInfoTable.file{i},'SessionData');
    % get the number of trials
    nTrials = SessionData.nTrials;
    % get trial outcomes
    trialOutcome = strcmp('correct',SessionData.trialOutcomes.Outcome);
    trialOutcome = trialOutcome(1:nTrials);
    % get the number of correct trials
    nTrialsCorrect = sum(trialOutcome);
    % get the number of touch events
    nTouch = sum(cellfun(@(x) numel(x.Events.Port3In), SessionData.RawEvents.Trial(trialOutcome), 'UniformOutput', true));
    % get the duration of trials
    %graspStartTrialCorrect = cellfun(@(x)x.States.GraspWater(1),SessionData.RawEvents.Trial(trialOutcome));
    %graspEndTrialCorrect = cellfun(@(x)x.States.GraspWater(2),SessionData.RawEvents.Trial(trialOutcome));
    % total duration of grasp
    %durationGrasp = sum(graspEndTrialCorrect - graspStartTrialCorrect);

    % add to table
    trialInfoTable.nTrials(i) = nTrials;
    trialInfoTable.nTrialsCorrect(i) = nTrialsCorrect;
    trialInfoTable.nTouch(i) = nTouch;
end
% sort by first mouseID then sessionID
trialInfoTable = sortrows(trialInfoTable,{'mouse','sessionID'});
trialInfoTable.sessionNumberID = zeros(height(trialInfoTable),1);
% for each mouse add the index number of the session
uniqueMouseID = unique(trialInfoTable.mouseID);
for i = 1:numel(uniqueMouseID)
    idx = trialInfoTable.mouseID == uniqueMouseID(i);
    trialInfoTable.sessionNumberID(idx) = 1:sum(idx);
end
% export to csv
writetable(trialInfoTable,fullfile(p.dir.session,'RGsessionInfo.csv'));
end