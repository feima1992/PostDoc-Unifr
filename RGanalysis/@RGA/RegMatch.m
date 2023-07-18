%% Regexpfunction collections
function Reg = RegMatch(strCell, patternID)
% RegMatch: match the strings in strCell with the regular
% strCell: cell array with the strings to match
% patternID: ID of the pattern to match, number
% Reg: cell array with the matches

% validate the input
arguments
    strCell
    patternID double
end

switch patternID
    case 1 % match mouse ID
        pattern = '[vmr]\d{4}';
    case 2 % match session ID
        pattern = '\d{8}';
end
% match the strings
Reg = regexp(strCell, pattern, 'match', 'once');
% convert to n*1 cell array
Reg = reshape(Reg, [], 1);
end