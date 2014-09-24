function c = conv(a,b)

[n1 m1 p1 q1 r1]=size(a);[n2 m2 p2 q2 r2]=size(b);
aa = fftn(a);
bb = fftn(b,[n1 m1 p1 q1 r1]);
c = ifftn(aa.*bb);
n = n1-n2; m = m1-m2; p = p1-p2; q = q1-q2; r = r1-r2;
c = c(end-n:end,end-m:end,end-p:end,end-q:end,end-r:end);
c = real(c);
