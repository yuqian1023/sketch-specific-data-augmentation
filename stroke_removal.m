function stroke_removal(filename,percent,svgFolder)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to do stroke removal.
% Input: svgFolder: the destination folder
% Update Time: 2017/08/15
% Author: Qian Yu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid = fopen(filename);
[name1,name2,~]=fileparts(filename);
id_1 = 0;
count = 0;
R = [];
%p = 0.5;
nextline = fgetl(fid); 
while isstr(nextline)    
    % extract the info. after "transform"
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
            if i==3                              %T2: translate matrix two
                T2(i-2,:)=[1 0 str2num(sca)*trans(1)];
                T2(i-1,:)=[0 1 str2num(sca)*trans(2)];
                T2(i,:)=[0 0 1];
            end
        end
    end
    
   if strfind(nextline,'path')
      % discard the character "M" and "C", and extract the numbers.
      [mm1,mm2]=strtok(nextline,'M');
      [mm1,mm2]=strtok(mm2,'M');   
      S = regexp(mm1,'"/>','split');
      S1 = char(S{1});
      % 'L': straight line
      if strfind(S1,'L')
        S1 = regexp(S1,'L','split');         
        % compute the length
        len = length(S1);
        flag = 1;
        for i = 1:len
            shuzi = regexp(char(S1{i}),' |,','split');
            id = cellfun('length',shuzi);
            shuzi(id==0)=[];
            temp = char(shuzi);
            temp1 = str2num(temp);       
            temp2(i,:)=[temp1(1),temp1(2)];
        end
        temp3(1,:)=temp2(1,:);
        temp3(2,:)=temp2(2,:);
        [P{count+1,i-1},flag,D{count+1,i-1}] = bezier_def([temp3(1,1),temp3(2,1)],[temp3(1,2),temp3(2,2)],T1,T2,C,flag);
        P_def{count+1} = P{count+1,i-1};
        P_def2{count+1} = P{count+1,i-1};
        P_def3{count+1} = P{count+1,i-1};
        D_index = D{count+1,1};           
        L = sqrt((D_index(1,1)-D_index(1,2))^2+(D_index(2,1)-D_index(2,2))^2);
        count = count+1;
        R(count,1:2) = [count,L];
    else
        % "C"(spline): Bezier Curve.
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
        % The more end points are used as pivot points, the more similar to the original one
        rmNum = floor(len);
        % % %     rmNum = len;
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
     count = count+1;
     % For each stroke s, R(s,1) records the ordering, R(s,2) records the length.
     R(count,1:2) = [count,L]; 
  end
   end
      id_1 = id_1 + 1;
      nextline = fgetl(fid); 
end 
fseek(fid,0,'bof');

ratio = zeros(count,1);
ratio_rm = zeros(count, 1);
% two parameters control the weights of length and ordering
alpha = 0.5;
bate = 2;
for i = 1:count
    ratio(i,1) = exp(alpha*R(i,1)-bate*R(i,2));
% % %     ratio(i,1) = exp(-bate*R(i,2));
end

% compute the removal probability for each stroke
for i = 1:count
    ratio_rm(i,1) = ratio(i,1)/sum(ratio(:,1));
end
rm = round(percent*count);
if rm  == count
    rm = rm-1;
end
[score, index] = sort(ratio_rm,'descend');
rm_index = index(1:rm,1);
rm_index = sort(rm_index);
newFile = fullfile(svgFolder,sprintf('%s_%d.svg',name2,percent*100));  % the last number indicate the removal ratio
fid1 = fopen(newFile, 'w');

for j = 1 : 5
    nextline_2 = fgetl(fid);
    fprintf(fid1, nextline_2);
    fprintf(fid1, '\n');
end
for j = 6 : (id_1-3)
    nextline_2 = fgetl(fid);
    comp = j-5;
    if ~isempty(find(rm_index==comp))
        fprintf(fid1, '\n');
    else
        fprintf(fid1, nextline_2);
        fprintf(fid1, '\n');
    end
end
for j = (id_1-2) : id_1
    nextline_2 = fgetl(fid);    
    fprintf(fid1, nextline_2);
    fprintf(fid1, '\n');
end

fclose(fid1);
fclose(fid);
end