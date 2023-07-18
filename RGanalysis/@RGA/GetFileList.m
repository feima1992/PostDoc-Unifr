%% GetFileList
function fileList = GetFileList(target)
% getFileList: get the file list for the target
% target: target to get the file list for
% fileList: cell array with the file list
p = RGA.GetParams();
switch target
    case 'BpodRG'
        % get the file list for the ABM template
        fileList = F.FindFiles(p.dir.session,{'LimbReachGrasp','Session Data','mat'},{'Fake'});
    otherwise
        error('Unknown target');
end
end