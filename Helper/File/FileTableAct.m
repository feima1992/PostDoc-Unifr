classdef FileTableAct < FileTable
    %% Methods
    methods
        %% Constructor
        function obj = FileTableAct(topDir, varargin)
            if nargin < 1
                topDisk = mfilename('fullpath');
                userDir = regexp(topDisk, '.*Fei', 'match', 'once');
                topDir = fullfile(userDir, 'Bpod');
            end
            % Call superclass constructor
            obj = obj@FileTable(topDir, varargin{:});
            % Filter the table to keep only the ActMap folders
            obj.Filter('path', @(X)contains(X, 'ActMap')&contains(X, '.mat'));
            % Add nTrial to the table
            obj.AddNtrial();
            % Add mvtDir to the table
            obj.AddMvtDir();
            % Add actType to the table
            obj.AddActType();
            obj.AddGroupInfo('1xbaLWzdmBQ-1Klv_2I2YOco51lpTwndMM7ZfOwqFW6c')
        end

        %% Add Ntrial to the table
        function AddNtrial(obj)
            findNtrial = @(X)regexp(X, '(?<=Trial).*?(?=\\)', 'match', 'once');
            obj.fileTable.nTrial = findNtrial(obj.fileTable.path);
        end

        %% Add mvtDir to the table
        function AddMvtDir(obj)
            obj.fileTable.mvtDir = findMvtDir(obj.fileTable.folder);
        end

        %% Add actType to the table
        function AddActType(obj)
            findActType = @(X)regexp(X, '(?<=ActMap\\).*', 'match', 'once');
            obj.fileTable.actType = findActType(obj.fileTable.folder);
        end
        %% Function add group information to the table
        function AddGroupInfo(obj, groupInfoSheetId)
            groupInfo = readGoogleSheet(groupInfoSheetId);
            groupInfo = convertvars(groupInfo, 'session', @(X)cellstr(string(X)));

            if ~ismember('group', obj.fileTable.Properties.VariableNames)
                obj.fileTable = innerjoin(obj.fileTable, groupInfo);
            end
            obj.CleanVar('problematicTrials', 'remove')
        end

        %% Function calculate delta F over F
        function CalDeltaFoverF(obj, varargin)
            calDeltaFoverF(obj.fileTable.path, varargin{:})
        end

        %% Function load deltaFoverF
        function loadDeltaFoverF(obj, varargin)
            % Notify the user that files are being loaded
            fprintf('   Loading deltaFoverF from %d files\n', height(obj.fileTable))
            tic;
            % Load deltaFoverF
            obj.fileTable = loadDeltaFoverF(obj.fileTable, varargin{:});
            % Notify the user that loading is done and how long it took
            fprintf('   Loading deltaFoverF from %d files took %.2f seconds\n', height(obj.fileTable), toc)
        end
    end

end