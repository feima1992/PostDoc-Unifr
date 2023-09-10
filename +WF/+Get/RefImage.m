function RefImage(filesList, p)
    fprintf('▶  Get reference images\n');
    % group table by mouse and session
    filesList = sortrows(filesList, {'mouse', 'sessionID'});
    mouse = unique(filesList.mouse);
    sessionID = unique(filesList.sessionID);

    % get REF images from the first trial of each mouse and session
    for imouse = 1:length(mouse)

        for isession = 1:length(sessionID)
            filesListTemp = filesList(ismember(filesList.mouse, mouse{imouse}) & ismember(filesList.sessionID, sessionID(isession)), :);

            if ~isempty(filesListTemp)
                % sort by trialID ascending
                filesListTemp = sortrows(filesListTemp, 'trialID');
                % get the first trial
                file = filesListTemp(1, :);
                % get the REF images
                refFile = [file.mouse{1}, '_', file.session{1}, '_REF.tif'];
                refVfile = [file.mouse{1}, '_', file.session{1}, '_REFv.tif'];

                if ~isfile(fullfile(p.dir.refImage, refFile))
                    REF = imread(file.path{1}, 1);
                    imwrite(REF, fullfile(p.dir.refImage, refFile));
                    disp([' Create ', refFile]);
                end

                if ~isfile(fullfile(p.dir.refImage, refVfile))
                    REFv = imread(file.path{1}, 2);
                    imwrite(REFv, fullfile(p.dir.refImage, refVfile));
                    disp([' Create ', refVfile]);
                end

            end

        end

    end
