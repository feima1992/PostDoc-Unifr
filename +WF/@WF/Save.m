function Save(obj, target)
switch target
    case 'trialStat'

        % get trialStat of current running session
        cStat = obj.Info.wfBpod(:,{'mouseID','sessionID_filesBpod','trialID','outcomeIdx','mvtDir',});
        cStat.Properties.VariableNames = {'mouseID','sessionID','trialID','outcome','mvtDir'};

        % get trialStat of previous running session
        statFile = fullfile(fileparts(obj.P.folderPath), 'trialStat.csv');

        if exist(statFile, 'file')
            stat = readtable(statFile);
            stat = [stat; cStat];
            % remove duplicate rows
            stat = unique(stat);
        else
            stat = cStat;
        end
        
        writetable(stat, statFile);
end
end