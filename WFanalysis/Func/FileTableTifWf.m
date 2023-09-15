classdef FileTableTifWf< FileTableTif
%% Methods
    methods
        %% Constructor
        function obj = FileTableTifWf(varargin)
            obj = obj@FileTableTif(varargin{:});
            obj.Filter('path',@(X)contains(X,'WFrecordings')&contains(X,'.tif')); % Filter out non-WF recordings
            obj.Remove('path',@(X)contains(X,'FakeSubject')); % Remove fake subject
            obj.AddDuration(); % Add duration to the fileTable
            obj.RemoveLongTrial(); % Remove trials with duration longer than 14s or NaN
            obj.GetRefImage();
        end 
        
        %% AddDuration
        function AddDuration(obj)
            fprintf('   Load tif record duration...\n');
            % Check whether temp file exists and read it if it does
            if exist(Param().path.fileTableTifWfTemp, 'file') == 2
                temp = readtable(Param().path.fileTableTifWfTemp, 'Delimiter', '\t');
                temp = convertvars(temp,'session',@(X)cellstr(string(X)));

                % Combine the existing duration column in the temp file to obj.fileTable
                if ~ ismember('duration', obj.fileTable.Properties.VariableNames)
                    obj.fileTable = leftJoin(obj.fileTable, temp, 'Keys', {'mouse', 'session', 'trial'});
                end
            else
                obj.fileTable.duration = nan(height(obj.fileTable),1);
            end

            % Add duration to the fileTable
            idxNanDuration = find(isnan(obj.fileTable.duration));
            for i = progress(1:length(idxNanDuration), 'Title', '   Add WF duration')
                % Add the duration to the fileTable
                obj.fileTable.duration(idxNanDuration(i)) = loadTifDuration(obj.fileTable.path{idxNanDuration(i)});
                % Save the temp file every 50 trials duration were added to the temp file
                if mod(i,50) == 0
                    writetable(obj.fileTable(:,{'mouse', 'session', 'trial', 'duration'}), Param().path.fileTableTifWfTemp, 'Delimiter', '\t');
                end
            end
            % Save the temp file after all trials were added to the temp file
            writetable(obj.fileTable(:,{'mouse', 'session', 'trial', 'duration'}), Param().path.fileTableTifWfTemp, 'Delimiter', '\t');
        end

        %% RemoveLongTrial
        function RemoveLongTrial(obj, varargin)
            % parser input
            p = inputParser;
            addOptional(p, 'durationThreshold', 14, @(X)isnumeric(X)&&isscalar(X));
            parse(p, varargin{:});
            durationThreshold = p.Results.durationThreshold;
            % Remove trials with duration longer than durationThreshold or NaN
            longTrials = filterRow(obj.fileTable, 'duration', @(X)X>=durationThreshold | isnan(X)).path;
            % Show notification
            fprintf('   %d trials with duration > %ds were moved to backup folder...\n', length(longTrials), durationThreshold);
            % move the long trials to the backup folder
            bkupFolder = Param().dir.bk;
            for i = 1:length(longTrials)
                try
                    movefile(longTrials{i}, bkupFolder);
                catch
                    continue;
                end
            end
            obj.Remove('duration', @(X)X>=durationThreshold | isnan(X));
        end

        %% GetRefImage
        function GetRefImage(obj)
            % Get the reference image for each mouse and session (the earliest trial)
            [~, fileTableRefIdx] = findgroups(obj.fileTable(:,{'mouse', 'session'}));
            [~, fileTableRefIdx] = ismember(fileTableRefIdx,obj.fileTable(:,{'mouse', 'session'}));
            fileTableRef = obj.fileTable(fileTableRefIdx,:);
            % Get the reference image path for each mouse and session
            funcRefPath = @(X,Y)fullfile(Param().dir.refImage,[ X, '_', Y, '_REF.tif']);
            fileTableRef.refPath = rowfun(funcRefPath, fileTableRef, 'InputVariables', {'mouse', 'session'}, 'OutputVariableNames', 'refPath', 'ExtractCellContents', true, 'OutputFormat', 'cell');
            fileTableRef.refPathExist = cellfun(@(X)exist(X,'file'), fileTableRef.refPath);
            % Get the violet reference image path for each mouse and session
            funcRefVpath = @(X,Y)fullfile(Param().dir.refImage, [X, '_', Y, '_REFv.tif']);
            fileTableRef.refVpath = rowfun(funcRefVpath, fileTableRef, 'InputVariables', {'mouse', 'session'}, 'OutputVariableNames', 'refVpath', 'ExtractCellContents', true, 'OutputFormat', 'cell');
            fileTableRef.refVpathExist = cellfun(@(X)exist(X,'file'), fileTableRef.refVpath);
            % Filter out the sessions without reference image or violet reference image
            fileTableRef = fileTableRef(~(fileTableRef.refPathExist | fileTableRef.refVpathExist),:);
            % Extract the reference image for each mouse and session
            for i = 1:height(fileTableRef)
                % Extract the reference image
                refImage = imread(fileTableRef.path{i},1);
                refVimage = imread(fileTableRef.path{i},2);
                % Save the reference image
                imwrite(refImage, fileTableRef.refPath{i});
                imwrite(refVimage, fileTableRef.refVpath{i});
                % Show notification
                fprintf('   Reference image for %s %s extracted\n', fileTableRef.mouse{i}, fileTableRef.session{i});
            end
        end
    end
end