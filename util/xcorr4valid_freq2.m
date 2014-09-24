function xc = xcf(a,b)

[n1 m1 p1 q1 r1]=size(a);[n2 m2 p2 q2 r2]=size(b);
aa = fftn(a);
bb = fftn(flipdims(b),[n1 m1 p1 q1 r1]);
xc = ifftn(aa.*bb);
n = n1-n2; m = m1-m2; p = p1-p2; q = q1-q2; r = r1-r2;
xc = xc(end:-1:end-n,end:-1:end-m,end:-1:end-p,end:-1:end-q,end:-1:end-r);
xc = real(xc);
