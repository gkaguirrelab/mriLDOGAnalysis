% This script makes validation tables from the folders in LDOG_processing
% which are created by the visualizeValidation.m script.
clear all

% Set warning
warning('Delete the csv files in LDOG processing if you already ran this script before or it will fail')

% Set dropbox path
dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');

% We want to get the validations for MRI and pupil sessions. The pupil 
% stimulus file sets path to MRScotoLDOG, so the sessions are in there
experiment = {'MRFlickerLDOG', 'MRScotoLDOG'};

% Loop through validation directionObjects and organize tables 
for ii = 1:length(experiment)
    
    % Set the output directory which will be the same as input directory
    experimentName = experiment{ii};
    dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing/Experiments/OLApproach_TrialSequenceMR', experimentName, 'ValidationSummary');

    % Find the folders in LDOG_processing
    directory = dir(dataOutputDirRoot);
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
        averageLCone = nanmean([(-1*preLConeNegative + preLConePositive)/2 (-1*postLConeNegative + postLConePositive)/2], 2);
        averageSCone = nanmean([(-1*preSConeNegative + preSConePositive)/2 (-1*postSConeNegative + postSConePositive)/2], 2);
        averageMel = nanmean([(-1*preMelNegative + preMelPositive)/2 (-1*postMelNegative + postMelPositive)/2], 2);        
        averageRod = nanmean([(-1*preRodNegative + preRodPositive)/2 (-1*postRodNegative + postRodPositive)/2], 2);          
        
        table = table(Names', Sessions', num2str(averageLum,'%.4f'), num2str(averageLCone,'%.4f'), num2str(averageSCone,'%.4f'), num2str(averageMel,'%.4f'), num2str(averageRod,'%.4f'));
        table.Properties.VariableNames = {'Names','Sessions','Average Luminance','Average Lcone', ...
                                          'Average Scone', 'Average Mel', 'Average Rod'};
        writetable(table, fullfile(dataOutputDirRoot, [modulations{mod} '.xls']));
        clear table
    end
end