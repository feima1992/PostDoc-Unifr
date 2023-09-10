function [subTables, group] = splitTable(aTable,groupVars)
% splitTable splits a table into a cell array of tables based on the group variables
% aTable is the table to be split
% groupVars is a string or cell array of strings of the variables to group by

% parser inputs
p = inputParser;
p.addRequired('aTable',@istable);
p.addRequired('groupVars',@(x) ischar(x) || iscellstr(x));
p.parse(aTable,groupVars);
aTable = p.Results.aTable;
groupVars = p.Results.groupVars;

% find groups
[groupIdx,group] = findgroups(aTable(:,groupVars));

subTables = cell(1,height(group));

for i = 1:height(group)
    subTables{i} = aTable(groupIdx == i,:);
end