% train a CRF with thresholding
% the Js are constrained to be non negative

addpath('../adjacency_list');
%addpath('~/svn/EM/segmentation/');

load ~jfmurray/project/semdata/retina1/retina1.mat
load ~jfmurray/project/semdata/retina1/retina1_comp0707.mat
load ~viren/nosplit_label_mask_4.mat

clear conn;

multiplier=1024;

im=retina1.im;
clear retina1;

% renormalize image to mean 0 and variance 16 (min cut algorithm runs with integers)
meanim=mean(im(:));
stdim=std(im(:));
% im3=im-meanim;
% im3=16*double(im3/stdim);
im3=double(im(20:70,20:120,1:100));

trace=comp>0;
trace=trace(20:70,20:120,1:100);

trace=trace*2-1;

[m,n,l]=size(im3);
nhoodsize=124;


nhood=mknhood(nhoodsize);


nhoodfull=[nhood; -nhood];

nhoodtidx = [nhoodsize/2+[1:nhoodsize/2] 1:nhoodsize/2 ];
p=MakePermuteVecDenseGraph([m n l], nhoodfull, nhoodtidx);


mask=double(label_mask(20:70,20:120,1:100));
nmask=double(sum(mask(:)>0));
mtrace=trace.*mask;


%clear comp




%cl=ones(m,n,l,nhoodsize/2);

%theta = .5;
%Jparam=zeros(nhoodsize/2,1);

sidsjd=MakeConnLabel(trace,nhood)*2-1;

T=200;
eta=.001;
etat=.001;
for t=1:T
tic
% clear cl2;
% for i=1:length(Jparam)
%   cl2(:,:,:,i) = cl(:,:,:,i)*Jparam(i);
% end
% J=Dense2SparseGraph(cl2,nhood);
% [i,j,weight]=find(J);
% lidx=find(i<j);
% clear J;
% 
% is=i(lidx);
% js=j(lidx);
% weights=multiplier*weight(lidx);
%  clear i;
%  clear j;
%  clear lidx;
%  clear weight;
%  
%  clear adm;
% adm = [is js weights weights];
%  clear weights;
%  clear is;
%  clear js;
%  clear ssm;
% ssm = multiplier*[im3(:)-theta -(im3(:)-theta)];

% keyboard

%cut=cut_graph_al(ssm,adm);
cut=findMAPthetaBP(Jparam,theta,nhood,im3,p);
cut=cut*2-1;
cut=reshape(cut,[m n l]);
thetaerr = (mtrace-cut.*mask)/nmask;
thetagrad = sum(thetaerr(:))

sisj=MakeConnLabel(cut,nhood)*2-1;
Jerr = (sidsjd - sisj)/nmask;

Jgrad = squeeze(sum(sum(sum(Jerr,1),2),3));
clear Jerr;

%keyboard

Jparam=Jparam+Jgrad*eta;
%Jparam(Jparam<0)=0;
theta = theta-thetagrad*etat;

for i=1:62
  k(3+nhood(i,1),3+nhood(i,2),3+nhood(i,3))=Jparam(i);
  k(3-nhood(i,1),3-nhood(i,2),3-nhood(i,3))=Jparam(i);
end

%pixelperf = 1-(sum(sum(sum(abs(cut-trace))))/2)/numel(trace)

t
figure(1);montage2(k);
figure(2);imagesc(cut(:,:,20));
figure(3);imagesc(im3(:,:,20)>theta);
figure(4);imagesc(trace(:,:,20));

disp('updated params');
k
theta
pixelperf = 1-(sum(sum(sum(abs(cut-mtrace))))/2)/nmask

toc
end

%thetaim = (theta/16*stdim)+meanim
pixelperf = 1-(sum(sum(sum(abs(cut-trace))))/2)/numel(trace)

for i=1:62
  k(3+nhood(i,1),3+nhood(i,2),3+nhood(i,3))=Jparam(i);
  k(3-nhood(i,1),3-nhood(i,2),3-nhood(i,3))=Jparam(i);
end

save results/params_trainCRFBP Jparam theta eta cut trace im3 pixelperf k
