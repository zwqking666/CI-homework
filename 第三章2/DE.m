function [gbest, gbestval, fitrecord] = DE(funcId, D, NP, MaxGen, F, CR, strategy, lb, ub)
% 差分进化算法 —— 全向量化版本（每代仅一次矩阵运算，无逐个体for循环）

fhd = get_fhd(funcId);
pop = lb + (ub - lb) .* rand(NP, D);
fitness = fhd(pop);

[gbestval, idx] = min(fitness);
gbest = pop(idx, :);
fitrecord = zeros(1, MaxGen);

% 预分配索引矩阵的内存
idxPool = zeros(NP, 5);

for gen = 1:MaxGen
    % --- 为每个个体预选5个互不相同且不等于自身的随机索引 ---
    for i = 1:NP
        pool = 1:NP;
        pool(i) = [];
        idxPool(i, :) = pool(randperm(NP-1, 5));
    end

    % --- 向量化变异（同时处理所有NP个个体） ---
    r1 = idxPool(:,1); r2 = idxPool(:,2); r3 = idxPool(:,3);
    r4 = idxPool(:,4); r5 = idxPool(:,5);

    switch strategy
        case 1  % DE/rand/1
            v = pop(r1, :) + F .* (pop(r2, :) - pop(r3, :));
        case 2  % DE/rand/2
            v = pop(r1, :) + F .* (pop(r2, :) - pop(r3, :)) + F .* (pop(r4, :) - pop(r5, :));
        case 3  % DE/best/1
            v = gbest + F .* (pop(r1, :) - pop(r2, :));
        case 4  % DE/best/2
            v = gbest + F .* (pop(r1, :) - pop(r2, :)) + F .* (pop(r3, :) - pop(r4, :));
        otherwise
            v = pop(r1, :) + F .* (pop(r2, :) - pop(r3, :));
    end

    % --- 向量化交叉 ---
    mask = rand(NP, D) < CR;
    jrand = randi(D, NP, 1);
    mask(sub2ind([NP, D], (1:NP)', jrand)) = true;  % 确保每行至少一维来自变异

    u = pop;
    u(mask) = v(mask);

    % --- 边界处理 ---
    u = max(min(u, ub), lb);

    % --- 向量化适应度评估（一次矩阵调用） ---
    u_fitness = fhd(u);

    % --- 向量化贪婪选择 ---
    improved = u_fitness < fitness;
    pop(improved, :) = u(improved, :);
    fitness(improved) = u_fitness(improved);

    % --- 更新全局最优 ---
    [min_fit, min_idx] = min(fitness);
    if min_fit < gbestval
        gbestval = min_fit;
        gbest = pop(min_idx, :);
    end

    fitrecord(gen) = gbestval;
end
end
