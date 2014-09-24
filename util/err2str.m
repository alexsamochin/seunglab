function str = err2str(e)
% prints error stack to string
str = '';
str = sprintf([str 'e.message: ' e.message '\n']);
str = sprintf([str 'e.stack length:' num2str(length(e.stack)) '\n']);
for k = 1:length(e.stack),
	str = sprintf([str 'e.stack(' num2str(k) ')' '\n']);
	str = sprintf([str '\t file:' e.stack(k).file '\n']);
	str = sprintf([str '\t name:' e.stack(k).name '\n']);
	str = sprintf([str '\t line:' num2str(e.stack(k).line) '\n']);
end
end
