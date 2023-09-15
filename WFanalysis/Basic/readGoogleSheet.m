function result = readGoogleSheet(ocid)
    %% Read data from Google Sheet to Matlab table
    % ocid: Google Sheet ID, caracter vector
    % result: Matlab table

    % validate input
    arguments
        ocid (1, :) char
    end

    % create url
    url = ['https://docs.google.com/spreadsheets/d/', ocid, '/export?format=csv'];

    % read data
    try
        result = webread(url);
    catch ME
        error('Failed to download data from Google Sheet: %s', ME.message);
    end
end