%% Set up these parameters for the session

% Subject and session params.
pathParams.Subject = 'EM426';
pathParams.Date = '2020-03-12';
pathParams.Session = '';

% The approach and protocol. These shouldn't change much
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'MRScotoLDOG';

% What to plot
validationNumber = 'median';
whatToPlot = 'noSPD';

results = visualizeValidation(pathParams, 'validationNumber', validationNumber, 'whatToPlot', whatToPlot);
