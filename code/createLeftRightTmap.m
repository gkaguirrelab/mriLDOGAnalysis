
load('/Users/aguirre/Downloads/N344_mtSinai_templateImage.mat')
load('/Users/aguirre/Downloads/N344_mtSinai_results.mat')

outMap = templateImage;
outImage = zeros(size(templateImage.vol));
vxs = results.meta.vxs;

leftIdx = cellfun(@(x) contains(x,'left'),results.model.opts{4});

for ii=1:length(vxs)
    idx = vxs(ii);
    params = results.params(idx,1:length(leftIdx));
    [~,~,~,tVal] = ttest2(params(leftIdx),params(~leftIdx));
    outImage(idx)=tVal.tstat;
end

outData.vol = outImage;
outData.nframes = 1;
MRIwrite(outData, '/Users/aguirre/Downloads/photoFlicker_WT_left_vs_right.nii');