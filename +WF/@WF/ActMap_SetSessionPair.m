function ActMap_SetSessionPair(obj, options)

    arguments
        obj
        % withinBaselineMethod: 'random' or 'chronological'
        options.withinBaselineMethod (1, :) char {mustBeMember(options.withinBaselineMethod, {'random', 'chronological'})} = 'random'
    end
    % register method call
    obj.RegCall(mfilename);

    % call dependent methods
    obj.Flow_CallMethod({'ActMap_GetFileList'});

    % get session pairs for raw and reg ActMap
    filedNames = {'raw', 'reg'};

    % loop through raw and reg
    for i = 1:length(filedNames)

        % initialize sessionPair table
        sessionPair = table();
        % get session table for this ActMap(raw or reg)
        ThisActMap = obj.ActMap.(filedNames{i});

        % get group index for each mouse
        groupIdx = findgroups(ThisActMap.mouse);

        % loop through each mouse
        for j = 1:length(unique(groupIdx))

            % within baseline session pairs
            thisMouse = ThisActMap(groupIdx == j, :); % get session table for this mouse
            thisMouseBaseline = thisMouse(ismember(thisMouse.phase, 'Baseline'), :); % get baseline session table for this mouse
            sessionNumIDbaseline = unique(thisMouseBaseline.sessionNumID); % get sessionNumID for baseline sessions of this mouse

            switch options.withinBaselineMethod
                case 'random' % randomly split baseline sessions into two groups
                    idxPart1 = randperm(length(sessionNumIDbaseline), length(sessionNumIDbaseline) / 2);
                    sessionNumIDbaseline1 = sessionNumIDbaseline(idxPart1);
                    sessionNumIDbaseline2 = sessionNumIDbaseline(~ismember(sessionNumIDbaseline, sessionNumIDbaseline1));
                case 'chronological' % split baseline sessions into two groups chronologically, first half and second half
                    sessionNumIDbaseline1 = sessionNumIDbaseline(1:length(sessionNumIDbaseline) / 2);
                    sessionNumIDbaseline2 = sessionNumIDbaseline(length(sessionNumIDbaseline) / 2 + 1:end);
            end

            % calculate within baseline session pairs
            sessionTableBaseline1 = thisMouseBaseline(ismember(thisMouseBaseline.sessionNumID, sessionNumIDbaseline1), :);
            sessionTableBaseline2 = thisMouseBaseline(ismember(thisMouseBaseline.sessionNumID, sessionNumIDbaseline2), :);
            sessionPairWithinBaselineTem = SessionPairHelper(sessionTableBaseline1, sessionTableBaseline2);
            sessionPairWithinBaselineTem.pairType = repmat({'withinBaseline'}, height(sessionPairWithinBaselineTem), 1);
            sessionPair = [sessionPair; sessionPairWithinBaselineTem];

            % training vs baseline session pairs
            sessionTableBaseline = thisMouseBaseline; % get baseline session table for this mouse
            sessionTableTraining = thisMouse(ismember(thisMouse.phase, 'Training'), :); % get training session table for this mouse
            sessionPairTrainingBaselineTem = SessionPairHelper(sessionTableBaseline, sessionTableTraining);
            sessionPairTrainingBaselineTem.pairType = repmat({'trainingBaseline'}, height(sessionPairTrainingBaselineTem), 1);
            sessionPair = [sessionPair; sessionPairTrainingBaselineTem]; %#ok<*AGROW>
        end

        % save sessionPair table
        obj.ActMap.([filedNames{i}, 'Diff']) = sessionPair;
    end

end

function sessionPairTem = SessionPairHelper(sessionTable1, sessionTable2)

    if ~ismember('module', sessionTable1.Properties.VariableNames) % for raw ActMap
        sessionPairTem = outerjoin(sessionTable1, sessionTable2, 'Keys', 'mouse');
    else % for reg ActMap
        % assign moduleID base on content of module column
        sessionTable1.moduleID = string(sessionTable1.module);
        sessionTable2.moduleID = string(sessionTable2.module);
        sessionPairTem = outerjoin(sessionTable1, sessionTable2, 'Keys', {'mouse', 'moduleID'});
    end

    % rename columns, replace _left and _right with 1 and 2
    sessionPairTem.Properties.VariableNames = cellfun(@(x) strrep(x, '_sessionTable1', '1'), sessionPairTem.Properties.VariableNames, 'UniformOutput', false);
    sessionPairTem.Properties.VariableNames = cellfun(@(x) strrep(x, '_sessionTable2', '2'), sessionPairTem.Properties.VariableNames, 'UniformOutput', false);
    % remove session pairs with same session
    sessionPairTem = sessionPairTem(sessionPairTem.sessionID1 ~= sessionPairTem.sessionID2, :);
end
