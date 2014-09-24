function xdn = upsmpl3(x,N)
% upsamples x by a factor rof N by averaging

dnsz = floor(size(x)/N);
x = x(1:dnsz(1)*N,1:dnsz(2)*N,1:dnsz(3)*N);
xdn = zeros(dnsz,'single');

for shft1 = 1:N,
	for shft2 = 1:N,
		for shft3 = 1:N,
			xdn = xdn + x(shft1:N:end,shft2:N:end,shft3:N:end);
		end
	end
end
xdn = xdn/(N^3);
