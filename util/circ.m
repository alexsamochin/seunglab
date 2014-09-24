function out=circ(nx,ny,cx,cy,r);

out=zeros(nx,ny);
for i=1:180
    x(i)=cx+round(r*cos(2*pi*i/180));
    y(i)=cy+round(r*sin(2*pi*i/180));
    out(x(i),y(i))=1;
end
