function [cmp,Jnew] = typicalCuts(J,nIter)

Jnew = zeros(size(J),'single');
for k = 1:nIter,
k
	G = rand(size(J))<J;
	Jnew = Jnew + MakeConn3Label(connectedComponentsBlocks(G));
end
Jnew = Jnew/nIter;

cmp = connectedComponentsBlocks(Jnew>0.95);
