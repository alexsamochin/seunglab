% train an MRF with pseudo likelihood

addpath('../adjacency_list');
addpath('../util');
%addpath('~/svn/EM/segmentation/');

load ~/retina1/retina1.mat
load ~/retina1/retina1_comp0707.mat


im=retina1.im;

% renormalize image to mean 0 and variance 16 (min cut algorithm runs with integers)
meanim=mean(im(:));
stdim=std(im(:));
%im3=im-meanim;
%im3=16*double(im3/stdim);
im3=im(20:70,20:120,1:100);

trace=comp>0;
trace=trace(20:70,20:120,1:100);

trace=trace*2-1;



%clear comp


[m,n,l]=size(im3);

nhoodsize=124;
nhood=mknhood(nhoodsize);
nhoodfull=[nhood; -nhood];

%paddeds=zeros(m+2,n+2,l+2);
%paddeds(2:m+1,2:n+1,2:l+1) = trace;
neighs = zeros(m+4,n+4,l+4,nhoodsize);
for i=1:nhoodsize
  mi=2-nhoodfull(i,1);
  ni=2-nhoodfull(i,2);
  li=2-nhoodfull(i,3);
  neighs(mi+1:mi+m,ni+1:ni+n,li+1:li+l,i)=trace;
  %      neighs(:,:,:,i)=circshift(paddeds,nhoodfull(i,:));
end
neighsvalid=neighs(3:m+2,3:n+2,3:l+2,:);
neighsvalid=squeeze(reshape(neighsvalid,[numel(neighsvalid)/nhoodsize 1 1 nhoodsize]));
%neighsvalid=neighs(3:m,3:n,3:l,:);
%tracevalid=trace(2:m-1,2:n-1,2:l-1);
%keyboard
%neighsvalid=squeeze(reshape(neighsvalid,[prod(size(tracevalid)) 1 1 nhoodsize]));
tracevalid=trace(:);
%squeeze(reshape(trace,[numel(tracev)) 1 1]));
sisj=neighsvalid.*repmat(tracevalid,1,nhoodsize);
sumsisj=sum(sisj,1)/length(sisj);
sumsi=sum(trace(:))/numel(trace);

Jparam = zeros(1,nhoodsize/2);
theta=.5;

% keyboard

T=400;
eta=.55;
etat=.55;
for t=1:T
  t
  tic
  net = neighsvalid*[Jparam Jparam]'+(im3(:)-theta);
  sigma=tanh(net);
  
  sisigma = neighsvalid.*repmat(sigma,1,nhoodsize);
  sumsigma = sum(sigma)/numel(sigma);
  
% plus symmetric terms
  sumsisigma=sum(sisigma,1)/length(sisigma);
  sumsisigma=(sumsisigma(1:nhoodsize/2)+sumsisigma(nhoodsize/2+1:end))/2;
  
%  keyboard
  
  gradJ = sumsisj(1:nhoodsize/2) - sumsisigma
  Jparam = Jparam +eta * [gradJ];
for i=1:62
  k(3+nhood(i,1),3+nhood(i,2),3+nhood(i,3))=Jparam(i);
  k(3-nhood(i,1),3-nhood(i,2),3-nhood(i,3))=Jparam(i);
end
k

sumsi
sumsigma
  gradtheta = sumsigma - sumsi;
  theta = theta + etat*gradtheta
figure(1);
montage2(k);
figure(2);
mf=reshape(sigma,[m n l]);
imagesc(mf(:,:,30)>0);
  
%   if (constrained)
%     Jparam(Jparam<0)=0;
%   end
   toc
  
%  if (t>20)
%    keyboard
%  end

end






%
%% now learn mixture of gaussians
%% mu1, sigma1, mu2, sigma2
%
%%im4=im3-meanim;
%%im4=16*double(im4/stdim);
%im1=im3(find(trace>0));
%im2=im3(find(trace<0));
%
%% im1 contains all image pixels that were traced to 'inside'
%% im2 contains all image pixels that were traced to 'oustide'
%% fit gaussian model now:
%
%mu1=mean(im1);
%sigma1=std(im1);
%mu2=mean(im2);
%sigma2=std(im2);
%
%condparam=[mu1 sigma1 mu2 sigma2];
%
%%keyboard

