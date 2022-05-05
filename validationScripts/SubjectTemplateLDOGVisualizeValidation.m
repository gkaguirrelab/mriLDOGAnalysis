%% Set up these parameters for the session

% Subject list
subjects = {'2350', '2353', '2353', '2356', '2356', ...
            'EM529', 'EM529', 'EM529', 'EM543', 'EM543', 'EM543', ...
            'N344', 'N344', 'N347', 'N349', ...
            'Z663', 'Z665', 'Z666', 'Z666'};

sessionDates = {'2020-11-23', '2020-11-23', '2021-01-08', '2020-11-19', '2021-01-11', ...
                '2021-01-29', '2021-05-11', '2021-08-12', '2021-03-11', '2021-05-20', '2021-08-26', ...
                '2021-03-18', '2021-04-08', '2022-01-31', '2021-11-12', ...
                '2020-11-06', '2020-11-06', '2020-11-19', '2020-12-11'};

% What to plot
validationNumber = 'median';
whatToPlot = 'noSPD';

for ii = 1:length(subjects)
        
    % Subject and session params.
    pathParams.Subject = subjects{ii};
    pathParams.Date = sessionDates{ii};
    pathParams.Session = '';

    % The approach and protocol. These shouldn't change much
    pathParams.Approach = 'OLApproach_TrialSequenceMR';
    pathParams.Protocol = 'MRFlickerLDOG';

    results = visualizeValidation(pathParams, 'validationNumber', validationNumber, 'whatToPlot', whatToPlot);

end