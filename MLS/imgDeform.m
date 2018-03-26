function imgDeform

% The step size:
step = 15;

% Reading an image:
img = imread('image.jpg');

% Requiring the pivots:
f=figure; imshow(img);
p = getpoints;
close(f);

% Requiring the new pivots:
f=figure; imshow(img); hold on; plotpointsLabels(p,'r.');
q = getpoints;
close(f);

% Generating the grid:
[X,Y] = meshgrid(1:step:size(img,2),1:step:size(img,1));
gv = [X(:)';Y(:)'];

% Generating the mlsd:
mlsd = MLSD2DpointsPrecompute(p,gv);

% The warping can now be computed:
imgo = MLSD2DWarp(img,mlsd,q,X,Y);

% Plotting the result:
figure; imshow(imgo); hold on; plotpoints(q,'r.');