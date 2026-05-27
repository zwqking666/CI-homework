function chapter2_report_singlefile()
%CHAPTER2_REPORT_SINGLEFILE 第二章实验报告单文件可运行版。
%
% 使用方法：
%   将本文件放在“报告代码”目录下，在 MATLAB 中运行：
%   chapter2_report_singlefile

    clearvars -except ans;
    clc;
    close all;

    codeDir = fileparts(mfilename('fullpath'));
    chapterDir = fileparts(codeDir);
    outputDir = fullfile(chapterDir, '实验报告输出');
    if exist(outputDir, 'dir') ~= 7
        mkdir(outputDir);
    end

    fprintf('===== 实验1：TSP穷举求解 =====\n');
    task1Summary = local_run_tsp_experiment(outputDir);
    disp(task1Summary);

    fprintf('\n===== 实验2：智能优化算法性能分析 =====\n');
    dataDir = fullfile(chapterDir, '实验2：智能优化算法性能分析', '实验数据结果');
    [task2Summary, rankTestTable] = local_analyze_optimizer_results(dataDir, outputDir);
    disp(task2Summary);
    disp(rankTestTable);

    fprintf('\n全部结果已保存到：%s\n', outputDir);
end

function summary = local_run_tsp_experiment(outputDir)
    rng(2026);
    cityCounts = 4:10;
    startCity = 1;
    coordinateScale = 100;
    repeatTimes = 3;

    bestDistances = zeros(numel(cityCounts), 1);
    elapsedTimes = zeros(numel(cityCounts), 1);
    routeCounts = zeros(numel(cityCounts), 1);
    bestRoutes = cell(numel(cityCounts), 1);

    warmupCoords = coordinateScale * rand(4, 2);
    local_brute_force_tsp(local_build_distance_matrix(warmupCoords), startCity);

    for i = 1:numel(cityCounts)
        n = cityCounts(i);
        coords = coordinateScale * rand(n, 2);
        distMat = local_build_distance_matrix(coords);

        trialTimes = zeros(repeatTimes, 1);
        for r = 1:repeatTimes
            timerStart = tic;
            [bestRoute, bestDistance, routeCount] = local_brute_force_tsp(distMat, startCity);
            trialTimes(r) = toc(timerStart);
        end

        bestDistances(i) = bestDistance;
        elapsedTimes(i) = median(trialTimes);
        routeCounts(i) = routeCount;
        bestRoutes{i} = mat2str(bestRoute);

        if n == cityCounts(end)
            local_draw_tsp_route(coords, bestRoute, fullfile(outputDir, 'task1_tsp_best_route.png'));
        end
    end

    summary = table(cityCounts(:), routeCounts, bestDistances, elapsedTimes, bestRoutes, ...
        'VariableNames', {'N', 'EnumeratedRoutes', 'BestDistance', 'TimeSeconds', 'BestRoute'});
    writetable(summary, fullfile(outputDir, 'task1_tsp_summary.csv'));

    figure('Color', 'w');
    yyaxis left;
    plot(summary.N, summary.TimeSeconds, 'o-', 'LineWidth', 1.5, 'MarkerSize', 6);
    ylabel('运行时间 / s');
    yyaxis right;
    semilogy(summary.N, summary.EnumeratedRoutes, 's--', 'LineWidth', 1.5, 'MarkerSize', 6);
    ylabel('枚举路径数 (log)');
    grid on;
    xlabel('城市数量 N');
    title('TSP穷举算法规模与运行代价');
    legend({'运行时间', '枚举路径数'}, 'Location', 'northwest');
    local_export_figure(fullfile(outputDir, 'task1_tsp_runtime.png'));
end

function distMat = local_build_distance_matrix(coords)
    n = size(coords, 1);
    distMat = zeros(n, n);
    for i = 1:n
        dx = coords(i, 1) - coords(:, 1);
        dy = coords(i, 2) - coords(:, 2);
        distMat(i, :) = sqrt(dx.^2 + dy.^2).';
    end
end

