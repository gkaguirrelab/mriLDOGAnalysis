% Housekeeping 
clear all; clc;

% Path to the dropbox files 
dropboxBaseDir = 'C:/Users/ozenc/Aguirre-Brainard Lab Dropbox/Ozenc Taskin';
dataSource = fullfile(dropboxBaseDir,'LDOG_data','Experiments','OLApproach_TrialSequenceMR');

% Initiate subjects and session cells 
subjects = {};
sessions = {};

% List of MRI subejcts we want to analyze and dates
% WM67 is the gene therapy animal
% We exclude 2356 from the list as we are not using the data in the paper.
subjects{1} = {'2346', '2350', '2353', ...
               'N344', 'N347', 'N349', ...
               'Z663', 'Z665', 'Z666', 'Z710', 'Z709', ...
               'WM65', 'AS2454', 'AS2451', ...
               'WM67'};
sessions{1} = {'2022-05-19', '2020-11-23', '2021-01-08', ...
               '2021-04-08', '2022-01-31', '2021-11-12', ...
               '2020-11-06', '2020-11-06', '2020-11-19', '2023-01-04', '2023-01-05', ...
               '2022-09-09', '2023-03-30', '2023-04-19', ...
               '2022-11-29'};   

% List of pupillometry subjects we want to analyze
% We remote N347 as we are not using the data for that subject 
subjects{2} = {'2350', '2353', '2356', 'N344', 'N349', ...
               'Z663', 'Z665', 'Z666'};
sessions{2} = {'2020-12-11', '2020-10-20', '2020-12-11', ...
               '2020-10-14', '2021-08-24', '2020-08-20', '2020-10-14', ...
               '2020-12-11'};

% Empty struct for subject results. This will contain in order; mean 
% luminance, irradiance, and contrast (which includes pos and neg arms). 
subjectMRIResults = {};
subjectPupilResults = {};           

