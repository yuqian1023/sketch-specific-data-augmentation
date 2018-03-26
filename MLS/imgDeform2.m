function imgDeform2

img = '355.jpg';
% Requiring the pivots:
f=figure; imshow(img);
lp = getpoints;
close(f);

% Rearranging the pivots:
if mod(size(lp,2),2)==1
    lp = lp(:,1:end-1);
end
p = [lp(:,1:2:end);lp(:,2:2:end)];

% Requiring the new pivots:
f=figure; imshow(img); hold on;
plotpointsLabels(lp,'r.');
plot([p(1,:);p(3,:)],[p(2,:);p(4,:)],'r-');
lq = getpoints;
close(f);

% Rearranging the pivots:
if mod(size(lq,2),2)==1
    lq = lq(:,1:end-1);
end
q = [lq(:,1:2:end);lq(:,2:2:end)];

% Generating the mlsd:
mlsd = MLSD2DlinesPrecompute(p,gv);

% The warping can now be computed:
imgo = MLSD2DWarp(img,mlsd,q,X,Y);

% Plotting:
f=figure; imshow(imgo); hold on;
plotpointsLabels(lq,'g.');
plot([q(1,:);q(3,:)],[q(2,:);q(4,:)],'g-');