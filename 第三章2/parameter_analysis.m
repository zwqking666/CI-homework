%% parameter_analysis.m
% 分析缩放因子 F 和交叉概率 CR 对 DE 算法性能的影响
clear; clc; close all;

%% 参数设置
funcIds = [1, 8, 9, 11, 12, 13];
funcNames = {'Sphere (f1)', 'Schwefel (f8)', 'Rosenbrock (f9)', ...
             'Griewank (f11)', 'Ackley (f12)', 'Rastrigin (f13)'};
D = 30;                  % 固定30维
NP = 60;
MaxGen = 500;
runs = 10;               % 独立运行次数
lb = -100;
ub = 100;
strategy = 1;            % 使用 DE/rand/1 进行分析

%% 实验1: 分析缩放因子 F 的影响 (固定 CR=0.9)
CR_fixed = 0.9;
F_values = 0.1:0.2:1.5;  % F 从 0.1 到 1.5
F_results = cell(length(funcIds), length(F_values));

fprintf('========== 分析缩放因子 F 的影响 (CR=%.1f) ==========\n', CR_fixed);
for fi = 1:length(funcIds)
    for fv = 1:length(F_values)
        F = F_values(fv);
        fprintf('Running: %s, F=%.1f\n', funcNames{fi}, F);
        all_best = zeros(1, runs);
        all_convergence = zeros(MaxGen, runs);
        for r = 1:runs
            [~, gbestval, fitrecord] = DE(funcIds(fi), D, NP, MaxGen, F, CR_fixed, strategy, lb, ub);
            all_best(r) = gbestval;
            all_convergence(:, r) = fitrecord';
        end
        F_results{fi, fv}.mean = mean(all_best);
        F_results{fi, fv}.std = std(all_best);
        F_results{fi, fv}.convergence = mean(all_convergence, 2);
    end
end

%% 实验2: 分析交叉概率 CR 的影响 (固定 F=0.5)
F_fixed = 0.5;
CR_values = 0.1:0.2:1.0;  % CR 从 0.1 到 1.0
CR_results = cell(length(funcIds), length(CR_values));

fprintf('\n========== 分析交叉概率 CR 的影响 (F=%.1f) ==========\n', F_fixed);
for fi = 1:length(funcIds)
    for cv = 1:length(CR_values)
        CR = CR_values(cv);
        fprintf('Running: %s, CR=%.1f\n', funcNames{fi}, CR);
        all_best = zeros(1, runs);
        all_convergence = zeros(MaxGen, runs);
        for r = 1:runs
            [~, gbestval, fitrecord] = DE(funcIds(fi), D, NP, MaxGen, F_fixed, CR, strategy, lb, ub);
            all_best(r) = gbestval;
            all_convergence(:, r) = fitrecord';
        end
        CR_results{fi, cv}.mean = mean(all_best);
        CR_results{fi, cv}.std = std(all_best);
        CR_results{fi, cv}.convergence = mean(all_convergence, 2);
    end
end

%% 绘制 F 影响图
figure('Position', [100, 100, 1200, 800]);
for fi = 1:length(funcIds)
    subplot(2, 3, fi);
    means = zeros(1, length(F_values));
    stds = zeros(1, length(F_values));
    for fv = 1:length(F_values)
        means(fv) = F_results{fi, fv}.mean;
        stds(fv) = F_results{fi, fv}.std;
    end
    errorbar(F_values, means, stds, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
    xlabel('缩放因子 F'); ylabel('最优适应度值');
    title(funcNames{fi});
    grid on;
end
sgtitle(sprintf('缩放因子 F 对 DE/rand/1 性能的影响 (D=%d, CR=%.1f)', D, CR_fixed));

%% 绘制 CR 影响图
figure('Position', [100, 100, 1200, 800]);
for fi = 1:length(funcIds)
    subplot(2, 3, fi);
    means = zeros(1, length(CR_values));
    stds = zeros(1, length(CR_values));
    for cv = 1:length(CR_values)
        means(cv) = CR_results{fi, cv}.mean;
        stds(cv) = CR_results{fi, cv}.std;
    end
    errorbar(CR_values, means, stds, 'r-s', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'r');
    xlabel('交叉概率 CR'); ylabel('最优适应度值');
    title(funcNames{fi});
    grid on;
end
sgtitle(sprintf('交叉概率 CR 对 DE/rand/1 性能的影响 (D=%d, F=%.1f)', D, F_fixed));

%% 绘制 F 和 CR 的收敛曲线对比
figure('Position', [100, 100, 1400, 500]);
% F 收敛曲线 (选2个代表性函数: Sphere=f1, Rastrigin=f13)
rep_funcs = [1, 13];
rep_idx   = [1, 6];   % 对应 funcIds 中的位置索引

for fi_idx = 1:2
    fi = rep_funcs(fi_idx);
    row = rep_idx(fi_idx);
    subplot(2, 3, fi_idx);
    for fv = 1:length(F_values)
        semilogy(F_results{row, fv}.convergence, 'LineWidth', 1.2); hold on;
    end
    xlabel('迭代次数'); ylabel('最优适应度值 (log)');
    title(sprintf('不同F下 %s 收敛曲线', funcNames{row}));
    legend(arrayfun(@(x) sprintf('F=%.1f', x), F_values, 'UniformOutput', false), 'Location', 'best');
    grid on;
end

% CR 收敛曲线
for fi_idx = 1:2
    fi = rep_funcs(fi_idx);
    row = rep_idx(fi_idx);
    subplot(2, 3, 3 + fi_idx);
    for cv = 1:length(CR_values)
        semilogy(CR_results{row, cv}.convergence, 'LineWidth', 1.2); hold on;
    end
    xlabel('迭代次数'); ylabel('最优适应度值 (log)');
    title(sprintf('不同CR下 %s 收敛曲线', funcNames{row}));
    legend(arrayfun(@(x) sprintf('CR=%.1f', x), CR_values, 'UniformOutput', false), 'Location', 'best');
    grid on;
end
sgtitle('缩放因子 F 和交叉概率 CR 对收敛曲线的影响');

%% 输出数值结果
fprintf('\n========== F 影响数值结果 ==========\n');
for fi = 1:length(funcIds)
    fprintf('\n%s:\n', funcNames{fi});
    fprintf('F=   ');
    for fv = 1:length(F_values)
        fprintf('%-12.1f', F_values(fv));
    end
    fprintf('\nMean:');
    for fv = 1:length(F_values)
        fprintf('%-12.4e', F_results{fi, fv}.mean);
    end
    fprintf('\nStd: ');
    for fv = 1:length(F_values)
        fprintf('%-12.4e', F_results{fi, fv}.std);
    end
    fprintf('\n');
end

fprintf('\n========== CR 影响数值结果 ==========\n');
for fi = 1:length(funcIds)
    fprintf('\n%s:\n', funcNames{fi});
    fprintf('CR=  ');
    for cv = 1:length(CR_values)
        fprintf('%-12.1f', CR_values(cv));
    end
    fprintf('\nMean:');
    for cv = 1:length(CR_values)
        fprintf('%-12.4e', CR_results{fi, cv}.mean);
    end
    fprintf('\nStd: ');
    for cv = 1:length(CR_values)
        fprintf('%-12.4e', CR_results{fi, cv}.std);
    end
    fprintf('\n');
end

save('parameter_analysis_results.mat', 'F_results', 'CR_results', 'F_values', 'CR_values', 'funcIds', 'funcNames');
fprintf('\n结果已保存至 parameter_analysis_results.mat\n');
