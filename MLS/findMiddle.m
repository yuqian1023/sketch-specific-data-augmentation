function [diff_x,diff_y] = findMiddle(P,count)

%translate the sketch as a whole
A = P;
X = zeros(count,4);
for i = 1:count
A{i}(1,:) = sort(P{i}(1,:));
A{i}(2,:) = sort(P{i}(2,:));
end

for i = 1:count
X(i,1) = max(max(A{i}(1,:))); %find the x_max
X(i,2) = min(min(A{i}(1,:))); %find the x_min
X(i,3) = max(max(A{i}(2,:))); %find the y_max
X(i,4) = min(min(A{i}(2,:))); %find the y_min
end

MAX_x = max(max(X(:,1:2)));
MIN_x = min(min(X(:,1:2)));
MAX_y = max(max(X(:,3:4)));
MIN_y = min(min(X(:,3:4)));
mid_x = (MAX_x-MIN_x)/2;
mid_y = (MAX_y-MIN_y)/2;
mid_x = mid_x+MIN_x;
mid_y = mid_y+MIN_y;
diff_x = mid_x-400;
diff_y = mid_y-400;

