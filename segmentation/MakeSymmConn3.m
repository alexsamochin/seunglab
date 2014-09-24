function A = MakeSymmConn3(conn)
% A = MakeSymmConn3(conn)
%
% Symmetrize 3 connectedness for speed in Conn3Label1Pass.m 
%
%
%
% JFM    8/14/2006 (from Srini mkSymmConn.m)
% Rev:   8/14/2006 JFM

% ---- Make sure there are no connections outside the volume
conn(1,:,:,1) = 0;
conn(:,1,:,2) = 0;
conn(:,:,1,3) = 0;

[sy sx sz, sc] = size(conn);

A = zeros(sy, sx, sz, 6);
A(:,:,:,1:3) = conn;

% y direction (make down conn from up)
A(1:end-1,:,:,4) = A(2:end,:,:,1);

% x direction (make right conn from left)
A(:,1:end-1,:,5) = A(:,2:end,:,2);

% z direction (make down-z conn from up-z)
A(:,:,1:end-1,6) = A(:,:,2:end,3);



% ---- Old part
% [imx jmx kmx jnk] = size(conn);
% A = zeros([imx jmx kmx 3 3 3],'single');
% idx = 0;
% for ii = -1:0, for jj = -1:(0-ii), for kk = -1:(0-min(ii,jj)),
% 	idx = idx+1;
% 	idxi = max(1-ii,1):min(imx-ii,imx);
% 	idxj = max(1-jj,1):min(jmx-jj,jmx);
% 	idxk = max(1-kk,1):min(kmx-kk,kmx);
% 	if idx<14,
% 		A(idxi,idxj,idxk,2+ii,2+jj,2+kk) = conn(idxi,idxj,idxk,idx);
% 		A(idxi+ii,idxj+jj,idxk+kk,2-ii,2-jj,2-kk) = conn(idxi,idxj,idxk,idx);
% 	end
% end, end, end
% A = A(:,:,:,:);
