function p = parameters(folderName)
%% p = parameters(createFolder), parameters for proprioception plasticity analysis
% OUTPUT:
% p: structure containing all the parameters for the analysis
arguments
    folderName(1,:) char = ['WF',datestr(now,'yyyymmdd')]; % folder name of the analysis
end
%% generate parameters structure
p = struct(); % create a structure to hold parameters

% data folder of the analysis
p.note = 'Basic parameters for WF analysis';

% determine the user directory so the script can be run on any computer
fullPath = mfilename('fullpath');

% take the first 2 levels of the full path as the user directory
fullPath = strsplit(fullPath, '\');
p.folder = fullfile(fullPath{1:3},'DataAnalysis',folderName);

%% parameters for data directory and file path
% directory where the bpod data is located
p.dir.bp = fullfile(fullPath{1:3},'Bpod\Bpod Local\Data\'); % directory of bpod data

% on which hard drive the widefield and behavior videos are stored
hardDrive = 1;
switch hardDrive
    case 0 % D drive
        prefix = 'D:\Data\';
        p.dir.wf = fullfile(prefix,'WFrecordings'); % directory of widefield video recordings
        p.dir.bh = fullfile(prefix,'VideoRecordings'); % directory of behavior video recordings
        p.dir.rg = fullfile(prefix,'ReachGrasp'); % directory of behavior video recordings of reach and grasp task
        p.dir.bk = fullfile(prefix,'WFrecordings\FakeSubject'); % directory of backup folder to store wf recordings with problem
    case 1 % E drive
        prefix = 'E:\Data\';
        p.dir.wf = fullfile(prefix,'WFrecordings'); % directory of widefield video recordings
        p.dir.bh = fullfile(prefix,'VideoRecordings'); % directory of behavior video recordings
        p.dir.rg = fullfile(prefix,'ReachGrasp'); % directory of behavior video recordings of reach and grasp task
        p.dir.bk = fullfile(prefix,'WFrecordings\FakeSubject'); % directory of backup folder to store wf recordings with problem
end

p.dir.refImages = fullfile(p.folder,'REFimages'); % directory of reference images
p.dir.ACTmaps = fullfile(p.folder,'ACTmaps'); % directory of activation maps
p.dir.ACTreg = fullfile(p.folder,'ACTreg'); % directory of activation maps after registration
p.dir.regXYs = fullfile(p.folder,'RegXYs'); % directory of coordinate registration files

p.dir.ACTdiff = fullfile(p.folder,'ACTdiff');% directory of difference in activation map

p.path.ABMtemplate = fullfile(fullPath{1:3},'Code','+WF','Utilities','ABMtemplate.tif'); % path of the template for allen mouse brain atlas
p.path.ROImask = fullfile(fullPath{1:3},'Code','+WF','Utilities','roiMask.mat'); % path of the mask for ROI analysis

p.sheet.wrongTrials = '1xbaLWzdmBQ-1Klv_2I2YOco51lpTwndMM7ZfOwqFW6c';
%% parameters to select mouse, session, trial, stimulus generate trigger aligned movies
% leave the parameters as empty will disable the selection

% experiment type
p.select.stimType.proprioception = 1; % passive movement session
p.select.stimType.vibration = 0; % vibration session
p.select.stimType.whisker = 0; % whisker session

% animal to be analysed
p.select.animal.proprioception = {};
p.select.animal.vibration = {};
p.select.animal.whisker = {};

% sessions to be analysed
p.select.session.proprioception = [];
p.select.session.vibration = [];
p.select.session.whisker = [];

% trials to be analysed
p.select.trial.proprioception.randomNtrial = []; % [] to select all the trials
p.select.trial.proprioception.randomNtrialLessThan = 'skip'; % sessions with trial number less than randomNtrial will be skiped
p.select.trial.proprioception.outcome = [3,4,5];
p.select.trial.proprioception.moveDirection = [1,2,3,4,5,6,7,8];

% stimulus to be analysed
p.select.stim = 1; % 1, first stimulus; 2, second stimulus

% parameters for WF trigger alignment
p.wf.win.align = [-1,1.5]; % window for alignment, relative to the trigger onset
p.wf.frq = 20; % frame rate of the WF video

%% parameters for ACT analysis
p.act.win.baseline = [-0.5,0];
p.act.flag.reuseMask = 1; % reuse the mask from the previous analysis
end
