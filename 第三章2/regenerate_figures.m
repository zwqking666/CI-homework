%% regenerate_figures.m - MATLAB直接重绘所有图表并保存
clear; clc;

fig_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');
data_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'figures');

%% 加载数据
load(fullfile(data_dir, 'compare_DE_results.mat'));
load(fullfile(data_dir, 'parameter_analysis_results.mat'));

%% 图1: DE变体收敛曲线对比
figure('Position', [50, 50, 1800, 900], 'Visible', 'off');
for di = 1:length(dims)
    D = dims(di);
    for fi = 1:length(funcIds)
        subplot(length(dims), length(funcIds), (di-1)*length(funcIds)+fi);
        c1 = results{fi, di, 1}.convergence;
        c2 = results{fi, di, 2}.convergence;
        semilogy(c1, 'b-', 'LineWidth', 1.5); hold on;
        semilogy(c2, 'r--', 'LineWidth', 1.5);
        xlabel('Generation'); ylabel('Fitness (log)');
        title(sprintf('%s (D=%d)', funcNames{fi}, D), 'FontSize', 8);
        legend(stratNames, 'Location', 'best', 'FontSize', 6);
        grid on;
    end
end
sgtitle('DE/rand/1 vs DE/rand/2 Convergence Curves', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, fullfile(fig_dir, 'fig1_DE_convergence_comparison.png'));
close;
fprintf('Figure 1 saved.\n');

%% 图2: DE变体箱线图对比(对数坐标)
figure('Position', [50, 50, 1600, 600], 'Visible', 'off');
for di = 1:length(dims)
    subplot(1, 2, di);
    data_all = [];
    g = [];
    lbls = {};
    for fi = 1:length(funcIds)
        d1 = results{fi, di, 1}.best(:);
        d2 = results{fi, di, 2}.best(:);
        data_all = [data_all; d1; d2];
        g = [g; ones(length(d1),1)*((fi-1)*2+1); ones(length(d2),1)*((fi-1)*2+2)];
        shortName = strrep(funcNames{fi}, ' (f', sprintf('\nf'));
        lbls{end+1} = [shortName ' rand/1'];
        lbls{end+1} = [shortName ' rand/2'];
    end
    boxplot(data_all, g, 'Labels', lbls);
    set(gca, 'YScale', 'log');
    ylabel('Best Fitness (log)');
    title(sprintf('DE/rand/1 vs DE/rand/2 Boxplot (D=%d)', dims(di)));
    grid on;
    xtickangle(30);
end
sgtitle('DE Variants Performance Distribution (log scale)', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, fullfile(fig_dir, 'fig2_DE_boxplot.png'));
close;
fprintf('Figure 2 saved.\n');

%% 图3: F参数影响(对数坐标)
figure('Position', [50, 50, 1400, 900], 'Visible', 'off');
for fi = 1:length(funcIds)
    subplot(2, 3, fi);
    means = zeros(1, length(F_values));
    stds = zeros(1, length(F_values));
    for fv = 1:length(F_values)
        means(fv) = F_results{fi, fv}.mean;
        stds(fv) = F_results{fi, fv}.std;
    end
    errorbar(F_values, means, stds, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 7, ...
        'MarkerFaceColor', 'b', 'CapSize', 6);
    set(gca, 'YScale', 'log');
    xlabel('Scaling Factor F');
    ylabel('Best Fitness (log)');
    title(funcNames{fi});
    grid on;
end
sgtitle('Effect of Scaling Factor F on DE/rand/1 (D=30, CR=0.9)', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, fullfile(fig_dir, 'fig3_F_analysis.png'));
close;
fprintf('Figure 3 saved.\n');

%% 图4: CR参数影响(对数坐标)
figure('Position', [50, 50, 1400, 900], 'Visible', 'off');
for fi = 1:length(funcIds)
    subplot(2, 3, fi);
    means = zeros(1, length(CR_values));
    stds = zeros(1, length(CR_values));
    for cv = 1:length(CR_values)
        means(cv) = CR_results{fi, cv}.mean;
        stds(cv) = CR_results{fi, cv}.std;
    end
    errorbar(CR_values, means, stds, 'r-s', 'LineWidth', 1.5, 'MarkerSize', 7, ...
        'MarkerFaceColor', 'r', 'CapSize', 6);
    set(gca, 'YScale', 'log');
    xlabel('Crossover Probability CR');
    ylabel('Best Fitness (log)');
    title(funcNames{fi});
    grid on;
end
sgtitle('Effect of Crossover Probability CR on DE/rand/1 (D=30, F=0.5)', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, fullfile(fig_dir, 'fig4_CR_analysis.png'));
close;
fprintf('Figure 4 saved.\n');

%% 图5: F/CR收敛曲线
figure('Position', [50, 50, 1400, 800], 'Visible', 'off');
rep_idx = [1, 6];  % Sphere (index 1), Rastrigin (index 6)
rep_names = {'Sphere (f1)', 'Rastrigin (f13)'};

for idx = 1:2
    fi = rep_idx(idx);
    % F 收敛曲线
    subplot(2, 2, idx);
    for fv = 1:length(F_values)
        semilogy(F_results{fi, fv}.convergence, 'LineWidth', 1.2); hold on;
    end
    xlabel('Generation'); ylabel('Fitness (log)');
    title(sprintf('%s (varying F)', rep_names{idx}));
    legend(arrayfun(@(x) sprintf('F=%.1f', x), F_values, 'UniformOutput', false), ...
        'Location', 'best', 'FontSize', 6);
    grid on;

    % CR 收敛曲线
    subplot(2, 2, 2+idx);
    for cv = 1:length(CR_values)
        semilogy(CR_results{fi, cv}.convergence, 'LineWidth', 1.2); hold on;
    end
    xlabel('Generation'); ylabel('Fitness (log)');
    title(sprintf('%s (varying CR)', rep_names{idx}));
    legend(arrayfun(@(x) sprintf('CR=%.1f', x), CR_values, 'UniformOutput', false), ...
        'Location', 'best', 'FontSize', 6);
    grid on;
end
sgtitle('Effect of F and CR on Convergence Behavior', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, fullfile(fig_dir, 'fig5_F_CR_convergence.png'));
close;
fprintf('Figure 5 saved.\n');

fprintf('\n=== All figures regenerated successfully! ===\n');
