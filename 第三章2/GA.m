function [gbest, gbestval, fitrecord] = GA(funcId, D, NP, MaxGen, Pc, Pm, lb, ub)
% 遗传算法 (Genetic Algorithm) —— 优化版
% 实数编码 + SBX交叉 + 多项式变异 + 精英保留

% 预提取函数句柄（仅一次）
fhd = get_fhd(funcId);

% 初始化种群
pop = lb + (ub - lb) .* rand(NP, D);
fitness = fhd(pop);

[gbestval, idx] = min(fitness);
gbest = pop(idx, :);
fitrecord = zeros(1, MaxGen);

eta = 21;  % SBX分布指数

for gen = 1:MaxGen
    newpop = zeros(NP, D);
    for i = 1:NP
        % 锦标赛选择
        cand = randperm(NP, 4);
        if fitness(cand(1)) < fitness(cand(2))
            parent1 = pop(cand(1), :);
        else
            parent1 = pop(cand(2), :);
        end
        if fitness(cand(3)) < fitness(cand(4))
            parent2 = pop(cand(3), :);
        else
            parent2 = pop(cand(4), :);
        end

        % SBX交叉
        if rand < Pc
            mu = rand(1, D);
            beta = zeros(1, D);
            idx_lo = mu <= 0.5;
            idx_hi = ~idx_lo;
            beta(idx_lo) = (2 * mu(idx_lo)).^(1/(eta+1));
            beta(idx_hi) = (1 ./ (2 * (1 - mu(idx_hi)))).^(1/(eta+1));
            child = 0.5 * ((1 + beta) .* parent1 + (1 - beta) .* parent2);
        else
            child = parent1;
        end

        % 多项式变异
        mut_mask = rand(1, D) < Pm;
        if any(mut_mask)
            r = rand(1, D);
            delta = zeros(1, D);
            idx_lo = r < 0.5;
            idx_hi = ~idx_lo;
            delta(idx_lo) = (2 * r(idx_lo)).^(1/(eta+1)) - 1;
            delta(idx_hi) = 1 - (2 * (1 - r(idx_hi))).^(1/(eta+1));
            child(mut_mask) = child(mut_mask) + (ub - lb) * delta(mut_mask);
        end

        newpop(i, :) = max(min(child, ub), lb);
    end

    % 精英保留
    newfitness = fhd(newpop);
    [best_new, ~] = min(newfitness);
    [~, worst_idx] = max(fitness);
    if best_new > gbestval
        newpop(worst_idx, :) = gbest;
        newfitness(worst_idx) = gbestval;
    end

    pop = newpop;
    fitness = newfitness;

    [cur_best, cur_idx] = min(fitness);
    if cur_best < gbestval
        gbestval = cur_best;
        gbest = pop(cur_idx, :);
    end
    fitrecord(gen) = gbestval;
end
end
