
scratchSaveDir = tempdir();
outDir = '/Users/aguirre/Downloads/';

fw = flywheel.Flywheel(getpref('flywheelMRSupport','flywheelAPIKey'));

jobID = '628418f9f661a2ea13c73327';
theJob = fw.getJob(jobID);
analysisID = theJob.destination.id;
theAnalysis = fw.getAnalysis(analysisID);

% Grab the results.mat file
fileIdx = find(cellfun(@(x) contains(x.name,'_results.mat'), theAnalysis.files));
fileName = theAnalysis.files{fileIdx}.name;
filePath = fullfile(scratchSaveDir,fileName);
fw.downloadOutputFromAnalysis(analysisID,fileName,filePath);
load(filePath,'results');

% Grab the templateImage file
fileIdx = find(cellfun(@(x) contains(x.name,'_templateImage.mat'), theAnalysis.files));
fileName = theAnalysis.files{fileIdx}.name;
filePath = fullfile(scratchSaveDir,fileName);
fw.downloadOutputFromAnalysis(analysisID,fileName,filePath);
load(filePath,'templateImage');

% Extract the subject name
tmp = strsplit(fileName,'_');
subjectName = tmp{1};

% Process the t-map
outMap = templateImage;
outImageMain = zeros(size(templateImage.vol));
outImageLvR = zeros(size(templateImage.vol));
vxs = results.meta.vxs;

% Which were the left eye stim acquisitions?
leftIdx = cellfun(@(x) contains(x,'left'),results.model.opts{4});

% Loop over the voxels
for ii=1:length(vxs)
    idx = vxs(ii);
    params = results.params(idx,1:length(leftIdx));
    [~,pStat,~,tVal] = ttest(params(1:length(leftIdx)));
    zVal = sign(tVal.tstat)*norminv(pStat);
    outImageMain(idx)=zVal;
    [~,pStat,~,tVal] = ttest2(params(leftIdx),params(~leftIdx));
    zVal = sign(tVal.tstat)*norminv(pStat);
    outImageLvR(idx)=tVal.tstat;
end

outMap.vol = outImageMain;
outMap.nframes = 1;
outFilePath = fullfile(outDir,[subjectName '_zMap_Left+Right.nii']);
MRIwrite(outMap, outFilePath);


outMap.vol = outImageLvR;
outMap.nframes = 1;
outFilePath = fullfile(outDir,[subjectName '_zMap_Left-Right.nii']);
MRIwrite(outMap, outFilePath);
