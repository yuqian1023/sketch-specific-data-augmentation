function removal_script()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is the script for stroke removal.
% The main function is 'stroke_removal.m'.
% Update Time: 2017/08/15
% Author: Qian Yu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('./altmany-export_fig-e1b8666/');
folderPath = './svg/';
dstName = './rm/';
% how many percent of strokes to be removed
% here we define 9 ratios, which means each image will generate 9 sketches
percent = [0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.5,0.6]; 
% how many categories to be processed
numOfCate = 3; 
cateid = 0;
imageCounter = 0;
listFolder = dir(folderPath);

for i = 1:size(listFolder,1)
    if listFolder(i).isdir == 1 && ~strcmp(listFolder(i).name, '.') && ~strcmp(listFolder(i).name, '..')
        listImage = dir(fullfile(folderPath,[listFolder(i).name,'/*.svg']));
        dstFolder = fullfile(dstName,listFolder(i).name);
        if exist(dstFolder)~=7
            mkdir(dstFolder);
        end
        cateid = cateid + 1;
        for j = 1:80
            imageCounter = imageCounter + 1;
            disp(imageCounter);
            filename = fullfile(folderPath,listFolder(i).name,listImage(j).name);
            for k = 1:9
                stroke_removal(filename,percent(1,k),dstFolder);
            end
        end
    end
    if cateid == numOfCate
        break;
    end
    
end
  
end


