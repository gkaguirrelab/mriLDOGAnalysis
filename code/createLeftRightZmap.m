
scratchSaveDir = tempdir();
outDir = '/Users/aguirre/Downloads/';

fw = flywheel.Flywheel(getpref('flywheelMRSupport','flywheelAPIKey'));

analysisIDs = {...
    '6286968e9363e64a1b423abe',... % M662 all sessions
    '628501f4d761c6b839dd67f7',... % WT photoFlicker LF
    '62850196172a1813c00ba821',...
    '628501a5bcc8f465c7e22862',...
    '628501b3efe113ad9c4215f5',...
    '628501c06fbeeefb3597857b',...
    '628501cf22d8db0f25ed0bd2'};

for aa = 1:1 %length(analysisIDs)

    thisAnalysisID = analysisIDs{aa};
    theAnalysis = fw.getAnalysis(thisAnalysisID);

    % Grab the results.mat file
    fileIdx = find(cellfun(@(x) contains(x.name,'_results.mat'), theAnalysis.files));
    fileName = theAnalysis.files{fileIdx}.name;
    filePath = fullfile(scratchSaveDir,fileName);
    fw.downloadOutputFromAnalysis(thisAnalysisID,fileName,filePath);
    load(filePath,'results');

    % Grab the templateImage file
    fileIdx = find(cellfun(@(x) contains(x.name,'_templateImage.mat'), theAnalysis.files));
    fileName = theAnalysis.files{fileIdx}.name;
    filePath = fullfile(scratchSaveDir,fileName);
    fw.downloadOutputFromAnalysis(thisAnalysisID,fileName,filePath);
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

end
