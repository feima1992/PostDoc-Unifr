function Progress(c,t,info)
    % Progress indicator for long loops, inplace displays percentage
    % c: current iteration
    % t: total iterations
    % info: additional info to display
    
    % validate input
    arguments
        c (1,1) double
        t (1,1) double
        info (1,1) string = "Progress"
    end
    persistent last_line_length;
    
    % calculate percentage
    p = round(c/t*100);

    % calculate time
    if c > 1
        t_elapsed = toc;
        t_remaining = t_elapsed/c*(t-c);
        t_remaining = seconds(round(t_remaining));
        t_elapsed = seconds(round(t_elapsed));
    else
        t_elapsed = seconds(0);
        t_remaining = seconds(0);
        tic;
    end

    % display c == 1
    if c == 1
        % add newline
        % fprintf("\n");
        % display
        last_line_length = fprintf("%s: %d%%, %d/%d, %s elapsed, %s remaining",info,p,c,t,t_elapsed,t_remaining);
    end
    % update display
    if c > 1
        % remove last line
        fprintf(repmat('\b',1,last_line_length));
        % display
        last_line_length = fprintf("%s: %d%%, %d/%d, %s elapsed, %s remaining",info,p,c,t,t_elapsed,t_remaining);
    end
    % display c == t
    if c == t
        % remove last line
        fprintf(repmat('\b',1,last_line_length));
        % display finished
        fprintf("%s: Finished\n",info);
        % delete persistent variable
        clear last_line_length;
    end

end