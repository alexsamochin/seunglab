function conn = MakeConn3Label(comp)
% conn = MakeConn3Label(comp)
%
% Generates 3-direction connectivity labeling from component labeling.
% Doesn't count extracellular space as connected.
%
% Returns:
%   conn - 3 connectivity image (4d)
%           y, x, z order in 4th dim
%
% JFM   8/14/2006 (from Srini mkConnLabel.m)
% Rev:  8/14/2006 JFM

conn = zeros([size(comp) 3],'single');

% Up (y)
conn(2:end,:,:,1) = ( comp(2:end,:,:) ~= 0 ) & ...
    ( comp(2:end,:,:) == comp(1:end-1,:,:) );

% Left (x)
conn(:,2:end,:,2) = ( comp(:,2:end,:) ~= 0 ) & ...
    ( comp(:,2:end,:) == comp(:,1:end-1,:) );

% Z-up (z)
conn(:,:,2:end,3) = ( comp(:,:,2:end) ~= 0 ) & ...
    (  comp(:,:,2:end) == comp(:,:,1:end-1) );


% % Old version (13 conn) 8/14/2006
% for ii = -1:0,
% 	for jj = -1:(0-ii),
% 		for kk = -1:(0-min(ii,jj)),
% 			idx = idx+1;
% 			idxi = max(1-ii,1):min(imx-ii,imx);
% 			idxj = max(1-jj,1):min(jmx-jj,jmx);
% 			idxk = max(1-kk,1):min(kmx-kk,kmx);
%             
%             % Include extracellular space as component edges
% 			%conn(idxi,idxj,idxk,idx) = (comp(idxi,idxj,idxk) ==comp(idxi+ii,idxj+jj,idxk+kk);)
%             
%             % Don't include extracellular space
%             conn(idxi,idxj,idxk,idx) = (comp(idxi, idxj, idxk) ~= 0) & ...
%                 ( comp(idxi,idxj,idxk) == comp(idxi+ii,idxj+jj,idxk+kk) );
% 		end
% 	end
% end
% conn(:,:,:,end) = 0;
