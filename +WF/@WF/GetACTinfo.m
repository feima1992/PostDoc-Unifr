function GetACTinfo(obj)
% find all the ACT files in the analysis folder
actFiles = WF.Helper.FindFiles(obj.p.folder,{'.mat','_ACT'},{},'table_out',true);

% functions to extract information from the file folder or name
FindMouse = @(X)regexp(X,'[a-zA-Z]\d{4}(?=_)','match','once');
FindSession = @(X)regexp(X,'(?<=_)2[3-9][0-1][0-9][0-3][0-9](?=_)','match','once');
FindMvtDir = @(X)fillmissing(str2double(regexp(X,'(?<=MvtDir)\d{1}(?=\\)','match','once')),'constant',0);

% extract information from the file name
actFiles.mouse = FindMouse(actFiles.name);
actFiles.mouseID =  cellfun(@(X)str2double(X(2:end)),actFiles.mouse);
actFiles.session = FindSession(actFiles.name);
actFiles.sessionID = cellfun(@(X)str2double(X),actFiles.session);

% extract information from the file folder
actFiles.mvtDir = FindMvtDir(actFiles.folder);

% load group information
groupInfo = WF.Helper.ReadGoogleSheet(obj.p.sheet.wrongTrials);
groupInfo.mosueID = cellfun(@(X)str2double(X(2:end)),groupInfo.mouse);

% join the two tables, actFiles as base, with left join
actFiles = outerjoin(actFiles,groupInfo,'Keys',{'mouse','mouseID','sessionID'},'MergeKeys',true,'Type','left');
% clean up the table to keep only the relevant columns
actFiles = actFiles(:,{'mouse','session','mouseID','sessionID','sessionNumID','group','treatment','treatmentID','mvtDir','path'});
% 
end