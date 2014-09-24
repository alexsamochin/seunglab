% train a CRF with mixture of two gaussians
% this thing does not converge

addpath('../adjacency_list');
%addpath('~/svn/EM/segmentation/');

load ~jfmurray/project/semdata/retina1/retina1.mat
load ~jfmurray/project/semdata/retina1/retina1_comp0707.mat


im=retina1.im;

% renormalize image to mean 0 and variance 16 (min cut algorithm runs with integers)
meanim=mean(im(:));
stdim=std(im(:));
% im3=im-meanim;
% im3=16*double(im3/stdim);
im3=im(20:70,20:120,1:100);

trace=comp>0;
trace=trace(20:70,20:120,1:100);

trace=trace*2-1;



%clear comp


[m,n,l]=size(im3);

nhoodsize=26;


nhood=mknhood(nhoodsize);

cl=ones(m,n,l,nhoodsize/2);

%theta = -10;
%condparam=[0,1,0,1];
mu1=0.6;
mu2=0.4;
% estimated from data
sigma1=0.095;
sigma12=sigma1*sigma1;
sigma2=0.095;
sigma22=sigma2*sigma2;
Jparam=zeros(nhoodsize/2,1);

sidsjd=MakeConnLabel(trace,nhood);

T=400;
eta=.1;
for t=1:T
clear cl2;
for i=1:length(Jparam)
  cl2(:,:,:,i) = cl(:,:,:,i)*Jparam(i);
end
tic
J=Dense2SparseGraph(cl2,nhood);
toc
[i,j,weight]=find(J);
lidx=find(i<j);


is=i(lidx);
js=j(lidx);
weights=weight(lidx);

adm = [is js 32*weights 32*weights];
ssm = double([(im3(:)-mu1)/sigma1 (im3(:)-mu2)/sigma2]);
ssm = -32*ssm.^2/2;

%ssm = [im3(:)-theta -(im3(:)-theta)];
disp('computing cut');
tic
cut=cut_graph_al(ssm,adm);
toc
cut=cut*2-1;
cut=reshape(cut,[m n l]);



thetaerr = (trace-cut)/(m*n*l);
%thetagrad = sum(thetaerr(:))

disp('computing gradients');
% mu1grad = sum(thetaerr(:)/2.*(im3(:)-mu1)/sigma1^2);
% mu2grad = -sum(thetaerr(:)/2.*(im3(:)-mu2)/sigma2^2);
mu1grad = sum(thetaerr(:)/2.*(im3(:)-mu1)/1);
mu2grad = -sum(thetaerr(:)/2.*(im3(:)-mu2)/1);

% sigma12grad=.01*sum(thetaerr(:)/2.*(im3(:)-mu1).^2/2/sigma12^2)
% sigma22grad=.01*-sum(thetaerr(:)/2.*(im3(:)-mu2).^2/2/sigma22^2)

sisj=MakeConnLabel(cut,nhood);
Jerr = (sidsjd - sisj)/(m*n*l);

Jgrad = squeeze(sum(sum(sum(Jerr,1),2),3));

t
Jparam=Jparam+eta*Jgrad;
Jparam(Jparam<0)=0
mu1=mu1+eta*mu1grad
mu2=mu2+eta*mu2grad
% sigma12=sigma12+eta*sigma12grad
% sigma22=sigma22+eta*sigma22grad
%keyboard
pixelperf = 1-(sum(sum(sum(abs(cut-trace))))/2)/numel(trace)
end

%thetaim = (theta/16*stdim)+meanim
pixelperf = 1-(sum(sum(sum(abs(cut-trace))))/2)/numel(trace)

condparam=[mu1 sqrt(sigma12) mu2 sqrt(sigma22)];
if nhoodsize==124
  for i=1:62
    k(3+nhood(i,1),3+nhood(i,2),3+nhood(i,3))=Jparam(i);
    k(3-nhood(i,1),3-nhood(i,2),3-nhood(i,3))=Jparam(i);
  end
elseif nhoodsize==26
  for i=1:13
    k(2+nhood(i,1),2+nhood(i,2),2+nhood(i,3))=Jparam(i);
    k(2-nhood(i,1),2-nhood(i,2),2-nhood(i,3))=Jparam(i);
  end
end

save n26CFR Jparam condparam stdim meanim eta cut trace im3 pixelperf k
