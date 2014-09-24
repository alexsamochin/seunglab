function comp = applylutWithZeros(comp,lut)

idx = comp>0;
comp(idx) = lut(comp(idx));
