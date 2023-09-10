classdef ParamLimbMvt < Param
    methods
        function obj = ParamLimbMvt(varargin)
            obj = obj@Param(varargin{:});
            obj.select.stimId = 1;
            obj.select.trial.outcome = [3, 4, 5];
            obj.select.trial.mvtDir = [1, 2, 3, 4, 5, 6, 7, 8];
        end
       
    end
end