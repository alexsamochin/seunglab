function cmpOut = fillOutValidComp(cmpIn,J)
% Uses potts relaxation to fill out valid components

cmpOut = pottsSeg(J-0.5,mknhood(6),cmpIn,1e6,cmpIn==0);
