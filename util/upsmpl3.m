function xup = upsmpl3(x,N)
% upsamples x by a factor rof N by copying

xup = zeros(N*size(x),'single');

for shft1 = 1:N,
	for shft2 = 1:N,
		for shft3 = 1:N,
			xup(shft1:N:end,shft2:N:end,shft3:N:end) = x;
		end
	end
end
