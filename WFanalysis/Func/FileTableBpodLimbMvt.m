classdef FileTableBpodLimbMvt < FileTableBpod

    %% Methods
    methods
        %% Constructor
        function obj = FileTableBpodLimbMvt(varargin)
            % Call superclass constructor
            obj = obj@FileTableBpod(varargin{:});
            % Filter Row by stimulus type
            obj.Filter('stimulusType','LimbMvtTriggerWF');
        end
        %% Load file
        function LoadFile(obj)
            LoadFile@FileTableBpod(obj)
            obj.fileTable = loadDataBpodLimbMvt(obj.fileTable);
            obj.fileTable = expendColumn(obj.fileTable, 'data');
        end
    end
end