classdef WF < handle
    %% WF class for:
    % generating stimulus induced activation maps from widefield imaging data
    % analyzing activation maps
    
    %% WF class properties
    properties
        pName = 'basic' % name of parameter file to be used
        p % params
        WFinfo % information of WF tif files
        BpodInfo % information of Bpod files
        BpodWFInfo % information of the joint Bpod and WF files
        ACTinfo % information of the act files
        CoordPixels % coordinates of each pixels refer to bregma in mm
        TrialsCount % information of the trial count for act map
        callCount % count the call number of a method
        ROImask
        Plot
    end
    
    %% WF class methods
    methods
        %% constructor
        function obj = WF(pName, options)
            
            % validate input
            arguments
                pName (1,:) char = 'basic'
                options.mapForEachMvtDir logical = false
            end
            
            % config package path
            WF.Helper.ConfigPackagePath(mfilename('fullpath'));

            % set properties
            obj.pName = pName;
            
            % get parameters
            obj.GetParams();
            obj.p.act.flag.mapForEachMvtDir = options.mapForEachMvtDir;
            
            % init callCount
            obj.callCount.CalACTmap = 0;
        end
    end
end