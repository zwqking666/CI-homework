%% main.m
% 进化计算综合实验 —— 主运行脚本
% 包含:
%   1) GA 与 DE 算法原理验证
%   2) DE/rand/1 与 DE/rand/2 变体对比
%   3) 缩放因子 F 和交叉概率 CR 的参数敏感性分析
clear; clc; close all;

fprintf('========================================\n');
fprintf('  进化计算综合实验\n');
fprintf('========================================\n\n');

%% 第一部分: GA 算法验证
fprintf('>>> 第一部分: 遗传算法 (GA) 验证运行...\n');
D_small = 10;
NP = 100;
MaxGen_small = 500;
Pc = 0.9;
Pm = 0.1;
lb = -100;
ub = 100;
testFunc = 1;  % Sphere

fprintf('  测试函数: Sphere (f1), D=%d, NP=%d, MaxGen=%d\n', D_small, NP, MaxGen_small);
[gbest_ga, gbestval_ga, fitrecord_ga] = GA(testFunc, D_small, NP, MaxGen_small, Pc, Pm, lb, ub);
fprintf('  GA 最优解适应度值: %.6e\n', gbestval_ga);

figure('Position', [100, 100, 800, 400]);
semilogy(fitrecord_ga, 'b-', 'LineWidth', 1.5);
xlabel('迭代次数'); ylabel('最优适应度值 (log)');
title('GA 收敛曲线 (Sphere, D=10)');
grid on;
saveas(gcf, 'GA_convergence.png');

%% 第二部分: DE 算法验证
fprintf('\n>>> 第二部分: 差分进化 (DE) 算法验证运行...\n');
F = 0.5; CR = 0.9;

[gbest_de, gbestval_de, fitrecord_de] = DE(testFunc, D_small, NP, MaxGen_small, F, CR, 1, lb, ub);
fprintf('  DE/rand/1 最优解适应度值: %.6e\n', gbestval_de);

figure('Position', [100, 100, 800, 400]);
semilogy(fitrecord_de, 'r-', 'LineWidth', 1.5);
xlabel('迭代次数'); ylabel('最优适应度值 (log)');
title('DE/rand/1 收敛曲线 (Sphere, D=10)');
grid on;
saveas(gcf, 'DE_convergence.png');

% GA vs DE 对比
figure('Position', [100, 100, 800, 400]);
semilogy(fitrecord_ga, 'b-', 'LineWidth', 1.5); hold on;
semilogy(fitrecord_de, 'r-', 'LineWidth', 1.5);
xlabel('迭代次数'); ylabel('最优适应度值 (log)');
title('GA vs DE/rand/1 收敛曲线对比 (Sphere, D=10)');
legend('GA', 'DE/rand/1', 'Location', 'northeast');
grid on;
saveas(gcf, 'GA_vs_DE_convergence.png');

fprintf('  截图已保存.\n');

%% 第三部分: DE 变体对比
fprintf('\n>>> 第三部分: DE/rand/1 vs DE/rand/2 变体对比...\n');
fprintf('  (此部分需要较长时间运行，请耐心等待...)\n');
run('compare_DE_variants.m');

%% 第四部分: 参数敏感性分析
fprintf('\n>>> 第四部分: 缩放因子 F 和交叉概率 CR 的参数分析...\n');
fprintf('  (此部分需要较长时间运行，请耐心等待...)\n');
run('parameter_analysis.m');

fprintf('\n========================================\n');
fprintf('  所有实验运行完成!\n');
fprintf('========================================\n');
