% genPhotoFlickerStimFile_LFLeftVsRight.m
%
% This code was used to conduct an analysis of the Light Flux acquisitions
% from the photoFlicker studies. Specifically, the data from the three WT
% animals was combined, and the stimulus matrix designed to create a
% contrast between the left and right eye. The goal is to identify
% monocular regions of cortex that are driven more by one or the other
% eyes.
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
% amplitude associated with each acquisition (photoreceptor direction and
% eye).
%

% The basic temporal structure of the experiment is 12 second on, 12 second
% off blocks. Data was acquired with a TR = 3 seconds. There were 18
% blocks, for a total acquisition length of 144 TRs.
blockLength = 8;  % In TRs
nBlocks = 18;
nTRsPerAcq = nBlocks*blockLength;

% The stimulus structure, however, is constructed according to the order in
% which the acquisitions are provided to the forwardModel. Because the
% different photoreceptor directions are grouped into different FIX
% analysis outputs, the stimLabels reflect this ordering.

stimLabels = {...
    'N344_LF_rightEye_01','N344_LF_rightEye_02','N344_LF_rightEye_03',...
    'N344_LF_leftEye_01','N344_LF_leftEye_02','N344_LF-leftEye_03',...
    'N347_LF_rightEye_01','N347_LF_rightEye_02','N347_LF_rightEye_03',...
    'N347_LF_leftEye_01','N347_LF_leftEye_02','N347_LF-leftEye_03',...
    'N349_LF_rightEye_01','N349_LF_rightEye_02','N349_LF_rightEye_03',...
    'N349_LF_leftEye_01','N349_LF_leftEye_02','N349_LF-leftEye_03',...
    };

nAcq = length(stimLabels);

% We set the "on" stimulus period to 0, and the "off" period to "1". This
% is because the BOLD fMRI response is inverted in these measurements
% conducted with 100% 02 ventilation. By switching the phase of the
% stimulus vector, we can make use of the mtSinai model machinery that
% searches for HRFs with a positive form.
%
% Additionally, we flip the assignment of on and off periods for the right
% eye acquisitions. This way, the analysis constitutes a contrast betweeen
% left and right.
stimVectorLeft = zeros(1,nTRsPerAcq);
stimVectorRight = ones(1,nTRsPerAcq);
for ii=1:nBlocks
    stimVectorLeft(1,(ii-1)*blockLength+5:(ii-1)*blockLength+8) = 1;
    stimVectorRight(1,(ii-1)*blockLength+5:(ii-1)*blockLength+8) = 0;
end

% Assemble the cell array of stimulus matrices.
fullMatrix = zeros(nAcq,144);
stimulus = {};
for ii=1:nAcq
    thisMatrix = fullMatrix;
    if contains(stimLabels{ii},'right')
        thisMatrix(ii,:) = stimVectorRight;
    else
        thisMatrix(ii,:) = stimVectorLeft;
    end
    stimulus{ii} = thisMatrix;
end

% Save the stimulus file to a tmp location
fileName = fullfile(tempdir,'photoFlickerStimulusMtSinaiModel_LFLeftVsRight.mat');
save(fileName,'stimulus');

% Get the flywheel key
flywheelAPIkey = getpref('flywheelMRSupport', 'flywheelAPIKey');

% Upload the stimulus file to Flywheel
system(['fw login' ' ' flywheelAPIkey ';' ' ' 'fw upload' ' ' fileName ' ' 'fw://gkaguirrelab/canineFovea/'])


% Initiate the modelOpts text string
modelOpts = '(polyDeg),13,(stimLabels),{ ';

% Add in the stimulus labels
for ii=1:length(stimLabels)
    modelOpts = [modelOpts ['(' stimLabels{ii} '),']];
end

% Remove trailing comma  and cap with bracket
modelOpts = [modelOpts(1:end-1) ' },' ];

% Create and add the avgAcqIdx. Average over eyes and acquisitions to
% show time-series for a given photoreceptor direction. This output is in
% the form of text that can be supplied to the forwardModelWrapper
avgGuide = {[1,4],[2,5],[3,6],[7,10],[8,11],[9,12],[13,16],[14,17],[15,18]};
modelOpts = [modelOpts '(avgAcqIdx),{ '];
for ii = 1:length(avgGuide)
    thisVector = [];
    thisSet = arrayfun(@(thisIdx) [(thisIdx-1)*nTRsPerAcq+1 thisIdx*nTRsPerAcq],avgGuide{ii},'UniformOutput',false);
    thisSet = cell2mat(thisSet);    
    modelOpts = [modelOpts sprintf('[%d:%d,%d:%d,%d:%d],',thisSet)];
end

% Remove trailing comma  and cap with bracket
modelOpts = [modelOpts(1:end-1) ' }\n' ];

% Report the modelOpts
fprintf('modelOpts for this design: \n\n')
fprintf(modelOpts);

