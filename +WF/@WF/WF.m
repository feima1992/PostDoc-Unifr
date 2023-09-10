classdef WF < handle

    %% WF class properties
    properties
        P % params structure
        Info % file information for wf, bpod, wfBpod
        ActMap % activation map for raw, reg, rawDiff, regDiff
        ActRoi % activation map with ROI mask average for raw, reg, rawDiff, regDiff, mask
        MethodCall % count of method call
    end

    %% WF class methods
    methods
        %% Constructor method
        function obj = WF(pName, MvtDirFlag)
            % validate input
            arguments

                pName (1, :) char = 'basic' % name of parameter file to be used, default is 'basic'
                MvtDirFlag (1, 1) logical = false % if true, calculate act map of each movement direction

            end

            % config package path
            obj.Set('packagePath', mfilename('fullpath'));

            % get parameters
            obj.Get('params', pName);

            % store MvtDirFlag in params
            obj.P.mvtDirFlag = MvtDirFlag;
            
            % initialize method call count
            obj.MethodCall = table(methods(obj),zeros(size(methods(obj))), 'VariableNames', {'Method', 'Count'});
            
            

        end

        %% set method
        function set.P(obj, val)

            % validate attribute
            validateattributes(val, {'struct'}, {'nonempty'}, mfilename, 'P', 1);
            obj.P = WF.Set.Params(val);

        end
        
        %% help method
        function RegCall(obj, methodName)
            obj.MethodCall.Count(ismember(obj.MethodCall.Method,methodName)) = obj.MethodCall.Count(ismember(obj.MethodCall.Method,methodName))  + 1;
        end

    end

end
