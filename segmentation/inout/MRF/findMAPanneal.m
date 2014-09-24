function [s, varargout] = findMAPanneal(Jparam,condparam,bias,nhood,im,varargin)
% find MAP
  
nhoodsize=2*length(nhood);

% find cut

[m n l]= size(im);

if (nhoodsize ~= 124)
  error('only nhoodsize 124 supported');
end


nhoodfull=[nhood; -nhood];

% init randomly
s=double(rand(m,n,l)>.5)*2-1;
paddeds=zeros(m+2,n+2,l+2);
neighs = zeros(m+4,n+4,l+4,nhoodsize);


% log P(y | x_i=1):
%pyx(:,:,:,1) = -((im-condparam(1))/condparam(2)).^2/2;
%pyx(:,:,:,2) = -((im-condparam(3))/condparam(4)).^2/2;
%pyxv=squeeze(reshape(pyx,[numel(im) 1 1 2]));

mu1=condparam(1);
mu2=condparam(2);
sigma=condparam(3);
bb=bias+1/(2*sigma^2)*(mu1-mu2)*((im-(mu1+mu2)/2));

nsublattices=27;
offsetrange=[0 1 2];
[offm offn offl]=ndgrid(offsetrange,offsetrange,offsetrange);
offsets=[reshape(offm,27,1,1), reshape(offn,27,1,1), reshape(offl,27,1,1)];
	

T=10;
iters=80;
for t=1:iters
  % flip spins on sublattices of conditionally independent nodes
  t
  T
tic
 gridperm = randperm(27);
for sgrid=gridperm
    mo=offsets(sgrid,1)+1;
    no=offsets(sgrid,2)+1;
    lo=offsets(sgrid,3)+1;
    
%    paddeds(2:m+1,2:n+1,2:l+1) = s;
    for i=1:nhoodsize
      mi=2-nhoodfull(i,1);
      ni=2-nhoodfull(i,2);
      li=2-nhoodfull(i,3);
      neighs(mi+1:mi+m,ni+1:ni+n,li+1:li+l,i)=s;
%      neighs(:,:,:,i)=circshift(paddeds,nhoodfull(i,:));
    end
    neighsvalid=neighs(2+mo:3:m+2,2+no:3:n+2,2+lo:3:l+2,:);
    [pm,pn,pl]=size(neighsvalid(:,:,:,1));
    neighsvalid=squeeze(reshape(neighsvalid,[numel(neighsvalid)/nhoodsize 1 1 nhoodsize]));
%    keyboard
%    for i=1:nhoodsize
%      mi=2+nhoodfull(i,1);
%      ni=2+nhoodfull(i,2);
%      li=2+nhoodfull(i,3);
%      neighs(mi+1:mi+m,ni+1:ni+n,li+1:li+l,i)=s;
%%      neighs(:,:,:,i)=circshift(paddeds,nhoodfull(i,:));
%    end
%    neighsvalid=neighs(1+mo:3:m+1,1+no:3:n+1,1+lo:3:l+1,:);
%    neighsvalid=squeeze(reshape(neighsvalid,[numel(neighsvalid)/nhoodsize 1 1 nhoodsize]));
%
    
    % compute conditional probability 
    % log P(x_i=+1 | x_js) (log P(x_i = -1|..) = -logP(x_i=+1|..)
    net = neighsvalid*[Jparam Jparam]';
    
%     tmpp=pyx(mo:3:end,no:3:end,lo:3:end,:); 
%     [pm,pn,pl]=size(tmpp(:,:,:,1));
%     pyxv=squeeze(reshape(tmpp,[numel(tmpp)/2 1 1 2]));
    clear E;
    bbv=bb(mo:3:end,no:3:end,lo:3:end);
    E(:,1) = net+bbv(:);
    E(:,2) = -net-bbv(:);

    ps=exp(1/T*E);
    p=ps./repmat(sum(ps,2),1,2);

    % now update on sublattice
    update=double(reshape(rand(numel(p(:,1)),1)<p(:,1),pm,pn,pl))*2-1;
    s(mo:3:end,no:3:end,lo:3:end)=update;
    
    
    
  end
    toc    
%  figure(2);
%    imagesc(s(:,:,30));
%    keyboard

    % simple annealing schedule
    T=T*19/20;
end

%if (nargin>4)
%  trace=varargin{1};
%  varargout{1} = 1-(sum(sum(sum(abs(s-trace))))/2)/numel(trace);
%end








