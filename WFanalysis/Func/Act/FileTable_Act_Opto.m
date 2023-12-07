classdef FileTable_Act_Opto < FileTable_Act
    %% properties
    properties
        pairedFileTable
    end

    %% methods
    methods

        % constructor
        function obj = FileTable_Act_Opto(varargin)
            obj = obj@FileTable_Act(varargin{:});
        end

        % getters
        function pairedFileTable = get.pairedFileTable(obj)
            pairedFileTable = obj.PairLazerOnOff().pairedFileTable;
        end

        % function to pair lazerOn and lazerOff sessions
        function obj = PairLazerOnOff(obj)
            lazerOn = obj.fileTable(ismember(obj.fileTable.trialType, 'LazerOn'),:);
            lazerOff = obj.fileTable(ismember(obj.fileTable.trialType, 'LazerOff'),:);
            if height(lazerOn) ~= height(lazerOff)
                warning('lazerOn and lazerOff trials are not equal')
            end
            obj.pairedFileTable = innerjoin(lazerOn,lazerOff, 'Keys', {'namefull', 'mouse', 'session', 'actType', 'mvtDir'});
        end
    end
end