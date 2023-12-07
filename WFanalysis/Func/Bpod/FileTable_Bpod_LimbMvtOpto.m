classdef FileTable_Bpod_LimbMvtOpto < FileTable_Bpod

    %% Methods
    methods
        %% Constructor
        function obj = FileTable_Bpod_LimbMvtOpto(varargin)
            % Call superclass constructor
            obj = obj@FileTable_Bpod(varargin{:});
            % Filter Row by stimulus type
            obj.Filter('stimulusType','LimbMvtTriggerWFopto');
        end
        %% Load file
        function LoadFile(obj)
            LoadFile@FileTable_Bpod(obj)
            obj.fileTable = loadDataBpodLimbMvtOpto(obj.fileTable);
            obj.fileTable = expendColumn(obj.fileTable, 'data');
        end
    end
end