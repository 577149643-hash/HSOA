 %Circle映射
 function [x] = Circle(Max_iter)
 x(1)=rand; %初始点
%Circle map
a=0.5;
b=0.2;
for i=1:Max_iter-1
    x(i+1)=mod(x(i)+b-(a/(2*pi))*sin(2*pi*x(i)),1);
end
 end