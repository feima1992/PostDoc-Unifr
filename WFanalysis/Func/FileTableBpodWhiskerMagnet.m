classdef FileTableBpodWhiskerMagnet < FileTableBpod

    %% Methods
    methods
        %% Constructor
        function obj = FileTableBpodWhiskerMagnet(varargin)
            % Call superclass constructor
            obj = obj@FileTableBpod(varargin{:});
            % Filter Row by stimulus type
            obj.Filter('stimulusType','WhiskerMagnetWF');
        end
        %% Load file
        function LoadFile(obj)
            LoadFile@FileTableBpod(obj)
            obj.fileTable = loadDataBpodWhiskerMagnet(obj.fileTable);
            obj.fileTable = expendColumn(obj.fileTable, 'data');
        end
    end
end