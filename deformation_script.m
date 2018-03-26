function deformation_script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is the script of stroke deformation. 
% The main function is 'stroke_deformation.m'.
% Update Time: 2017/08/15
% Author: Qian Yu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('./svg/');  
addpath('./altmany-export_fig-e1b8666');
addpath('./MLS');
folderPath = './svg/';
dstFolder1 = './def_local/';
dstFolder2 = './def_local_global/';
imageCounter = 0;
% get the list of classes
listFolder = dir(folderPath);
for i = 1:size(listFolder,1)
    cateID = i;
    if listFolder(cateID).isdir == 1 && ~strcmp(listFolder(cateID).name,'.') && ~strcmp(listFolder(cateID).name,'..')
        % get the list of images
        listImage = dir([fullfile(folderPath,listFolder(cateID).name),'/*.svg']);
        dstName1 = fullfile(dstFolder1,listFolder(cateID).name);
        dstName2 = fullfile(dstFolder2,listFolder(cateID).name);
        if exist(dstName1)~=7 || exist(dstName2)~=7
            mkdir(dstName1);
            mkdir(dstName2);
        end
        for j = 1:size(listImage,1)
                imageCounter = imageCounter + 1;
                sprintf('Processing sketch %d. It will take several seconds.',imageCounter)
                filename = fullfile(folderPath, listFolder(cateID).name, listImage(j).name);
                stroke_deformation(filename,dstName1,dstName2);
        end
    end
end

end