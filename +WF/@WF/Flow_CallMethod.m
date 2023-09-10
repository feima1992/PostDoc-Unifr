function Flow_CallMethod(obj, flow)

    % flow should be a n x 2 cell array, where n is the number of methods need to be called
    % first column is the method name, second column is the method parameters

    if ischar(flow) || isstring(flow)
        flow = {flow, []};
    elseif iscell(flow) && size(flow, 2) == 1
        flow = [flow, cell(size(flow))];
    elseif iscell(flow) && size(flow, 2) == 2
        flow = flow;
    else
        error('Wrong input format for flow.');
    end

    % eval the flow
    for i = 1:size(flow, 1)

        if isempty(flow{i, 2})
            funcN = flow{i, 1};

            if obj.MethodCall.Count(ismember(obj.MethodCall.Method, funcN)) == 0
                funcH = str2func(funcN);
                funcH(obj);
            end

        else
            funcN = flow{i, 1};

            if obj.MethodCall.Count(ismember(obj.MethodCall.Method, funcN)) == 0
                funcH = str2func(funcN);
                params = flow{i, 2};

                if iscell(params)
                    funcH(obj, params{:});
                else
                    funcH(obj, params);
                end

            end

        end

    end

end
