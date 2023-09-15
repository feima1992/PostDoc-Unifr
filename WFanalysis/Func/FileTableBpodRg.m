classdef FileTableBpodRg < FileTableBpod

    %% Methods
    methods
        %% Constructor
        function obj = FileTableBpodRg(varargin)
            % Call superclass constructor
            obj = obj@FileTableBpod(varargin{:});
            % Filter Row by stimulus type
            obj.Filter('stimulusType','LimbReachGrasp');
        end
        %% Load file
        function LoadFile(obj)
            LoadFile@FileTableBpod(obj);
        end
    end
end