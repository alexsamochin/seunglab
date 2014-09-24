function [cut, varargout] = findMAPcut(Jparam,condparam,bias,nhood,im,varargin)

if (length(condparam)~=3)
    error('old condparam, should be [mu1 mu2 sigma]');
end

  addpath('../adjacency_list');
  
nhoodsize=2*length(nhood);

% find cut
[m n l]=size(im);
disp('preparing dense weight mat');
tic
cl=ones(m,n,l,nhoodsize/2);
cl2=ones(m,n,l,nhoodsize/2);
for i=1:length(Jparam)
  cl2(:,:,:,i) = cl(:,:,:,i)*Jparam(i);
end
toc
clear cl;
disp('dense2sparse');
tic
J=Dense2SparseGraph(cl2,nhood);
toc
clear cl2;

[i,j,weight]=find(J);
clear J;
lidx=find(i<j);

multiplier=256;

is=i(lidx);
js=j(lidx);
clear i;
clear j
weights=double(multiplier*weight(lidx));
clear weight;

adm = [is js weights weights];
clear lidx;
clear is;
clear js;
clear weights;


%theta=(condparam(1)-condparam(2))/2;
%ssm = double(multiplier*([im(:)-theta+bias -(im(:)-theta+bias)]));
% ssm = [(im(:)-condparam(1))/condparam(2) (im(:)-condparam(3))/condparam(4)];
% ssm = -ssm.^2/2;
% ssm(:,1)=ssm(:,1)+bias;
% ssm(:,2)=ssm(:,2)-bias;
% ssm=double(multiplier*ssm);
% ssm=2*ssm(find(ssm>0));

mu1=condparam(1);
mu2=condparam(2);
sigma=condparam(3);

bb=bias+1/(2*sigma^2)*(mu1-mu2)*((im(:)-(mu1+mu2)/2));
ssm=double(multiplier*[bb -bb]);
clear bb;
ssm(ssm<0)=0;

%keyboard 
disp('computing cut');
tic
cut=cut_graph_al(ssm,adm);
toc
cut=cut*2-1;
cut=reshape(cut,[m n l]);

if (nargin>5)
  trace=varargin{1};
  varargout{1} = 1-(sum(sum(sum(abs(cut-trace))))/2)/numel(trace);
end








