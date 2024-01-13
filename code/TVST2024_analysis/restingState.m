function restingState(ldogFixArchive, workdir, outputDir, parcellationsOne, parcellationsTwo, labelsOne, labelsTwo, seedBasedLabelNames)
    
    % Inputs 
    %
    % ldogFixArchive:   ldogfix archive or you can pass a zip file which
    %                   contains subfolders which contain nifti images.
    % workdir:          Workdir where intermediate files will be saved.
    %                   This folder will be deleted by the script at the 
    %                   end.
    % outputDir:        Output directory where the correlation matrix will
    %                   be saved.
    % parcellationsOne: Nifti parcellation file that contains labels in the
    %                   same space as the input image coordinates
    % parcellationsTwo: Nifti parcellation file for another set of labels.
    %                   this option is available in case you want to pass
    %                   the same set of labels for left and right hemis 
    %                   separately.
    % labelsOne:        An exel or csv sheet containing label names on one
    %                   column and label numbers in the second column.
    % labelsTwo:        Second set of labels if you passed parcellationsTwo
    % seedBasedLabelNames:   Comma separated label str names which will be 
    %                        used for seed based whole brain comparisons. 
    %                        Do not use spaces between commas. 

    % Create a temp folder
    tmpFolder = fullfile(workdir, 'temp');
    if ~isfolder(tmpFolder)
        mkdir(tmpFolder)
    end
    
    % Unzip the ldogfix files
    unzip(ldogFixArchive, tmpFolder)

    % Get the directory that contains images in subfolders, remove the path
    % parameters.
    imageDir = dir(tmpFolder);
    imageDir(1:2, :) = [];
    
    % Read the first image on the list. We will concatanate the others with
    % this one in a loop.
    firstImageDir = dir(fullfile(tmpFolder, imageDir(1).name));
    firstImageContainer = load_nifti(fullfile(firstImageDir(3).folder, firstImageDir(3).name));
    firstImageForPlotting = firstImageContainer.vol;
    firstImage = firstImageContainer.vol;
    sz = size(firstImage);
    firstImage = reshape(firstImage, [sz(1)*sz(2)*sz(3), sz(4)]);
    
    % Remove the first image from the image list as we already read it. 
    imageDir(1, :) = [];
    
    % Loop through images and append to the first image
    for ii = 1:length(imageDir)
        subfolderNameDir = dir(fullfile(imageDir(ii).folder, imageDir(ii).name));
        image = load_nifti(fullfile(subfolderNameDir(3).folder, subfolderNameDir(3).name));
        image = image.vol;
        sz = size(image);
        image = reshape(image, [sz(1)*sz(2)*sz(3), sz(4)]);
        firstImage = [firstImage image];
    end
    
    % Read parcellations and the label list
    if ~strcmp(parcellationsOne, 'NA')
        parcellationOne = load_nifti(parcellationsOne);
        parcellationOne = parcellationOne.vol;
        sz = size(parcellationOne);
        parcellationOne = reshape(parcellationOne, [sz(1)*sz(2)*sz(3),1]);
        labelsOne = readtable(labelsOne);
        for ii = 1:height(labelsOne)
            cellOne{ii,1} = labelsOne{ii,2};
            cellOne{ii,2} = mean(firstImage(find(parcellationOne == table2array(labelsOne(ii,1))), :), 1);
        end
    end
    
    % Read the second set of parcellations and list if exists 
    if ~strcmp(parcellationsTwo, 'NA')
        parcellationsTwo = load_nifti(parcellationsTwo);
        parcellationsTwo = parcellationsTwo.vol;
        sz = size(parcellationsTwo);
        parcellationsTwo = reshape(parcellationsTwo, [sz(1)*sz(2)*sz(3),1]);
        labelsTwo = readtable(labelsTwo);
        for ii = 1:height(labelsTwo)
            cellTwo{ii,1} = labelsTwo{ii,2};
            cellTwo{ii,2} = mean(firstImage(find(parcellationsTwo == table2array(labelsTwo(ii,1))), :), 1);
        end
        correlationCell = [cellOne; cellTwo];
    else
        correlationCell = cellOne;
    end        
    
    % Separate matrix and labels
    matrix = [];
    labels = {};
    for ii = 1:length(correlationCell)
        matrix = [matrix correlationCell{ii,2}'];
        labels{end+1} = correlationCell{ii,1}{1};
    end
    
    % Make a correlation matrix 
    correlationMatrix = corrcoef(matrix,'rows','pairwise');
    
    % Make a correlation plot
    figureIm = figure('visible','off');
    imagesc(correlationMatrix)
    corrMatSize = size(correlationMatrix);
    set(gca, 'XTick', 1:corrMatSize(1)); % center x-axis ticks on bins
    set(gca, 'YTick', 1:corrMatSize(2)); % center y-axis ticks on bins
    set(gca, 'XTickLabel', labels); % set x-axis labels
    xtickangle(90)
    set(gca, 'YTickLabel', labels); % set y-axis labels
    colormap('jet'); % set the colorscheme
    colorbar; % enable colorbar
    set(gcf,'PaperPosition',[0 0 [1024 768]/100],'PaperUnits','inches'); %set paper size
    saveas(figureIm, fullfile(outputDir, 'correlationMat.jpg'));
    save(fullfile(outputDir, 'correlationMatrix.mat'), 'correlationMatrix')
    save(fullfile(outputDir, 'averageTimeseriesPerLabel.mat'), 'correlationCell')
    
    % Correlation 
    if ~strcmp(seedBasedLabelNames, 'NA')
        cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
        labels = strsplit(seedBasedLabelNames, ',');
        for l = 1:length(labels)
            labelName = labels{l};
            idx = find(cellfun(cellfind(labelName),correlationCell));
            emptyCorrelationMat = zeros(length(firstImage),1);
            for ii = 1:length(firstImage)
                r  = corrcoef(correlationCell{idx,2}, firstImage(ii,:), 'rows','pairwise');
                r = r(2);
                emptyCorrelationMat(ii) = r;
            end
            final_im = reshape(emptyCorrelationMat, [sz(1) sz(2) sz(3)]);
            firstImageContainer.vol = final_im;   
            save_name = fullfile(outputDir, [strrep(correlationCell{idx,1}{1}, ' ', '_') '_Rmap' '.nii.gz']);
            save_nifti(firstImageContainer,save_name);
        end
    end
end
