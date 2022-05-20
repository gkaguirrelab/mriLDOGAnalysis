% Compile results from Flywheel forwardModel analyses

% House keeping
clear
close all

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
    {'606f4e3a23a4b1585ea16b77'},{'61f8259d9c5e882ac6ff49da'},{'618eaf46cc13a7db50926d34'},...
    {'5fbc010f007a24bdb2631e2a'},{'6286a8a5eaaa26ce61027b0e'},{'5ffc9af3a2719d913b740e51'},...
    {'5fa5bbded20d5c2d63f359aa'},{'5fa9611917ddac02d6e32d8d'},{'5fb6c55208da2c5a2aa08e75'},...
    {'60146008afe25f7a6015acd6','609ac9b8267f663f4f609a9e'},{'604a6351e9a059778e89359b','60a6ad7839ca5ed906a2557f'},...
    {'611557d3c45699f4bee0f829'},{'6127e127999da0d2e6c708f4'},...
    };
nSessions = length(sessionIDs);

subjectNames = {...
    'N344','N347','N349',...
    '2350','2346','2356',...
    'Z663','Z665','Z666',...
    'EM529','EM543',...
    'EM529','EM543',...
    };

groupIdx = {[1 2 3],[4 5 6],[7 8 9],[10 11],[12 13]};
groupNames = {'WT','RCD1','XLPRA2','RHOT4R-pre','RHOT4R-post'};
groupColors = {[0.5 0.5 0.5],[0 0 1],[1 0 0],[0 0.5 0],[0 1 0]};
nGroups = length(groupNames);


jitterFactor = 0.1;
paramSets = {[1:6],[7:12],[13:18]};

% Some properties of the data and analyses
stimulusDirections = {'L+S','L-S','LF'};
nStimuli = length(stimulusDirections);
ROIs = {'antV1','postV1','LGN'};
nROIs = length(ROIs);
theModelUsed = 'mtSinai';
analysisIDs = [];

yLimVals = {...
    [-0.2 1],[-0.2,1],[-0.2 0.5];...
    [-0.2 1],[-0.2,1],[-0.2 0.5];...
    [-0.2 1],[-0.2,1],[-0.2 0.5]...
    };

% Obtain the list of mtSinai analysis IDs
for ss = 1:length(sessionIDs)
    for rr = 1:length(sessionIDs{ss})
        analysisList = fw.getSessionAnalyses(sessionIDs{ss}{rr});
        stillSearching = true(size(ROIs));
        idx = length(analysisList);
        while any(stillSearching)
            thisLabel = analysisList{idx}.label;
            roiMatches = cellfun(@(x) and(contains(thisLabel,x),contains(thisLabel,theModelUsed)),ROIs);
            if any(roiMatches)
                analysisIDs{ss,find(roiMatches)}{rr} = analysisList{idx}.id;
                stillSearching(find(roiMatches)) = false;
            end
            idx=idx-1;
            if idx==0
                error('Unable to find all of the analyses for this session')
            end
        end
    end
end

