% This script makes validation tables from the folders in LDOG_processing
% which are created by the visualizeValidation.m script.
clear all; clc

% Set dropbox path
dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');

% We want to get the validations for MRI and pupil sessions. The pupil 
% stimulus file sets path to MRScotoLDOG, so the sessions are in there
experiment = {'MRFlickerLDOG', 'MRScotoLDOG'};

% Subject and sessions to include in the table. This includes both pupil 
% and fmri sessions
subjectsMRI = {'2346', '2350', '2356', 'N344', 'N347', 'N349', 'Z663', ...
               'Z665', 'Z666'};
sessionsMRI = {'2022-05-19', '2020-11-23', '2021-01-11', '2021-04-08', ...
               '2022-01-31', '2021-11-12', '2020-11-06', '2020-11-06', ...
               '2020-11-19'};
subjectsPupil = {'2350', '2353', '2356', 'N344', 'N349', ...
                 'Z663', 'Z665', 'Z666'};
sessionsPupil = {'2020-12-11', '2020-10-20', '2020-12-11', ...
                 '2020-10-14', '2021-08-24', '2020-08-20', '2020-10-14', ...
                 '2020-12-11'};

% Loop through validation directionObjects and organize tables 
for ee = 1:length(experiment)
    
    % Create a summary cells 
    summaryTable_postRecept = table;
    summaryTable_photoRecept = table;
    
    % Set the output directory which will be the same as input directory
    experimentName = experiment{ee};
    dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing/Experiments/OLApproach_TrialSequenceMR', experimentName, 'ValidationSummary');

    % Find the folders in LDOG_processing
    directory = dir(dataOutputDirRoot);
    directory = directory([directory(:).isdir]);
    directory(1:2,:) = [];

    % Set modulation names and initiate a loop
    modulations = {'LightFluxDirection', 'LminusSDirection', 'LplusSDirection', 'RodMelDirection'};
    for mod = 1:length(modulations)
    
        % Initiate empty cells for directions, names, etc.
        Names = {};
        Sessions = {};
        preLuminance = {};
        postLuminance = {};
        preLConeNegative = {};
        preLConePositive = {};    
        postLConeNegative = {};
        postLConePositive = {};    
        preSConeNegative = {};
        preSConePositive = {};
        postSConeNegative = {};
        postSConePositive = {};    
        preMelNegative = {};
        preMelPositive = {};    
        postMelNegative = {};
        postMelPositive = {};    
        preRodNegative = {};
        preRodPositive = {};
        postRodNegative = {};
        postRodPositive = {};

        % Loop through the data in direction objects and save measurements
        counter = 0;
        for ii = 1:length(directory)
            subjectName = directory(ii).name;
            subDirPath = fullfile(dataOutputDirRoot, subjectName);
            subDir = dir(subDirPath);
            subDir(1:2,:) = []; 
            for aa = 1:length(subDir)
                counter = counter + 1;
                folderName = subDir(aa).name;
                filePath = fullfile(dataOutputDirRoot, subjectName, folderName, 'summaryTable.mat');
                load(filePath)
                
                % If both subject and session names exist in the folder, 
                if strcmp(experiment{ee}, 'MRFlickerLDOG')
                    subjectList = subjectsMRI;
                    sessionList = sessionsMRI;
                elseif strcmp(experiment{ee}, 'MRScotoLDOG')
                    subjectList = subjectsPupil;
                    sessionList = sessionsPupil;
                end
                
                if any(strcmp(subjectList,subjectName)) 
                    index = find(contains(subjectList,subjectName));
                    if strcmp(sessionList{index}, folderName)
                        Names{end+1} = subjectName;
                        Sessions{end+1} = folderName;
                        preLuminance{end+1} = summary.(modulations{mod}).BackgroundLuminanceSummary{1,2};
                        postLuminance{end+1} = summary.(modulations{mod}).BackgroundLuminanceSummary{1,3};

                        preLConeNegative{end+1} = summary.(modulations{mod}).contrastSummaryTable{2,2}(1); 
                        preLConePositive{end+1} = summary.(modulations{mod}).contrastSummaryTable{1,2}(1); 
                        postLConeNegative{end+1} = summary.(modulations{mod}).contrastSummaryTable{2,3}(1); 
                        postLConePositive{end+1} = summary.(modulations{mod}).contrastSummaryTable{1,3}(1); 

                        preSConeNegative{end+1} = summary.(modulations{mod}).contrastSummaryTable{4,2}(1); 
                        preSConePositive{end+1} = summary.(modulations{mod}).contrastSummaryTable{3,2}(1); 
                        postSConeNegative{end+1} = summary.(modulations{mod}).contrastSummaryTable{4,3}(1);
                        postSConePositive{end+1} = summary.(modulations{mod}).contrastSummaryTable{3,3}(1);

                        preMelNegative{end+1} = summary.(modulations{mod}).contrastSummaryTable{6,2}(1);
                        preMelPositive{end+1} = summary.(modulations{mod}).contrastSummaryTable{5,2}(1);
                        postMelNegative{end+1} = summary.(modulations{mod}).contrastSummaryTable{6,3}(1);
                        postMelPositive{end+1} = summary.(modulations{mod}).contrastSummaryTable{5,3}(1);

                        preRodNegative{end+1} = summary.(modulations{mod}).contrastSummaryTable{8,2}(1);
                        preRodPositive{end+1} = summary.(modulations{mod}).contrastSummaryTable{7,2}(1);
                        postRodNegative{end+1} = summary.(modulations{mod}).contrastSummaryTable{8,3}(1);
                        postRodPositive{end+1} = summary.(modulations{mod}).contrastSummaryTable{7,3}(1);  
                    end
                end
            end
        end
        
        % Convert everything to mat
        preLuminance = cell2mat(preLuminance');
        postLuminance = cell2mat(postLuminance');
        preLConeNegative = cell2mat(preLConeNegative');
        preLConePositive = cell2mat(preLConePositive');
        postLConeNegative = cell2mat(postLConeNegative');
        postLConePositive = cell2mat(postLConePositive');
        preSConeNegative = cell2mat(preSConeNegative');
        preSConePositive = cell2mat(preSConePositive');
        postSConeNegative = cell2mat(postSConeNegative');
        postSConePositive = cell2mat(postSConePositive');
        preMelNegative = cell2mat(preMelNegative');     
        preMelPositive = cell2mat(preMelPositive');        
        postMelNegative = cell2mat(postMelNegative');
        postMelPositive = cell2mat(postMelPositive');       
        preRodNegative = cell2mat(preRodNegative');        
        preRodPositive = cell2mat(preRodPositive');
        postRodNegative = cell2mat(postRodNegative');        
        postRodPositive = cell2mat(postRodPositive');
        
        % Make zeros NaN
        preLuminance(preLuminance==0) = NaN;
        postLuminance(postLuminance==0) = NaN;
        preLConeNegative(preLConeNegative==0) = NaN;
        preLConePositive(preLConePositive==0) = NaN;
        postLConeNegative(postLConeNegative==0) = NaN;
        postLConePositive(postLConePositive==0) = NaN;
        preSConeNegative(preSConeNegative==0) = NaN;
        preSConePositive(preSConePositive==0) = NaN;
        postSConeNegative(postSConeNegative==0) = NaN;
        postSConePositive(postSConePositive==0) = NaN;
        preMelNegative(preMelNegative==0) = NaN;
        preMelPositive(preMelPositive==0) = NaN;
        postMelNegative(postMelNegative==0) = NaN;    
        postMelPositive(postMelPositive==0) = NaN;         
        preRodNegative(preRodNegative==0) = NaN;      
        preRodPositive(preRodPositive==0) = NaN;      
        postRodNegative(postRodNegative==0) = NaN;          
        postRodPositive(postRodPositive==0) = NaN;        
        
        % If a value repeats in a pre validation, this means we didn't do
        % a prevalidation. Find these and replace with NaN.
        % Find the repeating value first
        [uniqueA i j] = unique(preLuminance,'first');
        repeating = find(not(ismember(1:numel(preLuminance),i)));
        
        % Find the all occurrences of a number
        if ~isempty(repeating)
            valLoc = ismember(preLuminance, preLuminance(repeating(1)));
            indices = find(valLoc);
            preLuminance(indices) = NaN;
            preLConeNegative(indices) = NaN;
            preLConePositive(indices) = NaN;            
            preSConeNegative(indices) = NaN;
            preSConePositive(indices) = NaN;            
            preMelNegative(indices) = NaN;
            preMelPositive(indices) = NaN;            
            preRodNegative(indices) = NaN;            
            preRodPositive(indices) = NaN;          
        end
        
        % Average stuff
        averageLum = nanmean([preLuminance postLuminance], 2);
        averageLCone = nanmean([nanmean([-1*preLConeNegative preLConePositive], 2) nanmean([-1*postLConeNegative postLConePositive], 2)], 2);
        averageSCone = nanmean([nanmean([-1*preSConeNegative preSConePositive], 2) nanmean([-1*postSConeNegative postSConePositive], 2)], 2);
        averageMel = nanmean([nanmean([-1*preMelNegative preMelPositive], 2) nanmean([-1*postMelNegative postMelPositive], 2)], 2);      
        averageRod = nanmean([nanmean([-1*preRodNegative preRodPositive], 2) nanmean([-1*postRodNegative postRodPositive], 2)], 2);                
        
        table1 = table(Names', Sessions', num2str(averageLum,'%.4f'), num2str(averageLCone,'%.4f'), num2str(averageSCone,'%.4f'), num2str(averageMel,'%.4f'), num2str(averageRod,'%.4f'));
        table1.Properties.VariableNames = {'Names','Sessions','Average Luminance','Average Lcone', ...
                                          'Average Scone', 'Average Mel', 'Average Rod'};
        writetable(table1, fullfile(dataOutputDirRoot, [modulations{mod} '.xls']));
        
        % Average luminance
        luminanceVals{mod} = mean(averageLum);
        
        % Drop the bad subject and make a new table for stimulus types
        modulationName = modulations{mod};
        averageLplusS = (averageLCone + averageSCone)/2;
        averageLminusS = (averageLCone - averageSCone)/2;
        averageLplusSMean = mean(averageLplusS);
        averageLplusSSD = std(averageLplusS);
        averageLminusSMean = mean(averageLminusS);
        averageLminusSSD = std(averageLminusS); 
        averageMelMean = mean(averageMel);
        averageMelStd = std(averageMel);
        averageRodMean = mean(averageRod);
        averageRodStd = std(averageRod);
        
        table2 = table(convertCharsToStrings(modulationName), convertCharsToStrings(num2str(averageLplusSMean,'%.4f')), convertCharsToStrings(num2str(averageLplusSSD,'%.4f')), ...
                       convertCharsToStrings(num2str(averageLminusSMean,'%.4f')), convertCharsToStrings(num2str(averageLminusSSD,'%.4f')), ...
                       convertCharsToStrings(num2str(averageMelMean,'%.4f')), convertCharsToStrings(num2str(averageMelStd,'%.4f')), ...
                       convertCharsToStrings(num2str(averageRodMean,'%.4f')), convertCharsToStrings(num2str(averageRodStd,'%.4f')));
        table2.Properties.VariableNames = {'Modulation', 'LplusS Mean', 'LplusS SD', ...
                                           'LminusS Mean', 'LminusS SD', ...
                                           'Mel Mean', 'Mel SD', 'Rod Mean', 'Rod SD'};
        
        summaryTable_postRecept = [summaryTable_postRecept; table2];

        meanLcone = mean(averageLCone);
        stdLcone = std(averageLCone);
        meanScone = mean(averageSCone);
        stdScone = std(averageSCone);
        
        table3 = table(convertCharsToStrings(modulationName), convertCharsToStrings(num2str(meanLcone,'%.4f')), convertCharsToStrings(num2str(stdLcone,'%.4f')), ...
                       convertCharsToStrings(num2str(meanScone,'%.4f')), convertCharsToStrings(num2str(stdScone,'%.4f')), ...
                       convertCharsToStrings(num2str(averageMelMean,'%.4f')), convertCharsToStrings(num2str(averageMelStd,'%.4f')), ...
                       convertCharsToStrings(num2str(averageRodMean,'%.4f')), convertCharsToStrings(num2str(averageRodStd,'%.4f')));
        table3.Properties.VariableNames = {'Modulation', 'L Cone Mean', 'L Cone SD', ...
                                           'S Cone Mean', 'S Cone SD', ...
                                           'Mel Mean', 'Mel SD', 'Rod Mean', 'Rod SD'};
        
        summaryTable_photoRecept = [summaryTable_photoRecept; table3];
        
        clear table
    end
    luminanceTable = cell2table([modulations' luminanceVals']);
    luminanceTable.Properties.VariableNames = {'Modulation', 'Average Luminance'};
    writetable(luminanceTable, fullfile(dataOutputDirRoot, [experiment{ee}, '_averageLuminance.xls']));
    writetable(summaryTable_postRecept, fullfile(dataOutputDirRoot, [experiment{ee}, '_modulationSummary_postRecept.xls']));
    writetable(summaryTable_photoRecept, fullfile(dataOutputDirRoot, [experiment{ee}, '_modulationSummary_photoRecept.xls']));    
    clear summaryTable_postRecept
    clear summaryTable_photoRecept
end
