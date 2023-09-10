function ActMap_GetFileList(obj, varargin)
    % parse Input
    Input = inputParser;
    addOptional(Input, 'mvtDirFlag', false, @(x)islogical(x) || isnumeric(x));
    parse(Input, varargin{:});
    mvtDirFlag = Input.Results.mvtDirFlag;

    % Register the function call
    obj.RegCall(mfilename);

    % find all the ACT files in the analysis folder
    if obj.P.mvtDirFlag || mvtDirFlag
        folderPath = fileparts(obj.P.folderPath);
    else
        folderPath = obj.P.folderPath;
    end
    fprintf('   Looking for ACT files in %s\n', folderPath)

    actFiles = FindFiles(folderPath, {'.mat', 'ActMap'}, {}, 'table_out', true);

    % functions to extract information from the file folder or name
    FindMouse = @(X)regexp(X, '[a-zA-Z]\d{4}(?=_)', 'match', 'once');
    FindSession = @(X)regexp(X, '(?<=_)2[3-9][0-1][0-9][0-3][0-9](?=_)', 'match', 'once');
    FindMvtDir = @(X)fillmissing(str2double(regexp(X, '(?<=MvtDir)\d{1}(?=\\)', 'match', 'once')), 'constant', 0);

    % extract information from the file name
    actFiles.mouse = FindMouse(actFiles.name);
    actFiles.mouseID = cellfun(@(X)str2double(X(2:end)), actFiles.mouse);
    actFiles.session = FindSession(actFiles.name);
    actFiles.sessionID = cellfun(@(X)str2double(X), actFiles.session);

    % extract information from the file folder
    actFiles.mvtDir = FindMvtDir(actFiles.folder);

    % load group information
    groupInfo = ReadGoogleSheet(obj.P.gSheet.sessionNote);
    groupInfo.mosueID = cellfun(@(X)str2double(X(2:end)), groupInfo.mouse);

    % join the two tables, actFiles as base, with left join
    actFiles = innerjoin(actFiles, groupInfo, 'Keys', {'mouse', 'mouseID', 'sessionID'});
    % clean up the table to keep only the relevant columns
    actFiles = actFiles(:, {'mouse', 'session', 'mouseID', 'sessionID', 'sessionNumID', 'group', 'phase', 'phaseID', 'mvtDir', 'path', 'folder'});
    % remove the columns with NaN
    actFiles = actFiles(:, ~any(ismissing(actFiles), 1));
    % seperate raw act and regestrated act
    obj.ActMap.raw = actFiles(cellfun(@(X)contains(X, 'ACT.mat'), actFiles.path), :);
    obj.ActMap.reg = actFiles(cellfun(@(X)contains(X, 'REG.mat'), actFiles.path), :);
    
    % get bregma xy coordinates
    obj.Flow_CallMethod('ActMap_GetBregmaXy');
    
    % copy obj.ActMap to obj.ActRoi
    obj.ActRoi = obj.ActMap;

end
