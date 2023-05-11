%% Set up for fmri sessions

% NOTE: N344 session one does not have any validation. Not including it in
% this one. The session date, 2021-03-18

% Subject list
subjects = {'2346', '2350', '2353', '2356', ...
            'EM529', 'EM529', 'EM529', 'EM543', 'EM543', 'EM543', ...
            'N344', 'N347', 'N349', ...
            'Z663', 'Z665', 'Z666', 'Z710', 'Z709', ...
            'WM65', 'AS2454', 'AS2451'};

sessionDates = {'2022-05-19', '2020-11-23', '2021-01-08', '2021-01-11', ...
                '2021-01-29', '2021-05-11', '2021-08-12', '2021-03-11', '2021-05-20', '2021-08-26', ...
                '2021-04-08', '2022-01-31', '2021-11-12', ...
                '2020-11-06', '2020-11-06', '2020-11-19', '2023-01-04', '2023-01-05', ...
                '2022-09-09', '2023-03-30', '2023-04-19'};

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

%% Set up for pupil sessions

% NOTE: Neither EM529 ses do not have any validation. Removing them from the 
% average. Session dates 2020-10-15, 2021-08-24
% First session of EM543 does not have validation either, 2020-10-15
% 2356 doesn't either 2020-12-11
% Z665 doesn't either 2020-10-14
% Z666 either 2020-12-11

% Subject list
subjects = {'AS2-430', 'EM522', 'EM526', ...
            'EM543', 'N344', 'N347', 'N349', ...
            '2350', '2353', 'Z663'};

sessionDates = {'2020-10-15', '2020-06-30', '2020-06-30', ...
                '2021-08-24', '2020-10-14', '2020-08-21', '2021-08-24', ...
                '2020-12-11', '2020-10-20', '2020-08-20'};
            
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
    pathParams.Protocol = 'MRScotoLDOG';

    results = visualizeValidation(pathParams, 'validationNumber', validationNumber, 'whatToPlot', whatToPlot);

end            