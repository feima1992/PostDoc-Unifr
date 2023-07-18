% get current drive name
cpath = split(pwd,filesep);
% add Wfanalysis to the path
addpath(genpath([cpath{1},'\users\Fei\Code']));
% get parameters
p = RGA.GetParams();
% get session info table
sessionInfoTable = RGA.GetSessionInfo(p);
% filter session info table, sessionID >= 20230306
sessionInfoTable = sessionInfoTable(sessionInfoTable.sessionID >= 20230306,:);
% imageDate
imageDate = [20230310,20230317,20230324,20230331,20230406,20230503];
RGP.PlotTrialInfo(sessionInfoTable,{'r1221','r1222','r1223','r1224'},'imageDate',imageDate,'data','nTouch')
exportgraphics(gcf,'touch.png','resolution',300);close(gcf)
RGP.PlotTrialInfo(sessionInfoTable,{'r1221','r1222','r1223','r1224'},'imageDate',imageDate,'data','nTrialsCorrect')
exportgraphics(gcf,'trail.png','resolution',300);close(gcf)

RGP.PlotTrialInfo(sessionInfoTable,{'m1131','m1147','m1260'},'imageDate',[20230526,20230601],'data','nTouch')
RGP.PlotTrialInfo(sessionInfoTable,{'m1131','m1147','m1260'},'imageDate',[20230526,20230601],'data','nTrialsCorrect')