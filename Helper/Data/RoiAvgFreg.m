classdef RoiAvgFreg < handle
    %% Properties
    properties
        actFile
        regMask
    end

    %% Methods
    methods
        % Constructor
        function obj = RoiAvgFreg(varargin)
            % parse inputs
            p = inputParser;
            addOptional(p, 'actFile', {});
            addOptional(p, 'regMask', {26});
            parse(p, varargin{:});

            actFileParam = p.Results.actFile;
            regMaskParam = p.Results.regMask;

            if isscalar(regMaskParam)
                regMaskParam = {regMaskParam};
            end

            obj.actFile = FileTableActReg(actFileParam{:});
            obj.regMask = MaskReg(regMaskParam{:});
        end

        % Calculate average deltaF/F for ROI
        function CalAvgF(obj)

            if ~ismember('avgF', obj.actFile.fileTable.Properties.VariableNames)

                if ~ismember('deltaFoverF', obj.actFile.fileTable.Properties.VariableNames)
                    obj.actFile.loadDeltaFoverF();
                end

                obj.actFile.fileTable = hCombineTable(obj.actFile.fileTable, obj.regMask.maskTable);
                RowFunMean = @(X, Y)nanmean(X{1}(Y{1}));
                avgF = rowfun(RowFunMean, obj.actFile.fileTable, 'InputVariables', {'deltaFoverF', 'maskTable'}, 'OutputVariableName', {'avgF'});
                obj.actFile.fileTable = [obj.actFile.fileTable, avgF];
            else 
                fprintf('   Roi averaged deltaF/F already calculated.\n');
            end

        end

    end

end
