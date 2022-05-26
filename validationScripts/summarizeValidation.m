clear all

dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');
experiment = {'MRFlickerLDOG', 'MRScotoLDOG'};

for ii = 1:length(experiment)
    experimentName = experiment{ii};
    dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing/Experiments/OLApproach_TrialSequenceMR', experimentName, 'ValidationSummary');

    directory = dir(dataOutputDirRoot);
    directory(1:2,:) = [];

    modulations = {'LightFluxDirection', 'LminusSDirection', 'LplusSDirection', 'RodMelDirection'};
    for mod = 1:length(modulations)

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
        table = table(Names',Sessions',preLuminance',postLuminance',preLConeNegative',preLConePositive',...
                      postLConeNegative',postLConePositive',preSConeNegative',preSConePositive', ...
                      postSConeNegative',postSConePositive',preMelNegative',preMelPositive', ...
                      postMelNegative',postMelPositive',preRodNegative',preRodPositive', ...
                      postRodNegative', postRodPositive');
        table.Properties.VariableNames = {'Names','Sessions','preLuminance','postLuminance','preLConeNegative','preLConePositive',...
                      'postLConeNegative','postLConePositive','preSConeNegative','preSConePositive', ...
                      'postSConeNegative','postSConePositive','preMelNegative','preMelPositive', ...
                      'postMelNegative','postMelPositive','preRodNegative','preRodPositive', ...
                      'postRodNegative', 'postRodPositive'};
        writetable(table, fullfile(dataOutputDirRoot, [modulations{mod} '.xls']));
        clear table
    end
end