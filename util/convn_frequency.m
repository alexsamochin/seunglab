function C=convn_frequency(A, B, shape)
    if( nargin<3 || isempty(shape)) shape='full'; end;
    ndA = ndims(A);  ndB = ndims(B); nd = max(ndA,ndB);
    sizA = size(A); sizB = size(B); 
    if (ndA>ndB) sizB = [sizB ones(1,ndA-ndB)]; end;
    if (ndA<ndB) sizA = [sizA ones(1,ndB-ndA)]; end;

    siz = sizA + sizB - 1;

    % calculate correlation in frequency domain
    Fa = fftn(A,siz);
    Fb = fftn(B,siz);
    C = ifftn(Fa .* Fb);
    
    % make sure output is real if inputs were both real
    if(isreal(A) && isreal(B)) C = real(C); end;
    
    % crop to size
    if(strcmp(shape,'valid'))
        C = arraycrop2dims( C, max(0,sizA-sizB+1 ) );
    elseif(strcmp(shape,'same'))
        C = arraycrop2dims( C, sizA );
    elseif(~strcmp(shape,'full'))
        error('unknown shape');
    end
