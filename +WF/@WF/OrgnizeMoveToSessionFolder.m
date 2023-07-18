function OrgnizeMoveToSessionFolder(obj,options)
arguments
    obj
    options.processBackupFolder (1,1) logical = false
end
% orgnize all the video files, mouse and session selections do not have effects

if exist(obj.p.dir.wf,'dir')==7
    filesWF = WF.Helper.FindFiles(obj.p.dir.wf,'.tif',{'m0','v0','t0','r0'},'table_output',true);
    if ~isempty(filesWF)
        filesWF.dir = repmat({obj.p.dir.wf},height(filesWF),1);
    else
        filesWF = table();
    end
else
    filesWF = table();
end
if exist(obj.p.dir.rg,'dir')==7
    filesRG = WF.Helper.FindFiles(obj.p.dir.rg,'.tif',{'r0','m9'},'table_output',true); 
    if ~isempty(filesRG)
        filesRG.dir = repmat({obj.p.dir.rg},height(filesRG),1);
    else
        filesRG = table();
    end
else
    filesRG = table();
end
if exist(obj.p.dir.bh,'dir')==7
    filesBH = WF.Helper.FindFiles(obj.p.dir.bh,'.tif',{},'table_output',true);
    if ~isempty(filesBH)
        filesBH.dir = repmat({obj.p.dir.bh},height(filesBH),1);
    else
        filesBH = table();
    end
else
    filesBH = table();
end
 
filesList = [filesWF;filesRG;filesBH];
% if no file found, return
if isempty(filesList)
    fprintf('No file found\n');
    return;
end

% regexp string to find mouse, session
FindMouse = @(X)regexp(X,'[a-zA-Z]\d{4}(?=_)','match','once');
FIndSession = @(X)regexp(X,'(?<=_)2[3-9][0-1][0-9][0-3][0-9](?=_)','match','once');
% add mouse, session info to table
filesList.mouse = cellfun(FindMouse,filesList.name,'UniformOutput',false);
filesList.session = cellfun(FIndSession,filesList.name,'UniformOutput',false);

% combine fileList.dir, fileList.mouse, fileList.session to get targetDir in a row-wise manner
filesList.targetDir = fullfile(filesList.dir,filesList.mouse,filesList.session);

% combine fileList.targetDir, fileList.fullname to get targetPath in a row-wise manner
filesList.targetPath = fullfile(filesList.targetDir,filesList.namefull);

% determine if FileList.folder is the same as FileList.targetDir
if options.processBackupFolder
    filesList.needToMove = (~strcmp(filesList.folder,filesList.targetDir));
else
    filesList.needToMove = (~strcmp(filesList.folder,filesList.targetDir)) & (~ismember(filesList.folder,obj.p.dir.bk));
end
filesList = filesList(filesList.needToMove,:);
fprintf('>>> Move wf tif files to session folder\n')
% if no file need to move, return
if isempty(filesList)
    fprintf('No file need to move\n');
    return;
end

% for each file, move it from fileList.path to fileList.targetPath
for i = 1:height(filesList)
    WF.Helper.Progress(i,height(filesList),'Move wf tif files to session folder');
    if ~exist(filesList.targetDir{i},'dir')
        mkdir(filesList.targetDir{i});
    end
    movefile(filesList.path{i},filesList.targetDir{i});
end
end