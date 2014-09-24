function sim = sim_L1(vec1,vec2,r,sigma)

if ~exist('sigma','var') || isempty(sigma),
	sigma = 1;
end

sim = exp(-sum(abs(vec1-vec2),ndims(vec1))/sigma);
