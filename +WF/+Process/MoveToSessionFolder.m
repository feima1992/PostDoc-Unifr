function MoveToSessionFolder(P, options)

    arguments
        P
        options.processBackupFolder (1, 1) logical = false
    end

    %% orgnize all the video files, mouse and session selections do not have effects

    % wf tif files, wide field imaging files
    if exist(P.dir.wf, 'dir') == 7
        filesWf = findFile(P.dir.wf, '.tif', {'m0', 'v0', 't0', 'r0'}, 'table_output', true);

        if ~isempty(filesWf)
            filesWf.dir = repmat({P.dir.wf}, height(filesWf), 1);
        else
            filesWf = table();
        end

    else
        filesWf = table();
    end

    % rg tif files, reach grapsing files
    if exist(P.dir.rg, 'dir') == 7
        filesRg = findFile(P.dir.rg, '.tif', {'r0', 'm9'}, 'table_output', true);

        if ~isempty(filesRg)
            filesRg.dir = repmat({P.dir.rg}, height(filesRg), 1);
        else
            filesRg = table();
        end

    else
        filesRg = table();
    end

    % bh tif files, behavior recording files
    if exist(P.dir.bh, 'dir') == 7
        filesBh = findFile(P.dir.bh, '.tif', {}, 'table_output', true);

        if ~isempty(filesBh)
            filesBh.dir = repmat({P.dir.bh}, height(filesBh), 1);
        else
            filesBh = table();
        end

    else
        filesBh = table();
    end

    % combine all the files
    filesList = [filesWf; filesRg; filesBh];

    % if no file found, return
    if isempty(filesList)
        fprintf('✖✖✖No file found\n');
        return;
    end

    % regexp string to find mouse, session
    FindMouse = @(X)regexp(X, '[a-zA-Z]\d{4}(?=_)', 'match', 'once');
    FIndSession = @(X)regexp(X, '(?<=_)2[3-9][0-1][0-9][0-3][0-9](?=_)', 'match', 'once');

    % add mouse, session info to table
    filesList.mouse = cellfun(FindMouse, filesList.name, 'UniformOutput', false);
    filesList.session = cellfun(FIndSession, filesList.name, 'UniformOutput', false);

    % combine fileList.dir, fileList.mouse, fileList.session to get targetDir in a row-wise manner
    filesList.targetDir = fullfile(filesList.dir, filesList.mouse, filesList.session);

    % combine fileList.targetDir, fileList.fullname to get targetPath in a row-wise manner
    filesList.targetPath = fullfile(filesList.targetDir, filesList.namefull);

    % determine if FileList.folder is the same as FileList.targetDir
    if options.processBackupFolder
        filesList.needToMove = (~strcmp(filesList.folder, filesList.targetDir));
    else
        filesList.needToMove = (~strcmp(filesList.folder, filesList.targetDir)) & (~ismember(filesList.folder, P.dir.bk));
    end

    filesList = filesList(filesList.needToMove, :);

    fprintf('▶  Move tif files to session folder\n')

    % if no file need to move, return
    if isempty(filesList)
        fprintf('   No file need to move\n');
        return;
    end

    % for each file, move it from fileList.path to fileList.targetPath
    for i = 1:height(filesList)

        if ~exist(filesList.targetDir{i}, 'dir')
            mkdir(filesList.targetDir{i});
        end

        movefile(filesList.path{i}, filesList.targetDir{i});
    end

    fprintf('  %d files need to move\n', height(filesList));

end
