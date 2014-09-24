function  c=xcorr3valid(im1,im2)
% XCORR3VALID(IM1,IM2) Three-dimensional cross-correlation
% The same as XCORR3
% IM2 is smaller than IM1. 
[m1 n1 p1 q1]=size(im1); [m2 n2 p2 q2]=size(im2);
% zero pad im2
im2padded=zeros(size(im1));
im2padded(1:m2,1:n2,1:p2,1:q2)=im2;

c=zeros(m1-m2+1,n1-n2+1,p1-p2+1,q1-q2+1);
for i=0:(m1-m2)
  for j=0:(n1-n2)
    for k=0:(p1-p2)
      for l=0:(q1-q2)
        c(i+1,j+1,k+1,l+1)=sum(sum(sum(sum(im1.*circshift(im2padded,[i j k l])))));
      end
    end
  end
end
