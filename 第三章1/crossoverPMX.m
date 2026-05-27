function [newpop] =crossoverPMX(pop,pc)
%% 交叉操作（映射交叉）：适用于TSP问题
% 交换范例
%           _                          _                          _
%    [1 2 3|4 5 6 7|8 9]  |-> [4 2 3|1 5 6 7|8 9]  |-> [4 2 3|1 8 6 7|5 9]
%    [3 5 4|1 8 7 6|9 2]  |   [3 5 1|4 8 7 6|9 2]  |   [3 8 1|4 5 7 6|9 2]

[row,col]=size(pop);%行为个体数目，列为维度大小
newpop = pop; % 初始化为父代副本

for i=1:2:row
    if rand <= pc  %执行PMX交叉
        % 1.选择两个随机交叉点（或采用其他交叉方式）
        points = sort(randperm(col, 2));
        c1 = points(1);
        c2 = points(2);

        % 2.映射交叉操作（元素映射替换操作）
        child1 = pop(i,:); %转成向量再操作更简洁
        child2 = pop(i+1,:);%转成向量再操作更简洁
        for j = c1:c2
            if child1(j)~= child2(j)
                % 子串1元素映射替换
                pos1 = find(child1 == child2(j), 1);
                child1([j, pos1]) = child1([pos1, j]);

                % 子串2元素映射替换
                pos2 = find(child2 == child1(j), 1);
                child2([j, pos2]) = child2([pos2, j]);
            end
        end

        newpop(i,:)  = child1;
        newpop(i+1,:) = child2;
    else
        % 不交叉，复制得到两个新个体
        newpop(i,:) = pop(i,:);
        newpop(i+1,:) = pop(i+1,:);
    end
end%for

end