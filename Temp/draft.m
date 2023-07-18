% Get parameters

for i = 1:8
    i
    % get current drive name
    cpath = split(pwd,filesep);
    % add Wfanalysis to the path
    addpath(genpath([cpath{1},'\users\Fei\Code']));
    p = WF.GetParams(['p_d',num2str(i)],'process',true);
    % orgnize files: move to session folder
    %WF.OrgnizeMoveToSessionFolder(p)
    % get reference images
    WF.GetREFimages(p)
    %  orgnize files: remove wrong trials
    WF.OrgnizeRemoveWrongTrials(p)
    % align trigger
    WF.AlignTrig(p)
    % reg act map
    WF.RegACT(p)
    % find all the ATCreg data
    fileList = WFA.GetFileList(p,'ACTreg');
    % load trial information to the table
    infoTable = WFA.GetSessionInfo(fileList);

    % calculate the deltaFoverF
    WFA.CalDeltaFoverF(p,infoTable);
end