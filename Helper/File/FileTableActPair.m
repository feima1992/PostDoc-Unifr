classdef FileTableActPair
    %% Properties
    properties (SetAccess = immutable)
        fileTable
    end

    properties (Dependent)
        filePair
    end

    properties
        pairMethod = 'training-baseline';
    end

    %% Methods
    methods
        %% Constructor
        function obj = FileTableActPair(pairMethod, varargin)
            % Parse input
            if nargin > 0
                obj.pairMethod = pairMethod;
            end

            % Add fileTable to object
            obj.fileTable = FileTableAct(varargin{:}).fileTable;
        end

        %% Getter
        function filePair = get.filePair(obj)

            switch obj.pairMethod
                case {'training-baseline', 'all-random'}
                    filePair = pairActFile(obj.fileTable, 'pairMethod', obj.pairMethod);
                case {'allMthods', 'all', 'allMethod'}
                    filePair = [pairActFile(obj.fileTable, 'pairMethod', 'training-baseline'); ...
                                    pairActFile(obj.fileTable, 'pairMethod', 'all-random')];
            end

        end

    end

end
