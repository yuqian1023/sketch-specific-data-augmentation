function [N,flag,D] = bezier_def(x,y,T1,T2,C,flag)

% x,y represent the coordinates on the curve,T1,T2,C are transform matrix.
% bezier(x,y)
% h=bezier(x,y)
% [X,Y]=bezier(x,y)
% N: all points on this segment. D: end points of the segment.
% bezier([5,6,10,12],[0 5 -5 -2])

A = 1000; % the number of points you want to interpolate, the larger this number is, the smoother the line will be. 

n=length(x);
t=linspace(0,1,A);
xx=0;yy=0;

for k=0:n-1
    tmp=nchoosek(n-1,k)*t.^k.*(1-t).^(n-1-k);
    xx=xx+tmp*x(k+1);
    yy=yy+tmp*y(k+1);
% % %     disp(xx(3));
end
for i=1:A
        P(1,i)=xx(i);
        P(2,i)=yy(i);
        P(3,i)=1;
end
%if nargout==2
P =T2*C*T1*P;     %when use matrix to process the image, need to do left multiplication
%P = T2*T1*C*P;
for i=1:A
        M(1,i)=P(1,i);
        M(2,i)=P(2,i);
        M(3,i)=1;
end
M(P==1)=0;
if flag == 1;
    D = [M(1,1), M(1,A); M(2,1), M(2,A)];
    flag = 0;
else
    D = [M(1,A); M(2,A)];
end

% % % axis([0 800 0 800]);
% % % h=plot(M(1,:),M(2,:));
N = M(1:2,:);
if nargout==1
    X=h;
end