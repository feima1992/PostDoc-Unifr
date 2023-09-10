classdef FileTableActReg < FileTableAct

    %% Methods
    methods
        %% Constructor
        function obj = FileTableActReg(varargin)
            % Call superclass constructor
            obj = obj@FileTableAct(varargin{:});
            % Filter rows to only include raw data
            obj.Filter('actType', 'Reg');
        end
    end
    
end