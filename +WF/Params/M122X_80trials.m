function P = Parameters()

    %% generate parameters structure

    % create a structure to store all the parameters
    P = struct();

    %% data analysis folder
    fullPath = mfilename('fullpath');
    fullPath = strsplit(fullPath, '\');
    P.folderUser = fullfile(fullPath{1:3});
    P.folderParent = fullfile(P.folderUser,'DataAnalysis');
    P.folderName = 'WF_M122X\Trial80\MvtDir0'; % 0 indicate all 8 directions
    P.folderPath = fullfile(P.folderParent, P.folderName);

    %% parameters for widefield and Bpod data directory and file path

    % directory where the bpod data is located
    P.dir.bp = fullfile(P.folderUser, 'Bpod\Bpod Local\Data\'); % directory of bpod data

    % on which hard drive the widefield and behavior videos are stored
    dataDriveID = 1;

    switch dataDriveID
        case 0 % D drive
            prefix = 'D:\Data\';
            P.dir.wf = fullfile(prefix, 'WFrecordings'); % directory of widefield video recordings
            P.dir.bh = fullfile(prefix, 'VideoRecordings'); % directory of behavior video recordings
            P.dir.rg = fullfile(prefix, 'ReachGrasp'); % directory of behavior video recordings of reach and grasp task
            P.dir.bk = fullfile(prefix, 'WFrecordings\FakeSubject'); % directory of backup folderPath to store wf recordings with problem
        case 1 % E drive
            prefix = 'E:\Data\';
            P.dir.wf = fullfile(prefix, 'WFrecordings'); % directory of widefield video recordings
            P.dir.bh = fullfile(prefix, 'VideoRecordings'); % directory of behavior video recordings
            P.dir.rg = fullfile(prefix, 'ReachGrasp'); % directory of behavior video recordings of reach and grasp task
            P.dir.bk = fullfile(prefix, 'WFrecordings\FakeSubject'); % directory of backup folderPath to store wf recordings with problem
    end

    P.dir.refImage = fullfile(P.folderParent, 'Utilities\RefImage'); % directory of reference images
    P.dir.regXy = fullfile(P.folderParent, 'Utilities\RegXy'); % directory of coordinate registration files

    P.dir.actMap.raw = fullfile(P.folderPath, 'ActMap\Raw'); % directory of activation maps: raw
    P.dir.actMap.reg = fullfile(P.folderPath, 'ActMap\Reg'); % directory of activation maps: registered
    P.dir.actMap.rawDiff = fullfile(P.folderPath, 'ActMap\RawDiff'); % directory of activation maps: raw difference
    P.dir.actMap.regDiff = fullfile(P.folderPath, 'ActMap\RegDiff'); % directory of activation maps: registered difference

    p.dir.actRoi.raw = fullfile(P.folderPath, 'ActRoi\Raw'); % directory of activation ROI: raw
    P.dir.actRoi.reg = fullfile(P.folderPath, 'ActRoi\Reg'); % directory of activation ROI: registered
    P.dir.actRoi.rawDiff = fullfile(P.folderPath, 'ActRoi\RawDiff'); % directory of activation ROI: raw difference
    P.dir.actRoi.regDiff = fullfile(P.folderPath, 'ActRoi\RegDiff'); % directory of activation ROI: registered difference

    P.path.abmTemplate = fullfile(P.folderParent, 'Utilities', 'ABMTemplate.tif'); % path of the template for allen mouse brain atlas
    P.path.roiMaskForAlignTrig = fullfile(P.folderParent, 'Utilities', 'roiMask.mat'); % path of the mask for ROI analysis

    P.gSheet.sessionNote = '1xbaLWzdmBQ-1Klv_2I2YOco51lpTwndMM7ZfOwqFW6c';
    P.gSheet.brainAtlasLabel = '1kVuDSObVCEI02XG_x6lCCY1mDkVIL1ZuYyk42iSWnGQ';

    %% parameters to select mouse, session, trial, stimulus generate trigger aligned movies

    % leave the parameters as empty will disable the selection

    % experiment type
    P.select.stimType.proprioception = 1; % passive movement session
    P.select.stimType.vibration = 0; % vibration session
    P.select.stimType.whisker = 0; % whisker session

    % animal to be analyses
    P.select.animal.proprioception = {'m1221', 'm1222', 'm1223', 'm1224'};
    P.select.animal.vibration = {};
    P.select.animal.whisker = {};

    % sessions to be analyses
    P.select.session.proprioception = [230202,230203,230206,230207,230208,230210,230310,230317,230324,230331,230406,230504];
    P.select.session.vibration = [];
    P.select.session.whisker = [];

    % trials to be analyses
    P.select.trial.proprioception.randomNtrial = 80; % [] to select all the trials
    P.select.trial.proprioception.ActionLessThanRandomNtrial = 'skip'; % sessions with trial number less than randomNtrial will be skiped
    P.select.trial.proprioception.outcome = [3, 4, 5];
    P.select.trial.proprioception.mvtDir = [1, 2, 3, 4, 5, 6, 7, 8]; % direction 1,2,...,8 seperately and all directions together

    % stimulus to be analyses
    P.select.stim = 1; % 1, first stimulus; 2, second stimulus

    %% parameters for WF trigger alignment
    P.wf.align.win = [-1, 1.5]; % window for alignment, relative to the trigger onset
    P.wf.frame.frq = 20; % frame rate of the WF video
    P.wf.frame.time = P.wf.align.win(1):1 / P.wf.frame.frq:P.wf.align.win(2); % time line of the aligned WF video   
    
    %% parameters for ACT analysis
    P.act.win.baseline = [-0.5, 0];

    %% flag parameters
    P.flag.align.reuseMask = 1; % 1, reuse the mask for alignment; 0, generate new mask for alignment
end
