function [newpop] =mutation(pop,pm)
%% 变异操作：解决TSP问题
% pop： 变异前的种群
% pm：  变异概率
% 变异范例：
% swap:    _         _    slide:    _ _________    flip:     ---------->
%     [1 2|3 4 5 6 7 8|9]      [1 2|3 4 5 6 7 8|9]      [1 2|3 4 5 6 7 8|9]
%                                   _________ _              <----------
%     [1 2|8 4 5 6 7 3|9]      [1 2|4 5 6 7 8 3|9]      [1 2|8 7 6 5 4 3|9]

%-------------------------------------------------------------------------
% 1.预分配存储空间
[row,col]=size(pop);

% 2.直接复制得到新种群
newpop = pop;

% 3.对新种群按照概率执行变异
for i=1:row
    if rand<=pm
        %3.1 产生两个变异点
        points = sort(randperm(col, 2));
        m1 = points(1);
        m2 = points(2);

        % 3.2 根据变异点，对某一个体进行基因位点的交换（点交换，漂移块交换，逆块变换）
        switch randi(3)
            case 1 % Swap: exchange two genes
                newpop(i, [m1, m2]) = newpop(i, [m2, m1]);

            case 2 % Slide: shift segment left by one position
                segment = newpop(i, m1:m2);
                newpop(i, m1:m2) = [segment(2:end), segment(1)];

            case 3 % Flip: reverse the segment
                newpop(i, m1:m2) = newpop(i, m2:-1:m1);
        end
    end
end
end%函数定义结束