% Loop through the analaysis IDs, download the results file, store the
% forwardModel output
params=[];
for ss=1:nSessions
    thisParamSet = paramSets;
    for aa=1:length(ROIs)
        resultsFileName = [subjectNames{ss},'_',theModelUsed,'_results.mat'];
        saveLocation = fullfile(saveDir,resultsFileName);
        for rr=1:length(analysisIDs{ss,aa})
            fw.downloadOutputFromAnalysis(analysisIDs{ss,aa}{rr},resultsFileName,saveLocation);
            load(saveLocation,'results');
            voxelIdx = results.meta.vxs(1);
            if rr == 1
                params{ss,aa} = results.params(voxelIdx,1:18);
            else
                params{ss,aa} = [params{ss,aa}(:)' results.params(voxelIdx,1:18)];
                if aa==1
                    % THIS IS A HACK, AND WILL FAIL IF rr>2
                    thisParamSet = cellfun(@(x) [x x+18],thisParamSet,'UniformOutput',false);
                    if rr>2
                        error('You have encountered a hack. Need to fix this.')
                    end
                end
            end
        end
    end
    % Some of the analyses were required to enter a duplicate fMRI scan
    % if one was missing to allow the machinery to run. We detect these
    % duplicates here and account for this in the subsequent
    % calculation of param SEM. We consider any params that match at 10
    % decimal places to be a match.
    [C,ia,ic]= unique(round(params{ss,1},10));
    if length(C)<length(params{ss,1})
        idxToRemove = find(diff(ic)==0);
        for ii=1:length(idxToRemove)
            thisParamSet = cellfun(@(x) x(x~=idxToRemove(ii)),thisParamSet,'UniformOutput',false);
        end
        paramSetsBySession{ss} = thisParamSet;
        warning('Duplicate param in session %d',ss)
    end
    paramSetsBySession{ss} = thisParamSet;
end

% Extract the data from the params
dataMeans = []; dataSEMS = [];
for ss=1:nSessions
    for aa=1:nROIs
        dataMeans(ss,(aa-1)*nROIs+1:aa*nROIs) = [mean(params{ss,aa}(paramSetsBySession{ss}{1})), mean(params{ss,aa}(paramSetsBySession{ss}{2})), mean(params{ss,aa}(paramSetsBySession{ss}{3})) ];
        dataSEMs(ss,(aa-1)*nROIs+1:aa*nROIs) = [std(params{ss,aa}(paramSetsBySession{ss}{1}))/sqrt(length(paramSetsBySession{ss}{1})), std(params{ss,aa}(paramSetsBySession{ss}{2}))/sqrt(length(paramSetsBySession{ss}{2})), std(params{ss,aa}(paramSetsBySession{ss}{3}))/sqrt(length(paramSetsBySession{ss}{3})) ];
    end
end
% Variable names for the table
varNames =[];
for xx=1:length(ROIs)
    for yy=1:length(stimulusDirections)
        varNames{end+1}=[ROIs{xx} '_' stimulusDirections{yy}];
    end
end

% Create a figure that summarizes the results
figure
for xx=1:nGroups
    for yy=1:nStimuli
        for zz=1:nROIs
            plotIdx = (yy-1)*nStimuli+zz;
            subplot(nStimuli,nROIs,plotIdx);
            rowIdx = groupIdx{xx};
            for ss=1:length(rowIdx)
                thisMean = dataMeans(rowIdx(ss),(zz-1)*nROIs+yy);
                thisSEM = dataSEMs(rowIdx(ss),(zz-1)*nROIs+yy);
                if strcmp(ROIs(zz),'LGN')
                    thisMean = -thisMean;
                end
                plot(xx+(ss-1)*jitterFactor,thisMean,'o','MarkerEdgeColor','k','MarkerFaceColor',groupColors{xx});
                hold on
                plot([xx+(ss-1)*jitterFactor xx+(ss-1)*jitterFactor],[thisMean-thisSEM,thisMean+thisSEM],'-','Color',groupColors{xx});
            end
            plot([0.5 nGroups+0.5],[0 0],':k')
            xticks([1:nGroups]);
            xticklabels(groupNames);
            title([ROIs{zz} '.' stimulusDirections{yy}])
            xlim([0.5,nGroups+0.5]);
            ylim(yLimVals{yy,zz});
            ylabel('BOLD response [%d]')
        end
    end
end

% Create a table that summarizes the data
dataStr=[];
T=[];
for xx=1:size(dataMeans,1)
    for yy=1:size(dataMeans,2)
        dataStr{xx,yy} = sprintf('%2.2f ± %2.2f',dataMeans(xx,yy),dataSEMs(xx,yy));
    end
end
T = array2table(string(dataStr));

% Row names combine subject name and group
rowName = [];
for ss=1:nSessions
    rowName{ss} = [subjectNames{ss} '_' groupNames{cellfun(@(x) any(x==ss),groupIdx)}];
end
T.Properties.RowNames = rowName;
T.Properties.VariableNames = varNames;

