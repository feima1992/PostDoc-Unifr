function expended = ExpendColumn(aTable,var)
% expend the table by converting each element of the var to a new row
% aTable: a table
% var: a variable name
% expended: the expended table
% example:
%   aTable = table([1;2;3],{'a';'b';'c'},{[1,2];[3,4];[5,6]},'VariableNames',{'A','B','C'})
%   expended = Expend(aTable,'C')
%   expended = table([1;1;2;2;3;3],{'a';'a';'b';'b';'c';'c'},{1;2;3;4;5;6},'VariableNames',{'A','B','C'})

% validate input
arguments
    aTable table
    var char
end
% check if the variable exists
if ~any(strcmp(aTable.Properties.VariableNames,var))
    error('The variable %s does not exist in the table',var)
end
% expend the table
expended = table();
for i = 1:height(aTable)
    cRow = aTable(i,:);
    % get the value of the variable
    cValue = cRow.(var){1};

    % expend the table
    for j = 1:length(cValue)
        cRow.(var) = cValue(j);
        expended = [expended;cRow];
    end
end
end

