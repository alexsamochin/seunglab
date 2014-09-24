function m = moments_3D(im,pSz);

imSz = size(im);
r = floor(pSz/2);

% create the weighting filters
[x,y,z] = meshgrid(-r:r,-r:r,-r:r);
sphMask = (x.^2 + y.^2 + z.^2) <= r^2;
x = sphMask.*x; y = sphMask.*y; z = sphMask.*z;

xx = x.^2; yy = y.^2; zz = z.^2;
xy = x.*y; yz = y.*z; xz = x.*z;

m = zeros([imSz 3 3],'single');
m(:,:,:,1,1) = convn_fast(im,xx,'same');
m(:,:,:,2,2) = convn_fast(im,yy,'same');
m(:,:,:,3,3) = convn_fast(im,zz,'same');
m(:,:,:,1,2) = convn_fast(im,xy,'same'); m(:,:,:,2,1) = m(:,:,:,1,2);
m(:,:,:,2,3) = convn_fast(im,yz,'same'); m(:,:,:,3,2) = m(:,:,:,2,3);
m(:,:,:,1,3) = convn_fast(im,xz,'same'); m(:,:,:,3,1) = m(:,:,:,1,3);
