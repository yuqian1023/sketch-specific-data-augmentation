function pointDeform

% Collecting the points:
 f=figure; 
 imshow(ones(500));
v = getpoints;
close(f);

% Requiring the pivots:
f=figure; axis equal ij; hold on; plotshape(v,true,'g-');
p = getpoints;
close(f);

% Requiring the new pivots:
f=figure; axis equal ij; hold on; plotshape(v,true,'g-'); plotpointsLabels(p,'r.');
q = getpoints;
close(f);

% Precomputation of the mlsd:
mlsd = MLSD2DpointsPrecompute(p,v);

% Obtaining the transformed points:
fv = MLSD2DTransform(mlsd,q);

% Plotting:
figure;
subplot(121); axis equal ij; hold on;
plotshape(v,true,'g-'); plotpoints(p,'r.');
subplot(122); axis equal ij; hold on;
plotshape(fv,true,'k-'); plotpoints(q,'b.');

% Other transformations:
fv_rigid = fv;

% Transforming the same points using a similarity:
mlsd = MLSD2DpointsPrecompute(p,v,'similar');
fv_similar = MLSD2DTransform(mlsd,q);

% Transforming the same points using an affinity:
mlsd = MLSD2DpointsPrecompute(p,v,'affine');
fv_affine = MLSD2DTransform(mlsd,q);

% Plotting:
figure;
subplot(141); axis equal ij; hold on;
plotshape(v,true,'g-'); plotpoints(p,'r.');
title('Original');
subplot(142); axis equal ij; hold on;
plotshape(fv_rigid,true,'k-'); plotpoints(q,'b.');
title('Rigid');
subplot(143); axis equal ij; hold on;
plotshape(fv_similar,true,'k-'); plotpoints(q,'b.');
title('Similar');
subplot(144); axis equal ij; hold on;
plotshape(fv_affine,true,'k-'); plotpoints(q,'b.');
title('Affine');

end