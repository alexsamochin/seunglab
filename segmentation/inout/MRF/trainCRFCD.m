% train an MRF with pseudo likelihood

addpath('../adjacency_list');
%addpath('~/svn/EM/segmentation/');

%load ~/retina1/retina1.mat
%load ~/retina1/retina1_comp0707.mat
load ~jfmurray/project/semdata/retina1/retina1.mat
load ~jfmurray/project/semdata/retina1/retina1_comp0707.mat


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



K=2;

nsublattices=27;
offsetrange=[0 1 2];
[offm offn offl]=ndgrid(offsetrange,offsetrange,offsetrange);
offsets=[reshape(offm,27,1,1), reshape(offn,27,1,1), reshape(offl,27,1,1)];



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
eta=.02;
etat=.02;
for t=1:T
  t
  tic

  
  % do gibbs sampling

  test=zeros(size(s));
  s=trace;
  for step=1:K
    step
    gridperm = randperm(27);
    for sgrid=gridperm
      mo=offsets(sgrid,1)+1;
      no=offsets(sgrid,2)+1;
      lo=offsets(sgrid,3)+1;
      
      
      for i=1:nhoodsize
	mi=2-nhoodfull(i,1);
	ni=2-nhoodfull(i,2);
	li=2-nhoodfull(i,3);
	neighs(mi+1:mi+m,ni+1:ni+n,li+1:li+l,i)=s;
	%      neighs(:,:,:,i)=circshift(paddeds,nhoodfull(i,:));
      end
      neighsvalid=neighs(2+mo:3:m+2,2+no:3:n+2,2+lo:3:l+2,:);
      neighsvalid=squeeze(reshape(neighsvalid,[numel(neighsvalid)/nhoodsize 1 1 nhoodsize]));

      % compute conditional probability 
      % log P(x_i=+1 | x_js) (log P(x_i = -1|..) = -logP(x_i=+1|..)
      net = neighsvalid*[Jparam Jparam]';
      
      imc=im3(mo:3:end,no:3:end,lo:3:end,:);
      net = net + imc(:)-theta;
      
      [pm,pn,pl]=size(imc);
%      pyxv=squeeze(reshape(tmpp,[numel(tmpp)/2 1 1 2]));
      clear E;
      E(:,1) = net;
      E(:,2) = -net;
      
      ps=exp(E);
      p=ps./repmat(sum(ps,2),1,2);
      
      %    keyboard
      
      % now update on sublattice
      update=double(reshape(rand(numel(imc),1)<p(:,1),pm,pn,pl))*2-1;
      s(mo:3:end,no:3:end,lo:3:end)=update;
    
%      test(mo:3:end,no:3:end,lo:3:end)=1;
      
    end
  end
  
%  keyboard
  figure(1);
  imagesc(s(:,:,20));
  figure(2);
  imagesc(trace(:,:,20));
  % s now contains sample after K iterations
  
  for i=1:nhoodsize
    mi=2-nhoodfull(i,1);
    ni=2-nhoodfull(i,2);
    li=2-nhoodfull(i,3);
    neighs(mi+1:mi+m,ni+1:ni+n,li+1:li+l,i)=s;
    %      neighs(:,:,:,i)=circshift(paddeds,nhoodfull(i,:));
  end
  neighsvalid=neighs(3:m+2,3:n+2,3:l+2,:);
  neighsvalid=squeeze(reshape(neighsvalid,[numel(neighsvalid)/nhoodsize 1 1 nhoodsize]));
  cdsisj=neighsvalid.*repmat(s(:),1,nhoodsize);
  sumcdsisj=sum(cdsisj,1)/length(cdsisj);
  sumcdsisj=sumcdsisj(1:nhoodsize/2)+sumcdsisj(nhoodsize/2+1:nhoodsize);
  sumcdsi=sum(s(:))/numel(s);
  
  gradJ = sumsisj(1:nhoodsize/2) - sumcdsisj
  Jparam = Jparam +eta * [gradJ];
  for i=1:62
    k(3+nhood(i,1),3+nhood(i,2),3+nhood(i,3))=Jparam(i);
    k(3-nhood(i,1),3-nhood(i,2),3-nhood(i,3))=Jparam(i);
  end
  k

  sumsi
  sumcdsi
  
  gradtheta = sumcdsi - sumsi;
  theta = theta + etat*gradtheta
  figure(3);
  montage2(k);
  
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

