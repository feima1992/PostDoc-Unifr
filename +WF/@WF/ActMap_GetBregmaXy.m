function ActMap_GetBregmaXy(obj, varargin)
    % parse inputs
    Input = inputParser;
    addOptional(Input, 'mvtDirFlag', false, @(x)islogical(x) || ismember(x, [0, 1]));
    parse(Input, varargin{:});
    mvtDirFlag = Input.Results.mvtDirFlag;

    % Register the function call
    obj.RegCall(mfilename);

    %% get activity map
    if ~isfield(obj.ActMap, 'raw')

        if mvtDirFlag
            obj.Flow_CallMethod({'ActMap_GetFileList', 1})
        else
            obj.Flow_CallMethod({'ActMap_GetFileList', 0})
        end

    end

    %% get bregma coordinates
    % get all the files with bregma coordinates for each session
    regFiles = FindFiles(obj.P.dir.regXy, '_XYreg.mat', {}, 'table_out', true);
    FindMouse = @(X)regexp(X, '[a-zA-Z]\d{4}(?=_)', 'match', 'once');
    FindSession = @(X)regexp(X, '(?<=_)2[3-9][0-1][0-9][0-3][0-9](?=_)', 'match', 'once');
    regFiles.mouse = cellfun(@(X)FindMouse(X), regFiles.name, 'UniformOutput', false);
    regFiles.session = cellfun(@(X)FindSession(X), regFiles.name, 'UniformOutput', false);
    regFiles.mouseID = cellfun(@(X)str2double(X(2:end)), regFiles.mouse);
    regFiles.sessionID = cellfun(@(X)str2double(X), regFiles.session);
    [~, uniqueIdx] = unique(regFiles.namefull);
    regFiles = regFiles(uniqueIdx, {'mouse', 'session', 'mouseID', 'sessionID', 'path'});

    % get the bregma coordinates for each mouse and session
    for i = 1:height(regFiles)
        load(regFiles.path{i}, 'XYrefCTX');
        bregmaX = XYrefCTX(1, 1);
        bregmaY = XYrefCTX(1, 2);
        % calculate the coordinates of each pixel with respect to bregma as the origin
        [X, Y] = meshgrid(1:512, 1:512);
        X = X - bregmaX;
        Y = Y - bregmaY;
        % covert pixel coordinates to mm, 1 pixel = 0.019 mm
        X = X * 0.019;
        Y = Y * 0.019;
        % save the coordinates
        regFiles.X{i} = X;
        regFiles.Y{i} = Y;
        regFiles.XYs{i} = [bregmaX, bregmaY];
    end

    % save the coordinates
    bregmaXy = regFiles(uniqueIdx, {'mouse', 'session', 'mouseID', 'sessionID', 'X', 'Y', 'XYs'});

    if ~ismember('X', obj.ActMap.raw.Properties.VariableNames)
        obj.ActMap.raw = innerjoin(obj.ActMap.raw, bregmaXy, 'Keys', {'mouse', 'mouseID', 'session', 'sessionID'});
    end

end
