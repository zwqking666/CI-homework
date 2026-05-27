%% compare_DE_variants.m
% 对比分析 DE/rand/1 与 DE/rand/2 在不同测试函数上的性能差异
clear; clc; close all;

%% 参数设置
funcIds = [1, 8, 9, 11, 12, 13];  % 测试6个函数
funcNames = {'Sphere (f1)', 'Schwefel (f8)', 'Rosenbrock (f9)', ...
             'Griewank (f11)', 'Ackley (f12)', 'Rastrigin (f13)'};
dims = [10, 30];         % 测试10维和30维
NP = 60;                 % 种群规模
MaxGen = 500;            % 最大迭代代数
F = 0.5;                 % 缩放因子
CR = 0.9;                % 交叉概率
runs = 15;               % 独立运行次数
lb = -100;               % 搜索下界
ub = 100;                % 搜索上界

strategies = [1, 2];     % 1=DE/rand/1, 2=DE/rand/2
stratNames = {'DE/rand/1', 'DE/rand/2'};

%% 运行实验
results = cell(length(funcIds), length(dims), length(strategies));

for fi = 1:length(funcIds)
    for di = 1:length(dims)
        D = dims(di);
        for si = 1:length(strategies)
            fprintf('Running: %s, D=%d, %s\n', funcNames{fi}, D, stratNames{si});
            all_best = zeros(1, runs);
            all_convergence = zeros(MaxGen, runs);
            for r = 1:runs
                [~, gbestval, fitrecord] = DE(funcIds(fi), D, NP, MaxGen, F, CR, strategies(si), lb, ub);
                all_best(r) = gbestval;
                all_convergence(:, r) = fitrecord';
            end
            results{fi, di, si}.best = all_best;
            results{fi, di, si}.convergence = mean(all_convergence, 2);
            results{fi, di, si}.std_best = std(all_best);
            results{fi, di, si}.mean_best = mean(all_best);
        end
    end
end

%% 输出结果表格
fprintf('\n========== DE/rand/1 vs DE/rand/2 性能对比 ==========\n');
for di = 1:length(dims)
    D = dims(di);
    fprintf('\n--- 维度 D = %d ---\n', D);
    fprintf('%-20s %-15s %-15s %-15s %-15s\n', '函数', 'DE/rand/1 Mean', 'DE/rand/1 Std', 'DE/rand/2 Mean', 'DE/rand/2 Std');
    fprintf('%-20s %-15s %-15s %-15s %-15s\n', '----', '-------------', '-------------', '-------------', '-------------');
    for fi = 1:length(funcIds)
        m1 = mean(results{fi, di, 1}.best);
        s1 = std(results{fi, di, 1}.best);
        m2 = mean(results{fi, di, 2}.best);
        s2 = std(results{fi, di, 2}.best);
        fprintf('%-20s %-15.4e %-15.4e %-15.4e %-15.4e\n', funcNames{fi}, m1, s1, m2, s2);
    end
end

%% 绘制收敛曲线对比图
figure('Position', [100, 100, 1200, 800]);
for fi = 1:length(funcIds)
    for di = 1:length(dims)
        subplot(length(dims), length(funcIds), (di-1)*length(funcIds) + fi);
        c1 = results{fi, di, 1}.convergence;
        c2 = results{fi, di, 2}.convergence;
        semilogy(c1, 'b-', 'LineWidth', 1.5); hold on;
        semilogy(c2, 'r--', 'LineWidth', 1.5);
        xlabel('迭代次数'); ylabel('最优适应度值 (log)');
        title(sprintf('%s (D=%d)', funcNames{fi}, dims(di)));
        legend(stratNames, 'Location', 'northeast');
        grid on;
    end
end
sgtitle('DE/rand/1 与 DE/rand/2 收敛曲线对比');

%% 绘制箱线图对比
figure('Position', [100, 100, 1400, 600]);
for di = 1:length(dims)
    subplot(1, 2, di);
    data_to_plot = [];
    labels = {};
    for fi = 1:length(funcIds)
        data_to_plot = [data_to_plot, results{fi, di, 1}.best', results{fi, di, 2}.best'];
        labels = [labels, {[funcNames{fi} '-rand/1']}, {[funcNames{fi} '-rand/2']}];
    end
    boxplot(data_to_plot, 'Labels', labels);
    ylabel('最优适应度值');
    title(sprintf('DE/rand/1 vs DE/rand/2 箱线图对比 (D=%d)', dims(di)));
    xtickangle(45);
    grid on;
end

save('compare_DE_results.mat', 'results', 'funcIds', 'funcNames', 'dims', 'stratNames');
fprintf('\n结果已保存至 compare_DE_results.mat\n');
