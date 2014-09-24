function [x,upSmpIdx] = upSmpl(x,smpFact)
%UPSMPL upsamples an array by copying (and dividing by upsampling factor)
%	[x,upSmpIdx] = upSmpl(x,smpFact)
%	smpFact is an array of upsampling factors for each dimension

sz = size(x);
if length(sz)<length(smpFact), sz(length(sz)+1:length(smpFact))=1; end
assert(length(sz)==length(smpFact),'ndim doesnt match smpFact length')

upSmpIdx = repmat({':'},[1 length(smpFact)]);
for k=find(smpFact~=1),
	upSmpIdx{k} = reshape(repmat(1:sz(k),[smpFact(k) 1]),[smpFact(k)*sz(k) 1]);
end

x = x(upSmpIdx{:})/prod(smpFact);