% Loop through experiments (MRI and pupil)
for ii = 1:length(subjects)
    
    % Specify some general names we will use to save files
    if isequal(ii, 1)
        experiment = 'MRI';
        dataFolder = 'MRFlickerLDOG'; 
    elseif isequal(ii,2)
        experiment = 'Pupil';
        dataFolder = 'MRScotoLDOG';
    end
    
    % Get subject and session list 
    subjectList = subjects{ii}; 
    sessionList = sessions{ii};
    
    % Now loop through each subject in the experiment 
    for ss = 1:length(subjectList)
        % Get path to the direction object
        directionFile = fullfile(dataSource, dataFolder, 'DirectionObjects', ...
                                 subjectList{ss}, sessionList{ss}, ... 
                                 'directionObject.mat');
        
        % Save subject and session labels so we don't keep refereing to the
        % cell. Load the direction file. 
        subjectName = subjectList{ss};
        subjectDate = sessionList{ss}; 
        fprintf(['Processing ' subjectName ' for ' dataFolder '\n'])
        load(directionFile)
        
        % Put all directions in a cell so we can loop through them 
        allDirections = {};
        allDirections{1} = LightFluxDirection;
        allDirections{2} = LminusSDirection;
        allDirections{3} = LplusSDirection;
        allDirections{4} = RodMelDirection;
        directionNames = {'LightFlux', 'LminusS', 'LplusS', 'RodMel'};
        
        % Using the light flux direction SPD error, decide whether a
        % validation was performed or not. If a validaiton was not
        % performed, the OneLight script still enters the expected values.
        % We get rid of these here so that they don't go into the summary.
        indicesToDrop = [];
        for tt = 1:length(LightFluxDirection.describe.validation)
            if isequal(mean(LightFluxDirection.describe.validation(tt).SPDcombined(1).error), 0) 
                indicesToDrop = [indicesToDrop tt];
            end
        end        
        
        % If the length of the indices to remove is equal to length of the
        % entire validation, that means we don't have any validation
        % performed for that subject. Skip the rest of the loop.
        if isequal(length(indicesToDrop), length(LightFluxDirection.describe.validation))
            warning(['Skipping ' subjectName ' because it has no validation performed'])
            continue
        end
        
        % We will concatanate luminance of all modulations first, then we
        % will calculate irradiance for each luminance, then average both 
        % luminance and irradiance to get a mean for each subject.
        % Initialize the luminance vector 
        subjectLuminance = [];
        subjectIrradiance = [];        
        
        % We also get an empty contrast vector 
        subjectContrast = {};
        
        % Loop through directions save a large luminance-contrast vectors
        for mm = 1:length(allDirections)
            % If there are validations to drop, drop them.
            if ~isempty(indicesToDrop)
                allDirections{mm}.describe.validation(indicesToDrop) = [];
            end
            
            % Get the luminance values and add that to the subjectLuminance
            % vector
            allLuminances = vertcat(allDirections{mm}.describe.validation.luminanceActual);
            allLuminances = allLuminances(:,1);
            subjectLuminance = [subjectLuminance; allLuminances];        
            
            % Get the contrast values and add that to the subjectContrast
            % vector
            allContrasts = vertcat(allDirections{mm}.describe.validation.contrastActual);
            
            % Average positive and negative arms and concatanate
            allContrasts = (allContrasts(:,1) + -1*allContrasts(:,2))/2;
           
            % Separate the entire concatanated contrast values into their
            % photoreceptor classes. There will be 4 groups for Lcone, Scone,
            % Mel, and Rod
            classes = LightFluxDirection.describe.directionParams.photoreceptorClasses;
            numClasses = length(classes);
            groupedContrasts = cell(numClasses, 1);
            for classnum = 1:numel(allContrasts)
                groupIndex = mod(classnum - 1, numClasses) + 1;
                groupedContrasts{groupIndex} = [groupedContrasts{groupIndex}, allContrasts(classnum)];
            end
            
            % Add LplusS and LminusS in that order
            groupedContrasts{numClasses+1} = (groupedContrasts{1} + groupedContrasts{2})/2;
            groupedContrasts{numClasses+2} = (groupedContrasts{1} - groupedContrasts{2})/2;
            
            % Average the vectors
            contrastAverages = cellfun(@(v) mean(v), groupedContrasts);
            
            subjectContrast{mm} = contrastAverages;
        end
        
        % Get the calibration file, loop through the subjectLuminance and
        % calculate the irradiance for each value
        calName = LightFluxDirection.calibration.describe.calType;
        calDate = LightFluxDirection.calibration.describe.date;
        calibrationFile = fullfile(dropboxBaseDir, 'LDOG_materials', ...
                                   'Experiments', 'OLApproach_TrialSequenceMR', ...
                                   'OneLightCalData', ['OL' calName]);
        load(calibrationFile)                       
        for cal = 1:length(cals)
            if strcmp(cals{cal}.describe.calType, calName) && strcmp(cals{cal}.describe.date, calDate)
                calibrationIndex = cal;
            end
        end
        
        for lum = 1:length(subjectLuminance)
            irradiance = calculateIrradiance(subjectLuminance(lum), calibrationFile, calibrationIndex);
            subjectIrradiance = [subjectIrradiance; irradiance];
        end
    
    % Save averages to a main cell
    if isequal(ii,1)
        subjectMRIResults{ss,1} = subjectName;
        subjectMRIResults{ss,2} = mean(subjectLuminance);
        subjectMRIResults{ss,3} = mean(subjectIrradiance);
        subjectMRIResults{ss,4} = subjectContrast;
    elseif isequal(ii,2)
        subjectPupilResults{ss,1} = subjectName;
        subjectPupilResults{ss,2} = mean(subjectLuminance);
        subjectPupilResults{ss,3} = mean(subjectIrradiance);
        subjectPupilResults{ss,4} = subjectContrast;        
    end    
    end          
end