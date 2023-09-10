function wfInfoTable = RemoveInteruptedTrials(wfInfoTable, p)
    %% Move tif files of wrong trial specified during recording
    fprintf('▶  Remove interupted trials\n');
    % load wrong trials from csv file
    wrongTrials = ReadGoogleSheet(p.gSheet.sessionNote);
    % remove the rows with any empty cell
    wrongTrials = wrongTrials(~any(cellfun(@isempty, table2cell(wrongTrials)), 2), :);
    % if proproblematic trials are specified
    if iscell(wrongTrials.problematicTrials)

        wrongTrials.Trials = cellfun(@(X)textscan(X, '%f', 'Delimiter', ','), wrongTrials.problematicTrials, 'UniformOutput', false);
        wrongTrials.Trials = cellfun(@(X)X{1}, wrongTrials.Trials, 'UniformOutput', false);
        % the 'trials' column is a vector of trial number identified as wrong trials, expending it to multiple rows
        wrongTrials = WF.Helper.ExpendColumn(wrongTrials, 'Trials');
        % get the inner join of wrongTrials and filesWF
        filesToMove = innerjoin(wrongTrials, wfInfoTable, 'LeftKeys', {'mouse', 'sessionID', 'Trials'}, 'RightKeys', {'mouse', 'sessionID', 'trialID'}).path;
    
        % target folder, p.dir.bk, is the backup folder for the WF data of the wrong trials, create it if not exist
        if ~exist(p.dir.bk, 'dir')
            mkdir(p.dir.bk);
        end
    
        % move the files to the backup folder
        for i = 1:length(filesToMove)
            movefile(filesToMove{i}, p.dir.bk);
            fprintf('  Interupted file %s moved to %s\n', filesToMove{i}, p.dir.bk);
        end
    
        % update the WFinfo table
        wfInfoTable = wfInfoTable(~ismember(wfInfoTable.path, filesToMove), :);
        
    end

    %% Remove tif files that were found to be corrupted
    % get the path of corrupted files
    corruptedFiles = wfInfoTable.path(logical(wfInfoTable.corruptedTif));
    % directly remove the corrupted files if there are less than 10 files
    if length(corruptedFiles) < 10

        for i = 1:length(corruptedFiles)
            delete(corruptedFiles{i});
            fprintf('  Corrupted file %s deleted\n', corruptedFiles{i});
        end

    else
        % if there are more than 10 corrupted files, ask for user confirmation
        fprintf('  There are %d corrupted files, are you sure to delete them all? (y/n)\n', length(corruptedFiles));
        userConfirm = input('', 's');

        if strcmp(userConfirm, 'y')

            for i = 1:length(corruptedFiles)
                delete(corruptedFiles{i});
                fprintf('  Corrupted file %s deleted\n', corruptedFiles{i});
            end

        else
            fprintf('  No file deleted\n');
        end

    end

    % update the WFinfo table
    wfInfoTable = wfInfoTable(~ismember(wfInfoTable.path, corruptedFiles), :);

    %% Remove tif files that were found to have a duration less than 2.5s
    % get the path of short files
    shortFiles = wfInfoTable.path(wfInfoTable.trialDurWF < 2.5);
    % move the short files to the backup folder
    for i = 1:length(shortFiles)
        movefile(shortFiles{i}, p.dir.bk);
        fprintf('  Small file %s moved to %s\n', shortFiles{i}, p.dir.bk);
    end

    % update the WFinfo table
    wfInfoTable = wfInfoTable(~ismember(wfInfoTable.path, shortFiles), :);
end