function [bestRoute, bestDistance, routeCount] = local_brute_force_tsp(distMat, startCity)
    n = size(distMat, 1);
    otherCities = setdiff(1:n, startCity, 'stable');
    routePermutations = perms(otherCities);
    routeCount = size(routePermutations, 1);

    bestDistance = inf;
    bestRoute = [];
    for i = 1:routeCount
        route = [startCity, routePermutations(i, :), startCity];
        distance = 0;
        for j = 1:(numel(route) - 1)
            distance = distance + distMat(route(j), route(j + 1));
        end

        if distance < bestDistance
            bestDistance = distance;
            bestRoute = route;
        end
    end
end

function local_draw_tsp_route(coords, route, fileName)
    figure('Color', 'w');
    plot(coords(:, 1), coords(:, 2), 'ko', ...
        'MarkerFaceColor', [0.20 0.55 0.85], 'MarkerSize', 7);
    hold on;
    plot(coords(route, 1), coords(route, 2), 'r-', 'LineWidth', 1.5);
    text(coords(:, 1) + 1.2, coords(:, 2) + 1.2, cellstr(num2str((1:size(coords, 1)).')), ...
        'FontSize', 9);
    axis equal;
    grid on;
    xlabel('x坐标');
    ylabel('y坐标');
    title('TSP最短闭合路径示例');
    local_export_figure(fileName);
end

function [summary, rankTestTable] = local_analyze_optimizer_results(dataDir, outputDir)
    algorithms = {'A', 'B', 'C', 'D'};
    fileNames = {'Results_A.mat', 'Results_B.mat', 'Results_C.mat', 'Results_D.mat'};
    finalValues = cell(numel(algorithms), 1);
    convergenceCurves = cell(numel(algorithms), 1);

    for i = 1:numel(algorithms)
        data = local_load_numeric_matrix_from_mat(fullfile(dataDir, fileNames{i}));
        if size(data, 1) ~= 10 && size(data, 2) == 10
            data = data.';
        end
        finalValues{i} = min(data, [], 2);
        convergenceCurves{i} = mean(data, 1);
    end

    summary = local_build_summary_table(algorithms, finalValues);
    writetable(summary, fullfile(outputDir, 'task2_summary.csv'));
    local_draw_boxplot(algorithms, finalValues, fullfile(outputDir, 'task2_boxplot.png'));
    local_draw_convergence_curves(algorithms, convergenceCurves, fullfile(outputDir, 'task2_convergence.png'));

    rankTestTable = local_pairwise_ranksum(algorithms, finalValues);
    writetable(rankTestTable, fullfile(outputDir, 'task2_ranksum.csv'));
end

function data = local_load_numeric_matrix_from_mat(filePath)
    loaded = load(filePath);
    names = fieldnames(loaded);
    selectedName = '';
    selectedSize = -1;
    for i = 1:numel(names)
        value = loaded.(names{i});
        if isnumeric(value) && ismatrix(value) && numel(value) > selectedSize
            selectedName = names{i};
            selectedSize = numel(value);
        end
    end
    if isempty(selectedName)
        error('%s 中没有二维数值矩阵。', filePath);
    end
    data = double(loaded.(selectedName));
end

function summary = local_build_summary_table(algorithms, finalValues)
    meanValue = zeros(numel(algorithms), 1);
    stdValue = zeros(numel(algorithms), 1);
    bestValue = zeros(numel(algorithms), 1);
    worstValue = zeros(numel(algorithms), 1);

    for i = 1:numel(algorithms)
        values = finalValues{i};
        meanValue(i) = mean(values);
        stdValue(i) = std(values);
        bestValue(i) = min(values);
        worstValue(i) = max(values);
    end

    summary = table(algorithms(:), meanValue, stdValue, bestValue, worstValue, ...
        'VariableNames', {'Algorithm', 'Mean', 'Std', 'Best', 'Worst'});
end

function local_draw_boxplot(algorithms, finalValues, fileName)
    values = [];
    groups = {};
    for i = 1:numel(algorithms)
        values = [values; finalValues{i}(:)]; %#ok<AGROW>
        groups = [groups; repmat(algorithms(i), numel(finalValues{i}), 1)]; %#ok<AGROW>
    end

    figure('Color', 'w');
    boxplot(values, groups);
    grid on;
    xlabel('算法');
    ylabel('最终最佳适应度');
    title('算法A-D收敛精度箱线图');
    local_export_figure(fileName);
end

function local_draw_convergence_curves(algorithms, convergenceCurves, fileName)
    colors = lines(numel(algorithms));
    lineStyles = {'-', '--', '-.', ':'};
    markers = {'o', 's', '^', 'd'};
    figure('Color', 'w');
    hold on;

    for i = 1:numel(algorithms)
        y = convergenceCurves{i};
        sampleIndex = unique(round(linspace(1, numel(y), min(2000, numel(y)))));
        markerIndex = unique(round(linspace(1, numel(sampleIndex), min(16, numel(sampleIndex)))));
        plot(sampleIndex, y(sampleIndex), 'Color', colors(i, :), ...
            'LineStyle', lineStyles{i}, 'LineWidth', 1.4);
        plot(sampleIndex(markerIndex), y(sampleIndex(markerIndex)), ...
            'Color', colors(i, :), 'LineStyle', 'none', ...
            'Marker', markers{i}, 'MarkerSize', 4);
    end

    grid on;
    xlabel('迭代评价次数');
    ylabel('10轮平均历史最优适应度');
    title('算法A-D在F1函数上的收敛曲线');
    legend(algorithms, 'Location', 'northeast');
    local_export_figure(fileName);
end

function rankTestTable = local_pairwise_ranksum(algorithms, finalValues)
    algorithm1 = {};
    algorithm2 = {};
    pValue = [];
    significant = [];
    alpha = 0.05;

    for i = 1:(numel(algorithms) - 1)
        for j = (i + 1):numel(algorithms)
            x = finalValues{i};
            y = finalValues{j};
            if exist('ranksum', 'file') == 2
                p = ranksum(x, y);
            else
                p = local_mann_whitney_pvalue(x, y);
            end
            algorithm1{end + 1, 1} = algorithms{i}; %#ok<AGROW>
            algorithm2{end + 1, 1} = algorithms{j}; %#ok<AGROW>
            pValue(end + 1, 1) = p; %#ok<AGROW>
            significant(end + 1, 1) = p < alpha; %#ok<AGROW>
        end
    end

    rankTestTable = table(algorithm1, algorithm2, pValue, logical(significant), ...
        'VariableNames', {'Algorithm1', 'Algorithm2', 'pValue', 'SignificantAt005'});
end

function p = local_mann_whitney_pvalue(x, y)
    x = x(:);
    y = y(:);
    n1 = numel(x);
    n2 = numel(y);
    n = n1 + n2;
    values = [x; y];

    [sortedValues, order] = sort(values);
    ranks = zeros(n, 1);
    tieSizes = [];
    k = 1;
    while k <= n
        j = k;
        while j < n && sortedValues(j + 1) == sortedValues(k)
            j = j + 1;
        end
        ranks(order(k:j)) = (k + j) / 2;
        tieSizes(end + 1) = j - k + 1; %#ok<AGROW>
        k = j + 1;
    end

    rankSum1 = sum(ranks(1:n1));
    u1 = rankSum1 - n1 * (n1 + 1) / 2;
    meanU = n1 * n2 / 2;
    tieCorrection = sum(tieSizes.^3 - tieSizes) / (n * (n - 1));
    sigmaU = sqrt(n1 * n2 * ((n + 1) - tieCorrection) / 12);
    if sigmaU == 0
        p = 1;
    else
        z = (u1 - meanU) / sigmaU;
        p = erfc(abs(z) / sqrt(2));
    end
end

function local_export_figure(fileName)
    fig = gcf;
    axesHandles = findall(fig, 'Type', 'axes');
    for i = 1:numel(axesHandles)
        try
            axesHandles(i).Toolbar.Visible = 'off';
        catch
        end
    end
    saveas(fig, fileName);
end

