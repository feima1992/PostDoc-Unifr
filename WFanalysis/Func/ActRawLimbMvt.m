classdef ActRawLimbMvt< ActRaw
    %% Methods
    methods
        %% Constructor
        function obj = ActRawLimbMvt(param,wfTable, bpodTable)
                 obj = obj@ActRaw(param,wfTable, bpodTable)
                 obj.SelectTrial();

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
