function GetREFimages(obj)
fprintf('>>> Get Reference images\n')
filesList = obj.WFinfo;

% group table by mouse and session
filesList = sortrows(filesList,{'mouse','sessionID'});
mouse = unique(filesList.mouse);
sessionID = unique(filesList.sessionID);

% get REF images from the first trial of each mouse and session
for imouse = 1:length(mouse)
    for isession = 1:length(sessionID)
        filesListTemp = filesList(ismember(filesList.mouse,mouse{imouse}) & ismember(filesList.sessionID,sessionID(isession)),:);
        if ~isempty(filesListTemp)
            % sort by trialID ascending
            filesListTemp = sortrows(filesListTemp,'trialID');
            % get the first trial
            file = filesListTemp(1,:);
            % get the REF images
            REFfile = [file.mouse{1}, '_', file.session{1}, '_REF.tif'];
            REFvfile = [file.mouse{1}, '_', file.session{1}, '_REFv.tif'];
            if ~ isfile(fullfile(obj.p.dir.refImages, REFfile))
                REF = imread(file.path{1},1);
                imwrite(REF, fullfile(obj.p.dir.refImages, REFfile));
                disp(['Create >>> ',REFfile]);
            end
            if ~isfile(fullfile(obj.p.dir.refImages, REFvfile))
                REFv = imread(file.path{1},2);
                imwrite(REFv, fullfile(obj.p.dir.refImages, REFvfile));
                disp(['Create >>> ',REFvfile]);
            end
        end
    end
end
