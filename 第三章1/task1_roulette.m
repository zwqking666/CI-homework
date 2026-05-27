clc; clear; close all;
format short;
rng('shuffle');

%% 任务一：轮盘赌方法选择优势个体的基本原理
% 种群含40个个体，适应度在(0,100)之间随机生成
% 分别设计最大化问题和最小化问题的轮盘赌方法

popsize = 40;
fit = randi([1, 100], 1, popsize);

%% ========== 1. 最大化问题的轮盘赌方法 ==========
fprintf('========== 1. 最大化问题的轮盘赌方法 ==========\n');

p_max = fit ./ sum(fit);
cumP_max = cumsum(p_max);

selected_max = zeros(1, popsize);
for i = 1:popsize
    r = rand;
    selected_max(i) = find(r <= cumP_max, 1);
end

fprintf('原始适应度范围: [%.1f, %.1f]\n', min(fit), max(fit));
fprintf('选中个体平均适应度: %.2f (全局平均: %.2f)\n', mean(fit(selected_max)), mean(fit));

%% ========== 2. 最小化问题的轮盘赌方法 ==========
fprintf('\n========== 2. 最小化问题的轮盘赌方法 ==========\n');

invFit = 1 ./ (fit + eps);
p_min = invFit ./ sum(invFit);
cumP_min = cumsum(p_min);

selected_min = zeros(1, popsize);
for i = 1:popsize
    r = rand;
    selected_min(i) = find(r <= cumP_min, 1);
end

fprintf('原始适应度范围: [%.1f, %.1f]\n', min(fit), max(fit));
fprintf('选中个体平均适应度: %.2f (全局平均: %.2f)\n', mean(fit(selected_min)), mean(fit));

%% 统计选中频次
counts_max = histcounts(selected_max, 1:popsize+1);
counts_min = histcounts(selected_min, 1:popsize+1);

%% ========== 绘制结果 ==========
set(0, 'DefaultAxesFontName', 'Microsoft YaHei');

% ---- 图1：概率分布与轮盘图 ----
figure('Position', [100, 100, 1200, 500], 'Color', 'w');

% (a) 最大化 — 选择概率柱状图（按适应度降序排列）
[fit_sorted, idx_max] = sort(fit, 'descend');
p_max_sorted = p_max(idx_max);

