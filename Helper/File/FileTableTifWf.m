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
        end 
        
        %% AddDuration
        function AddDuration(obj)
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
    end
end