function [sizes, list] = ComponentSizes(comp);
% [sizes, list] = ComponentSizes(comp);
%
% JFM   4/10/2006
% Rev:  5/20/2006

comp=single(comp);

list = unique(comp);
num = length(list);

sizes = hist(comp(:),list);

% Sort the list in descending order of size
[sizes, ind] = sort(sizes, 'descend');  
list = list(ind);


% Old slow version
% 
% list = unique(comp);
% 
% for i = 1:length(list)
%     sizes(i) = length(find(comp == list(i)));
%     
%     if verbose
%         fprintf('Size of %d = %d\n', i, sizes(i));
%     end
%     
% end
% 
% % Sort the list in descending order of size
% [sizes, ind] = sort(sizes, 'descend');  
% list = list(ind);
% 
