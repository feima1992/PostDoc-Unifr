function fileTable = loadDataBpodLimbMvt(fileTable)
    fileTable.data = cellfun(@(X)loadDataBpodLimbMvtHelper(X.SessionData),fileTable.data,'UniformOutput',false);
end

function trialInfo = loadDataBpodLimbMvtHelper(data)
    trialInfo = cell(data.nTrials, 7); % 1st mvt time, 2nd mvt time, trial outcome, trial outcome idx, mvt direction
    % get trial IDs
    trialInfo(:, 1) = num2cell(1:data.nTrials);
    % get 1st and 2nd movement times relative to camera trigger
    tTriggerCAMLED = cellfun(@(X)X.States.TriggerCAMLED(1, 1), data.RawEvents.Trial, 'UniformOutput', true);
    tMoveHomeTarget = cellfun(@(X)X.States.MoveOut(1, 1), data.RawEvents.Trial, 'UniformOutput', true);
    tMoveTargetHome = cellfun(@(X)X.States.MoveHome(1, 1), data.RawEvents.Trial, 'UniformOutput', true);
    trialInfo(:, 2) = num2cell(tMoveHomeTarget - tTriggerCAMLED);
    trialInfo(:, 3) = num2cell(tMoveTargetHome - tTriggerCAMLED);
    % get trial outcomes
    trialInfo(:, 4) = data.trialOutcomes.Outcome(1:data.nTrials);
    [idx, ~] = find(data.trialOutcomes.OutcomeIdx');
    trialInfo(:, 5) = num2cell(idx);
    % get movement direction
    trialInfo(:, 6) = num2cell(data.PosTrigTrialHist(1:data.nTrials, 1));
    % get trial duration
    tFinalState = cellfun(@(X)X.States.FinalState(1, 1), data.RawEvents.Trial, 'UniformOutput', true);
    trialInfo(:, 7) = num2cell(tFinalState - tTriggerCAMLED);
    % table of output
    trialInfo = cell2table(trialInfo, 'VariableNames', {'trial', 't1stMvt', 't2ndMvt', 'outcome', 'outcomeIdx', 'mvtDir', 'duration'});
end
