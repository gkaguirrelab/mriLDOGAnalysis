% Compile results from Flywheel forwardModel analyses


%% Variable declaration
scratchSaveDir = tempdir;

% Create the functional tmp save dir if it does not exist
saveDir = fullfile(scratchSaveDir,'mriLDOGSAnalysis');
if ~exist(saveDir,'dir')
    mkdir(saveDir);
end

%% Open the flywheel object
fw = flywheel.Flywheel(getpref('flywheelMRSupport','flywheelAPIKey'));

% project ID
projectID = '5bb4ade9e849c300150d0d99';

% session IDs
sessionIDs = {...
    '606f4e3a23a4b1585ea16b77','61f8259d9c5e882ac6ff49da','618eaf46cc13a7db50926d34',...
    '5fbc010f007a24bdb2631e2a','5ff8a949a8232b19464b0926','5ffc9af3a2719d913b740e51',...
    '5fa5bbded20d5c2d63f359aa','5fa9611917ddac02d6e32d8d','5fb6c55208da2c5a2aa08e75',...
    };

subjectNames = {...
    'N344','N347','N349',...
    '2350','2353','2356',...
    'Z663','Z665','Z666',...
    };

% Some properties of the data and analyses
stimulusDirections = {'L+S','L-S','LF'};
ROIs = {'antV1','postV1','LGN'};
theModelUsed = 'mtSinai';
analysisIDs = [];

% Obtain the list of mtSinai analysis IDs
for ss = 1:length(sessionIDs)
    analysisList = fw.getSessionAnalyses(sessionIDs{ss});
    stillSearching = true(size(ROIs));
    idx = length(analysisList);
    while any(stillSearching)
        thisLabel = analysisList{idx}.label;
        roiMatches = cellfun(@(x) and(contains(thisLabel,x),contains(thisLabel,theModelUsed)),ROIs);
        if any(roiMatches)
            analysisIDs{ss,find(roiMatches)} = analysisList{idx}.id;
            stillSearching(find(roiMatches)) = false;
        end
        idx=idx-1;
        if idx==0
            error('Unable to find all of the analyses for this session')
        end
    end
end

% Loop through the analaysis IDs, download the results file, store the
% forwardModel output
params=[];
for ss=1:length(sessionIDs)
    for aa=1:length(ROIs)
        resultsFileName = [subjectNames{ss},'_',theModelUsed,'_results.mat'];
        saveLocation = fullfile(saveDir,resultsFileName);
        fw.downloadOutputFromAnalysis(analysisIDs{ss,aa},resultsFileName,saveLocation);
        load(saveLocation,'results');
        voxelIdx = results.meta.vxs(1);
        params{ss,aa} = results.params(voxelIdx,1:18);
    end
end

% Extract the data from the params
dataMeans = cell2mat(cellfun(@(x) [mean(x(1:6)),mean(x(7:12)),mean(x(13:18))],params,'UniformOutput',false));
dataSEMs = cell2mat(cellfun(@(x) [std(x(1:6))/sqrt(6),std(x(7:12))/sqrt(6),std(x(13:18))/sqrt(6)],params,'UniformOutput',false));

% Variable names for the table
varNames =[];
for xx=1:length(ROIs)
    for yy=1:length(stimulusDirections)
        varNames{end+1}=[ROIs{xx} '_' stimulusDirections{yy}];
    end
end

% Create a table that summarizes the data
for xx=1:size(dataMeans,1)
    for yy=1:size(dataMeans,2)
        dataStr{xx,yy} = sprintf('%2.2f ± %2.2f',dataMeans(xx,yy),dataSEMs(xx,yy));
    end
end
T = array2table(string(dataStr));
T.Properties.RowNames = subjectNames;
T.Properties.VariableNames = varNames;

