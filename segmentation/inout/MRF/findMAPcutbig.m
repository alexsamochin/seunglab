function o = findMAPcutbig(Jparam,condparam,bias,nhood,im,varargin)

  [m n l]=size(im);
  
  overlap=10;
  stepwidth=60;

  index=0;
  % split im
  for i=1:stepwidth:m
    index=index+1;
    x1=max(i-overlap/2,1)
    x2=min(m,i+stepwidth+overlap/2)
    
    cut=findMAPcut(Jparam,condparam,bias,nhood,im(x1:x2,:,:));
%    cut=zeros(size(im(x1:x2,:,:)));
%    res(index).x1=x1;
%    res(index).x2=x2;
%    res(index).cut=cut;
    
    if (i>1)
      offset=overlap/2+1;
      cut=cut(offset:end,:,:);
    end
    
    le=size(cut,1);
    o(i:i+le-1,:,:)=cut;
%    keyboard
  end

  
