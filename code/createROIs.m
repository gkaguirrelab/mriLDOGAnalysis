cd('/Users/aguirre/Downloads')
load('M662_glm_templateImage.mat')

V = MRIread('M662_R2_map.nii');

sizer = size(V.vol);

seedNames = {'LGN','antV1','postV1'};
seedCoords = {[33,27,23],[29,16,21],[29,19,16]};
maxDiffs = {0.4,0.2,0.125};
thresh = {0.2,0.3,0.3};

result=[];

% Loop through the seeds
overlapMap = zeros(sizer);
for ii=1:length(seedNames)
    thisSeed = seedCoords{ii};
    % Rearrange for this volume orientation
    thisSeed = thisSeed([2,1,3]);
    thisMap = V.vol;
    thisMap(thisMap<thresh{ii})=-99;
    switch ii
        case 1
            thisMap(1:23,:,:)=-99;
        case 2
            thisMap(:,:,1:18)=-99;
        case 3
            thisMap(:,:,19:end)=-99;
    end
    thisMap(thisMap==0)=-99;
    result{ii} = RegGrow(thisMap,maxDiffs{ii},thisSeed);
    overlapMap = overlapMap+result{ii};
    fprintf([seedNames{ii} ' - %d voxels\n'],sum(result{ii}(:)))

    % Pack the region into a nifti and save
    fileName = fullfile([seedNames{ii} '_ROI.nii.gz']);
    outData = templateImage;
    outData.vol = reshape(result{ii},[sizer 1]);
    outData.nframes = 1;
    MRIwrite(outData, fileName);

end
sum(overlapMap(:)==2)
