classdef ActRawLimbMvt< handle
    %% Properties
    properties (Access = private)
        wfTable % table of wf images
        bpodTable % table of bpod data
        param % parameters for the analysis
    end

    properties
        wfBpodTable; % table of wf and bpod data combined
    end

    %% Methods
    methods
        %% Constructor
        function obj = ActRawLimbMvt(wfTable, bpodTable, param)
            obj.wfTable = wfTable; % table of wf images
            obj.bpodTable = bpodTable; % table of bpod data
            obj.bpodTable.LoadFile(); % load the bpod data
            obj.bpodTable.CleanVar({'path', 'folder', 'fileTable', 'namefull'}, 'remove'); % remove the unused variables
            obj.wfBpodTable = innerjoin(obj.wfTable.fileTable, obj.bpodTable.fileTable, 'Keys', {'mouse', 'session', 'trial'}); % combine the wf and bpod table
            obj.RemoveUnmatchedDurationTrials(); % remove the trials with unmatched duration
            obj.param = param; % parameters for the analysis
            obj.SelectTrial(); % select the trials
            obj.Align(); % align the data
        end

        %% Function Align
        function Align(obj)
            % group the data by mouse and session
            groupIdx = findgroups(obj.wfBpodTable(:, {'mouse', 'session'}));
            % align the data for each group
            for i = 1:max(groupIdx)
                % get the data for the current group
                currGroup = obj.wfBpodTable(groupIdx == i, :);
                % align the data
                alignWfBpod(currGroup, obj.param);
            end

        end
    end

    methods(Access = private)
        %% Function remove umatched duration trials
        function obj = RemoveUnmatchedDurationTrials(obj)
            % filter out trials with duration_left and duration_right that are not matched (difference > 0.1)
            unMatchTrials = filterRow(obj.wfBpodTable, {'duration_left','duration_right'}, @(X,Y)abs(X-Y)>0.1).path;
            % move the unMatchTrials to the backup folder
            backupFolder = Param().dir.bk;
            for i = 1:length(unMatchTrials)
                try
                    movefile(unMatchTrials{i}, backupFolder);
                catch
                    continue;
                end
            end
            % remove the unMatchTrials from the table
            obj.wfBpodTable = filterRow(obj.wfBpodTable, {'path'}, @(X) ~ismember(X, unMatchTrials));

        end

        %% Function SelectTrial
        function SelectTrial(obj)
            % select the mouse
            if ~isempty(obj.param.select.mouse)
                obj.wfBpodTable = filterRow(obj.wfBpodTable, 'mouse', obj.param.select.mouse);
            end
            % select the session
            if ~isempty(obj.param.select.session)
                obj.wfBpodTable = filterRow(obj.wfBpodTable, 'session', obj.param.select.session);
            end
            % select the trial by outcome
            if ~isempty(obj.param.select.trial.outcome)
                obj.wfBpodTable = filterRow(obj.wfBpodTable, 'outcomeIdx', obj.param.select.trial.outcome);
            end
            % select the trial by mvtDir
            if ~isempty(obj.param.select.trial.mvtDir)
                obj.wfBpodTable = filterRow(obj.wfBpodTable, 'mvtDir', obj.param.select.trial.mvtDir);
            end
        end
    end

end