subplot(1,2,1);
b1 = bar(1:popsize, p_max_sorted, 0.7, 'FaceColor', [0.85 0.33 0.10], 'EdgeColor', 'none');
hold on;
scatter(1:popsize, p_max_sorted, 25, 'r', 'filled');
title('最大化 — 个体选择概率分布', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('个体编号（按适应度从大到小排列）', 'FontSize', 11);
ylabel('选择概率', 'FontSize', 11);
xlim([0, popsize+1]);
grid on;
text(popsize*0.7, max(p_max_sorted)*0.9, ...
    sprintf('总适应度 = %d', sum(fit)), 'FontSize', 10, 'Color', [0.5 0.2 0]);

% (b) 最小化 — 选择概率柱状图（按适应度升序排列）
[fit_sorted_min, idx_min] = sort(fit, 'ascend');
p_min_sorted = p_min(idx_min);

subplot(1,2,2);
b2 = bar(1:popsize, p_min_sorted, 0.7, 'FaceColor', [0.00 0.45 0.74], 'EdgeColor', 'none');
hold on;
scatter(1:popsize, p_min_sorted, 25, 'b', 'filled');
title('最小化 — 个体选择概率分布', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('个体编号（按适应度从小到大排列）', 'FontSize', 11);
ylabel('选择概率', 'FontSize', 11);
xlim([0, popsize+1]);
grid on;
text(popsize*0.7, max(p_min_sorted)*0.9, ...
    sprintf('总适应度 = %d', sum(fit)), 'FontSize', 10, 'Color', [0 0 0.4]);

sgtitle('轮盘赌 — 个体选择概率分布（最大化 vs 最小化）', 'FontSize', 14, 'FontWeight', 'bold');

% ---- 图2：累计概率曲线 ----
figure('Position', [100, 100, 900, 400], 'Color', 'w');

subplot(1,2,1);
stairs(1:popsize, cumP_max(idx_max), 'r-', 'LineWidth', 2);
title('最大化 — 累计概率曲线', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('个体编号（按适应度降序）', 'FontSize', 11);
ylabel('累计概率', 'FontSize', 11);
xlim([0, popsize+1]); ylim([0, 1.05]);
grid on;
% 画一条随机选择参考线示意轮盘赌原理
yline(0.5, '--k', 'LineWidth', 1);
text(popsize*0.5, 0.53, 'rand=0.5 → 选中个体约在第27位', 'FontSize', 9, 'Color', [0.3 0.3 0.3]);

subplot(1,2,2);
stairs(1:popsize, cumP_min(idx_min), 'b-', 'LineWidth', 2);
title('最小化 — 累计概率曲线', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('个体编号（按适应度升序）', 'FontSize', 11);
ylabel('累计概率', 'FontSize', 11);
xlim([0, popsize+1]); ylim([0, 1.05]);
grid on;
yline(0.5, '--k', 'LineWidth', 1);
text(popsize*0.5, 0.53, 'rand=0.5 → 选中个体约在第27位', 'FontSize', 9, 'Color', [0.3 0.3 0.3]);

sgtitle('轮盘赌 — 累计概率曲线', 'FontSize', 14, 'FontWeight', 'bold');

% ---- 图3：选中频次 vs 适应度 对比图 ----
figure('Position', [100, 100, 1200, 500], 'Color', 'w');

% (a) 最大化
subplot(1,2,1);
yyaxis left;
bar(1:popsize, counts_max, 0.6, 'FaceColor', [1.0 0.70 0.65], 'EdgeColor', 'none');
ylabel('被选中次数', 'FontSize', 11);
ylim([0, max(counts_max)*1.3]);

yyaxis right;
plot(1:popsize, fit, 'k-o', 'LineWidth', 1.5, 'MarkerSize', 5, 'MarkerFaceColor', 'k');
ylabel('适应度', 'FontSize', 11);

title('最大化 — 个体被选中频次 vs 适应度', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('个体编号', 'FontSize', 11);
xlim([0, popsize+1]);
grid on;

% 标注高适应度个体的选中次数
[~, top3] = maxk(fit, 3);
for k = 1:3
    text(top3(k), counts_max(top3(k))+0.3, ...
        sprintf('f=%.0f', fit(top3(k))), 'FontSize', 8, ...
        'HorizontalAlignment', 'center', 'Color', 'r', 'FontWeight', 'bold');
end

% (b) 最小化
subplot(1,2,2);
yyaxis left;
bar(1:popsize, counts_min, 0.6, 'FaceColor', [0.60 0.80 1.00], 'EdgeColor', 'none');
ylabel('被选中次数', 'FontSize', 11);
ylim([0, max(counts_min)*1.3]);

yyaxis right;
plot(1:popsize, fit, 'k-o', 'LineWidth', 1.5, 'MarkerSize', 5, 'MarkerFaceColor', 'k');
ylabel('适应度', 'FontSize', 11);

title('最小化 — 个体被选中频次 vs 适应度', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('个体编号', 'FontSize', 11);
xlim([0, popsize+1]);
grid on;

% 标注低适应度个体的选中次数
[~, bottom3] = mink(fit, 3);
for k = 1:3
    text(bottom3(k), counts_min(bottom3(k))+0.3, ...
        sprintf('f=%.0f', fit(bottom3(k))), 'FontSize', 8, ...
        'HorizontalAlignment', 'center', 'Color', 'b', 'FontWeight', 'bold');
end

sgtitle('轮盘赌 — 选择结果分析', 'FontSize', 14, 'FontWeight', 'bold');

%% 控制台输出分析
fprintf('\n========== 最大化 — 被选中次数 Top5 ==========\n');
[sorted_max, idx_smax] = sort(counts_max, 'descend');
for k = 1:5
    fprintf('  个体%2d: 适应度=%5.1f, 选中%2d次\n', idx_smax(k), fit(idx_smax(k)), sorted_max(k));
end

fprintf('\n========== 最小化 — 被选中次数 Top5 ==========\n');
[sorted_min, idx_smin] = sort(counts_min, 'descend');
for k = 1:5
    fprintf('  个体%2d: 适应度=%5.1f, 选中%2d次\n', idx_smin(k), fit(idx_smin(k)), sorted_min(k));
end

fprintf('\n========== 结果分析 ==========\n');
fprintf('最大化：选中个体平均适应度 = %.2f, 全局平均 = %.2f → 高出 %.1f%%\n', ...
    mean(fit(selected_max)), mean(fit), ...
    (mean(fit(selected_max))/mean(fit)-1)*100);
fprintf('最小化：选中个体平均适应度 = %.2f, 全局平均 = %.2f → 低于 %.1f%%\n', ...
    mean(fit(selected_min)), mean(fit), ...
    (1-mean(fit(selected_min))/mean(fit))*100);