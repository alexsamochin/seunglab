function [x,dnSmpSz,dnSmpIdx] = dnSmplMean(x,smpFact)
%DNSMPL dnsamples an array by averaging (binning)
%	[x,dnSmpSz] = dnSmpl(x,smpFact)
%	smpFact is an array of dnsampling factors for each dimension

sz = size(x);
if length(sz)<length(smpFact), sz(length(sz)+1:length(smpFact))=1; end
assert(length(sz)==length(smpFact),'ndim doesnt match smpFact length')

dnSmpIdx = find(smpFact~=1);
dnSmpSz(2:2:2*length(smpFact)) = sz./smpFact;
dnSmpSz(2*dnSmpIdx-1) = -1;
dnSmpSz(dnSmpSz==0) = [];
dnSmpIdx = fliplr(find(dnSmpSz==-1));
dnSmpSz(dnSmpIdx) = smpFact(smpFact~=1);

x = reshape(x,dnSmpSz);
dnSmpSzCopy = dnSmpSz;
for k=dnSmpIdx,
	dnSmpSzCopy(k) = [];
	x = reshape(mean(x,k),dnSmpSzCopy);
end
