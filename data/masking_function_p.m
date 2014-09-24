function [x_out_m, x_in_m]=masking_function_p(x_out, x_in)

% for out space
x_out_m=min(1,max(0, (1.5./(1+.4*x_out.^4))-.2));
x_out_m(find(abs(x_out)>1.5))=0;

% for in space
x_in_m=min(1,max(.1, (1./(1+.02*x_in.^2.5))));
