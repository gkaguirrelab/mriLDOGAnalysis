% genStimFile_M662_maxFlicker_LeftAndRight.m
%
% This routine produces output needed to conduct forwardModel analyses of
% the LDOG photoFlicker MRI experiments. We analyze the data using the
% "mtSinai" model. In addition to a stimulus.mat file, the model takes
% these components as input:
%
%   stimLabels    - A cell array of char vectors, one for each row of the
%                   stimulus matrix.
%   avgAcqIdx     - A cell array of vectors, all of the same length, with a
%                   total length equal to the length of the data. This
%                   vector controls how the data and model time-series from
%                   various acquisitions may be averaged together. Consider
%                   an experiment that has 6 acquisitions of length 100,
%                   consisting of 3 repetitions of the same stimulus
%                   sequence (with each sequence split over two
%                   acquisitions). To average these time-series together,
%                   one would pass {[1:200],[201:400],[401:600]};
%
% The goal is to conduct an "omnibus" analysis of all data collected for a
% given test subject, fit a custom HRF at each voxel, and extract the
% amplitude associated with each acquisition.
% 
% This particular script is used to create the stim file and stimLabels to
% analyze the data collected from M662 with alternating left and right eye
% stimulation over three separate sessions.
%

% The basic temporal structure of the experiment is 12 second on, 12 second
% off blocks. Data was acquired with a TR = 3 seconds. There were 18
% blocks, for a total acquisition length of 144 TRs.
blockLength = 8;  % In TRs
nBlocks = 14;
nTRsPerAcq = nBlocks*blockLength;

% The stimulus structure, however, is constructed according to the order in
% which the acquisitions are provided to the forwardModel. Because the
% different photoreceptor directions are grouped into different FIX
% analysis outputs, the stimLabels reflect this ordering.

stimLabels = {...
    'rightEye_01','rightEye_02','rightEye_03','rightEye_04','rightEye_05','rightEye_06','rightEye_07','rightEye_08',... % foveaLocalizer 1_2
    'rightEye_09','rightEye_10','rightEye_11','rightEye_12',...                                                         % foveaLocalizer 2_1
    'rightEye_13','rightEye_14','rightEye_15','rightEye_16','rightEye_17','rightEye_18','rightEye_19','rightEye_20',... % foveaLocalizer 3_1
    'leftEye_01','leftEye_02','leftEye_03','leftEye_04','leftEye_05','leftEye_06','leftEye_07','leftEye_08',...         % foveaLocalizer 1_1
    'leftEye_09','leftEye_10','leftEye_11','leftEye_12','leftEye_13','leftEye_14','leftEye_15','leftEye_16',...         % foveaLocalizer 2_1
    'leftEye_17','leftEye_18','leftEye_19','leftEye_20','leftEye_21','leftEye_22','leftEye_23','leftEye_24',...         % foveaLocalizer 3_1
    };

avgGuide = {[1,21],[2,22],[3,23],[4,24],[5,25],[6,26],[7,27],[8,28],... % session 1_1 and 1_2
    [9,29],[10,30],[11,31],[12,32],...                                  % session 2_1, first four acquisitions that have paired left and right
    [33,34],[35,36],...                                                 % session 2_1, last four left eye stims, paired together as a hack
    [13,37],[14,38],[15,39],[16,40],[17,41],[18,42],[19,43],[20,44]};   % session 3_1

nAcq = length(stimLabels);

% We set the "on" stimulus period to 0, and the "off" period to "1". 
% This is to account for the inversion of the cortical BOLD fMRI response
% with 100% 02 ventilation. The analysis is constrained to have a positive
% HRF, so this arrangement causes the cortex to have a positive response to
% stimulation.
stimVector = zeros(1,nTRsPerAcq);
for ii=1:nBlocks
    stimVector(1,(ii-1)*blockLength+5:(ii-1)*blockLength+8) = 1;
end

% Assemble the cell array of stimulus matrices
fullMatrix = zeros(nAcq,nTRsPerAcq);
stimulus = {};
for ii=1:nAcq
    thisMatrix = fullMatrix;
    thisMatrix(ii,:) = stimVector;
    stimulus{ii} = thisMatrix;
end

% Save the stimulus file to a tmp location
fileName = fullfile(tempdir,'stimFile_M662_maxFlicker_LeftAndRight.mat');
save(fileName,'stimulus');

% Instantiate the flywheel object
projectName = 'flywheelMRSupport';
fw = flywheel.Flywheel(getpref(projectName,'flywheelAPIKey'));

% Initiate the modelOpts text string
modelOpts = '(polyDeg),10,(stimLabels),{ ';

% Add in the stimulus labels
for ii=1:length(stimLabels)
    modelOpts = [modelOpts ['(' stimLabels{ii} '),']];
end

% Remove trailing comma  and cap with bracket
modelOpts = [modelOpts(1:end-1) ' },' ];

% Create and add the avgAcqIdx. Average over eyes and acquisitions to
% show time-series for a given photoreceptor direction. This output is in
% the form of text that can be supplied to the forwardModelWrapper
modelOpts = [modelOpts '(avgAcqIdx),{ '];
for ii = 1:length(avgGuide)
    thisVector = [];
    thisSet = arrayfun(@(thisIdx) [(thisIdx-1)*nTRsPerAcq+1 thisIdx*nTRsPerAcq],avgGuide{ii},'UniformOutput',false);
    thisSet = cell2mat(thisSet);    
    modelOpts = [modelOpts sprintf('[%d:%d,%d:%d],',thisSet)];
end

% Remove trailing comma  and cap with bracket
modelOpts = [modelOpts(1:end-1) ' }\n' ];

% Report the modelOpts
fprintf('modelOpts for this design: \n\n')
fprintf(modelOpts);

