function loadDataBpodRg(fileTable)
    fileTable.data = cellfun(@(X)loadDataBpodRgHelper(X.SessionData), fileTable.data, 'UniformOutput', false);
end

function trialInfo = loadDataBpodRgHelper(data)
    protocolId = any(contains(fieldnames(data.RawEvents.Trial{1, 1}.States), 'reach', 'IgnoreCase', true)) + 1;
    switch protocolId
        case 1
            trialInfo = loadDataBpodRgHelperOldProtocol(data);
        case 2
            trialInfo = loadDataBpodRgHelperNewProtocol(data);
    end

end

function trialInfo = loadDataBpodRgHelperOldProtocol(data)
    trialInfo = cell(data.nTrials, 8); % trialId, outcome, outcomeId, latencyReach, latencyGrasp, nReach, nTouch, protocolId
    % get trial IDs
    trialInfo(:, 1) = num2cell(1:data.nTrials);
    % get trial outcomes
    trialInfo(:, 2) = data.trialOutcomes.Outcome(1:data.nTrials);
    [idx, ~] = find(data.trialOutcomes.OutcomeIdx');
    trialInfo(:, 3) = num2cell(idx);
    % get 1st reach latency
    trialInfo(:, 4) = num2cell(nan(data.nTrials, 1));
    % get 1st grasp latency
    tRewardBeep = cellfun(@(X)X.States.RewardBeep, data.RawEvents.Trial, 'UniformOutput', false);
    tGraspWater = cellfun(@(X)X.States.GraspWater, data.RawEvents.Trial, 'UniformOutput', false);
    trialInfo(:, 5) = num2cell(cellfun(@(X, Y)Y(1) - X(1), tRewardBeep, tGraspWater));
    % get protocolId
    protocolId = any(contains(fieldnames(data.RawEvents.Trial{1, 1}.States), 'reach', 'IgnoreCase', true)) + 1;
    trialInfo(:, 8) = num2cell(repmat(protocolId, data.nTrials, 1));
    % get number of reaches and touches
    % get number of touches
    tTouches = cellfun(@(X)X.Events.Port3In, data.RawEvents.Trial, 'UniformOutput', false);
    FunIsBetween = @(X, Y)X >= Y(:, 1) & X <= Y(:, 2);
    trialInfo(:, 7) = cellfun(@(X, Y)sum(FunIsBetween(X, Y)), tTouches, tGraspWater, 'UniformOutput', false);
    % number of reaches are the same as number of touches
    trialInfo(:, 6) = trialInfo(:, 7);
    % table of output
    trialInfo = cell2table(trialInfo, 'VariableNames', {'trialId', 'outcome', 'outcomeId', 'latencyReach', 'latencyGrasp', 'nReach', 'nTouch', 'protocolId'});
end

function trialInfo = loadDataBpodRgHelperNewProtocol
    trialInfo = cell(data.nTrials, 8); % trialId, outcome, outcomeId, latencyReach, latencyGrasp, nReach, nTouch, protocolId
    % get trial IDs
    trialInfo(:, 1) = num2cell(1:data.nTrials);
    % get trial outcomes
    trialInfo(:, 2) = data.trialOutcomes.Outcome(1:data.nTrials);
    [idx, ~] = find(data.trialOutcomes.OutcomeIdx');
    trialInfo(:, 3) = num2cell(idx);
    % get 1st reach latency
    tRewardBeep = cellfun(@(X)X.States.RewardBeep, data.RawEvents.Trial, 'UniformOutput', false);
    tReach = cellfun(@(X)X.States.WaitForGrasp(1), data.RawEvents.Trial, 'UniformOutput', false);
    trialInfo(:, 4) = num2cell(cellfun(@(X, Y)Y(1) - X(1), tRewardBeep, tReach));
    % get 1st grasp latency
    tGraspWater = cellfun(@(X)X.States.Grasp, data.RawEvents.Trial, 'UniformOutput', false);
    trialInfo(:, 5) = num2cell(cellfun(@(X, Y)Y(1) - X(1), tRewardBeep, tGraspWater));
    % get protocolId
    protocolId = any(contains(fieldnames(data.RawEvents.Trial{1, 1}.States), 'reach', 'IgnoreCase', true)) + 1;
    trialInfo(:, 8) = num2cell(repmat(protocolId, data.nTrials, 1));
    % get number of reaches and touches
    % get number of touches
    tTouches = cellfun(@(X)X.Events.Port3In, data.RawEvents.Trial, 'UniformOutput', false);
    FunIsBetween = @(X, Y)X >= Y(:, 1) & X <= Y(:, 2);
    trialInfo(:, 7) = cellfun(@(X, Y)sum(FunIsBetween(X, Y)), tTouches, tGraspWater, 'UniformOutput', false);
    % number of reaches are the same as number of touches
    trialInfo(:, 6) = trialInfo(:, 7);
    % table of output
    trialInfo = cell2table(trialInfo, 'VariableNames', {'trialId', 'outcome', 'outcomeId', 'latencyReach', 'latencyGrasp', 'nReach', 'nTouch', 'protocolId'});
end