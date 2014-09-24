function [comp_out] = DownsampleComponents(comp, fac)
% [comp_out] = DownsampleComponents(comp, fac)
%
% Downsamples a component stack by the factor 'fac' by
% finding the most often component number near each 
% pixel in the new smaller stack.
%
% Returns:
%   comp_out - Components downsamlped by fac
%
% JFM   7/13/2006
% Rev:  7/13/2006

sz = size(comp);
sz_out = floor(sz/fac);

comp_in = zeros([sz_out fac^3],'single');
for ii=1:fac, for jj=1:fac, for kk=1:fac,
	idx = sub2ind(fac*[1 1 1],ii,jj,kk);
	comp_in(:,:,:,idx) = comp(ii:fac:sz_out(1)*fac,jj:fac:sz_out(2)*fac,kk:fac:sz_out(3)*fac);
end, end, end
clear comp
comp_out = mode(comp_in,4);
