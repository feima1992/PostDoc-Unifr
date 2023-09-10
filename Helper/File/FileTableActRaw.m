classdef FileTableActRaw < FileTableAct

    %% Methods
    methods
        %% Constructor
        function obj = FileTableActRaw(varargin)
            % Call superclass constructor
            obj = obj@FileTableAct(varargin{:});
            % Filter rows to only include raw data
            obj.Filter('actType', 'Raw');
        end
    end
    
end