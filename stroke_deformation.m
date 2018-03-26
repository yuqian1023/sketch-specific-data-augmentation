function [count] = stroke_deformation(filename,folder1,folder2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to deform sketch locally(stroke-level) and globally(sketch-level)
% Update Time: 2017/08/15
% Author: Qian Yu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid = fopen(filename);                        
count = 0;           % record the stroke number  
D = {};              % record the endpoint of each segment, each row corresponds to one stroke
[name1,name2,~]=fileparts(filename);
id_1 = 0;            % record the number of lines
nextline_2 = fgetl(fid); 
while isstr(nextline_2)                           
      id_1 = id_1 + 1;
      nextline_2 = fgetl(fid); 
end 
% alternative: content = textscan(fid,'%s','delimiter','\n');
%              id_1 = size(content{1,1},1)
id_2 = rem((id_1-8),2);
if id_2 == 0
    indicator = (id_1-8)/2;
else
    indicator = (id_1-9)/2;
end
fseek(fid,0,'bof');

while 1
    nextline = fgetl(fid);                       %read the next line    
    % extract the info. after the tag "transform"
    if strfind(nextline,'transform')
        [mm1,mm2]=strtok(nextline,'"');          
        [mm1,mm2]=strtok(mm2,'"/>');             

        S = regexp(mm1,' ','split');
        S = regexp(S,'(','split');
        for i=1:3;
            P{i} = regexp(S{i}{2},')','split');  %discard the empty cell
            id = cellfun('length',P{i});
            P{i}(id==0)=[];
        end
        sca = char(P{2});
        C=[str2num(sca) 0 0;0 str2num(sca) 0;0 0 1];    %C: scale matrix
        for i = 1:2:3                            %SVG:translate(...) scale(...) translate(...)
            shuzi = regexp(char(P{i}),',','split');
            trans = char(shuzi);
            trans = str2num(trans);
            if i==1
                T1(i,:)=[1 0 trans(1)];           %T1: translate matrix one
                T1(i+1,:)=[0 1 trans(2)];
                T1(i+2,:)=[0 0 1];
            end
            if i==3                               %T2: translate matrix two
                T2(i-2,:)=[1 0 str2num(sca)*trans(1)];
                T2(i-1,:)=[0 1 str2num(sca)*trans(2)];
                T2(i,:)=[0 0 1];
            end
        end
    end
    
%% extract the information following the tag "path".
    if strfind(nextline,'path')
        % discard the character "M" and "C", and extract the numbers behind.
        [mm1,mm2]=strtok(nextline,'M');
        [mm1,mm2]=strtok(mm2,'M');
        S = regexp(mm1,'"/>','split');
        S1 = char(S{1});
        
        % if the indicater is "L" (straight line), only two points needed to extract
        if strfind(S1,'L')
            S1 = regexp(S1,'L','split');
            len = length(S1);
            flag = 1;
            for i = 1:len
                shuzi = regexp(char(S1{i}),' |,','split');
                id = cellfun('length',shuzi);
                shuzi(id==0)=[];
                temp = char(shuzi);
                temp1 = str2num(temp);              % convert string to number.
                temp2(i,:)=[temp1(1),temp1(2)];
            end
            temp3(1,:)=temp2(1,:);
            temp3(2,:)=temp2(2,:);
            [P{count+1,i-1},flag,D{count+1,i-1}] = bezier_def([temp3(1,1),temp3(2,1)],[temp3(1,2),temp3(2,2)],T1,T2,C,flag);
            P_original{count+1} = P{count+1,i-1};
            P_def{count+1} = P{count+1,i-1};
            P_def2{count+1} = P{count+1,i-1};
            P_def3{count+1} = P{count+1,i-1};
            count = count+1;
        else
        % if the indicator is "C" (spline), need to draw Bezier Curve.
            S = regexp(S,'C','split');
            len = length(S{1});
            flag = 1;
            for i = 1:len
                shuzi = regexp(char(S{1}{i}),' |,','split');
                id = cellfun('length',shuzi);
                shuzi(id==0)=[];
                temp = char(shuzi);
                temp1 = str2num(temp);
                if i>1
                    P1(i-1,:) = [a,temp1(1),temp1(3),temp1(5)];
                    P2(i-1,:) = [b,temp1(2),temp1(4),temp1(6)];
                    [P{count+1,i-1},flag,D{count+1,i-1}] = bezier_def(P1(i-1,:),P2(i-1,:),T1,T2,C,flag);
                end
                a = temp1(end-1);
                b = temp1(end);
            end
            for j = 2:(len-1)
                if ~(isempty(D{count+1,j}))
                    D{count+1,1} = [D{count+1,1},D{count+1,j}];
                    P{count+1,1} = [P{count+1,1},P{count+1,j}];
                end
            end
            v = P{count+1,1};
          % how many end points are used as pivot points, the more, the more similar with the original one
            rmNum = floor(len);
            randNum = randperm(len,rmNum);
            p = D{count+1,1}(:,randNum);
            q = p;            
            L = 0;
            X_pre = D{count+1,1}(1,1);
            Y_pre = D{count+1,1}(2,1);
            for i = 2:len
                X_cur = D{count+1,1}(1,i);
                Y_cur = D{count+1,1}(2,i);
                L = L + sqrt((X_cur-X_pre)^2+(Y_cur-Y_pre)^2);
                X_pre = X_cur;
                Y_pre = Y_cur;
            end
        % local deformation
            X_pre = D{count+1,1}(1,1);
            Y_pre = D{count+1,1}(2,1);
            X_end = D{count+1,1}(1,len);
            Y_end = D{count+1,1}(2,len);
            L_dir = sqrt((X_pre-X_end)^2+(Y_pre-Y_end)^2);
            ratio = L_dir/L;
            bb = ones(800,800);
            imshow(bb);
            hold on;
            for k = 1:3
        % from a realistic and aesthetic view, r1 and r2 are introduced to control the distortion direction     
                r1 = (rand<=0.5)*2-1;
                r2 = (rand<=0.5)*2-1;
                for i = 2:rmNum 
        % 15 and 2 are two adjustable parameters to control the distortion degree            
                    q(1,i) = p(1,i) + 15*r1*ratio*abs(randn(1));
                    q(2,i) = p(2,i) + 15*r2*ratio*abs(randn(1));                    
                end                    
                    plotpoints(p,'gs');
                    plotpoints(q,'b*');
                    mlsd = MLSD2DpointsPrecompute(p,v,'similar');
                    fv= MLSD2DTransform(mlsd,q);
                if k==1
                    P_def{count+1} = fv;
                    P_original{count+1} = v;
                elseif k==2
                    P_def2{count+1} = fv;
                else
                    P_def3{count+1} = fv;
                end
            end
            count = count+1;
        end
        if exist(name1)~=7
            mkdir(name1);
        end
        
        if count == id_1 - 8
            % %               set(h1,'visible','off');
            % %               saveas(h1,name1,'png');
        end
    end
    if ~isstr(nextline)                           %reach the end of the file
        break;
    end
end
%%hold off;
fclose(fid);
[R,C] = size(D);
P(:,2:C) = [];
D(:,2:C) = [];
P_def = P_def';
P_def2 = P_def2';
P_def3 = P_def3';
P_original = P_original';

%% plot the deformed sketches and export
bb = ones(800,800);
imshow(bb);
hold on;
for i = 1:count
    plotpoints(P_original{i},'r'); % this is original sketch, drawn in red color
    plotpoints(P_def{i},'k'); 
end
hold off;
sv_name = fullfile(folder1, [name2,'_1.png']); 
export_fig(sv_name,'-native');

bb = ones(800,800);
imshow(bb);
hold on;
for i = 1:count
    plotpoints(P_def2{i},'k');
end
hold off;
sv_name = fullfile(folder1, [name2,'_2.png']); 
export_fig(sv_name,'-native');

bb = ones(800,800);
imshow(bb);
hold on;
for i = 1:count
    plotpoints(P_def3{i},'k');
end
hold off;
sv_name = fullfile(folder1, [name2,'_3.png']); 
export_fig(sv_name,'-native');


%% global deformation
%  here we do global deformation based on the first local deformed sketch
for m = 1:3
    if m==1
        P_bd = P_def;
    elseif m==2
            P_bd = P_def2;
    else 
            P_bd = P_def3;
    end
x = []; y = [];
for i = 1:size(P_def,1)
    x = [x,P_bd{i,1}(1,:)];
    y = [y,P_bd{i,1}(2,:)];
end

k = convhull(x,y);
[~,id1] = max(x(k));
[~,id2] = max(y(k));
[~,id3] = min(x(k));
[~,id4] = min(y(k));
id = [id1,id2,id3,id4];
id = unique(id);

control_p = [];
for j = 1:size(id,2)
    control_p(1,j) = x(k(id(j)));
    control_p(2,j) = y(k(id(j)));
end

flags = [];
flags_new = [];
counter = 1;
Point = [];
counter_bug=0;
while(1)
    counter_inner=0;
    Point = control_p(:,counter);
    r1 = (rand<=0.5)*2-1;
    r2 = (rand<=0.5)*2-1;
    R = abs(randn(1));
    D1 = abs(randn(1))*30;
    D2 = abs(randn(1))*30;
    Point_new(1,:) = Point(1,:) + D1*r1;  %this controls distortion degree.
    Point_new(2,:) = Point(2,:) + D2*r2;
    for i = 1:size(id,2)
        if i == counter
        else
            counter_inner = counter_inner+1;
            d1 = Point(1,:) - control_p(1,i);
            d2 = Point(2,:) - control_p(2,i);
            if d1<=0
                flags(counter_inner,1) = -1;
            else
                flags(counter_inner,1) = 1;
            end
            if d2<=0
                flags(counter_inner,2) = -1;
            else
                flags(counter_inner,2) = 1;
            end
        end
    end
    counter_inner = 0;
    
    for i = 1:size(id,2)
        if i == counter
        else
            counter_inner = counter_inner+1;
            d1_new = Point_new(1,:) - control_p(1,i);
            d2_new = Point_new(2,:) - control_p(2,i);
            if d1_new<=0
                flags_new(counter_inner,1) = -1;
            else
                flags_new(counter_inner,1) = 1;
            end
            if d2_new<=0
                flags_new(counter_inner,2) = -1;
            else
                flags_new(counter_inner,2) = 1;
            end
        end
    end
    diff_flag = flags_new-flags;
    if sum(sum(double(diff_flag~=0)))~=0 && counter_bug<=10
        counter_bug = counter_bug+1;
        continue;
    else
        control_p(:,counter) = Point_new;
        if counter == size(id,2)
            counter_bug = 0;
            break;
        end
        counter = counter+1;
    end
end

%%
xx = control_p(1,:);
yy = control_p(2,:);
mlsd = MLSD2DpointsPrecompute([x(k(id));y(k(id))],[x;y]);
fv= MLSD2DTransform(mlsd,[xx;yy]); 
%% check if any points out of range
[x_max ID1] = max(fv(1,:));
[y_max ID2] = max(fv(2,:));
[x_min ID3] = min(fv(1,:));
[y_min ID4] = min(fv(2,:));

FV = fv;
FLAG = 0;
if x_max>=800
    fv(1,ID1) = 790;
    FLAG=1;
end
if y_max>=800
    fv(2,ID2) = 790;
    FLAG=1;
end
if x_min<=0
    fv(1,ID3) = 10;
    FLAG=1;
end
if y_min<=0
    fv(2,ID4) = 10;
    FLAG=1;
end
ID = [ID1 ID2 ID3 ID4];
if FLAG==1
    mlsd = MLSD2DpointsPrecompute(FV(:,ID),FV);
    fv_new= MLSD2DTransform(mlsd,fv(:,ID)); 
    fv = fv_new;
else
end
for i = 1:count
    str_id(i) = size(P_bd{i,1},2);
end
start = 1; final = 0;
for i = 1:count
    index = str_id(i);
    final = start+index-1;
    P_new{i,1} = fv(:,start:final);
    start = final+1;
end

%% plot and export
bb = ones(800,800);
imshow(bb);
hold on;
for i = 1:count
    plotpoints(P_new{i},'k');
end
hold off;
sv_name = fullfile(folder2, sprintf('%s_%d.png',name2,m)); 
export_fig(sv_name,'-native');

end