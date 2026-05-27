function [summary, rankTestTable] = analyze_optimizer_results(dataDir, outputDir)
%ANALYZE_OPTIMIZER_RESULTS 分析算法 A-D 在 F1 函数上的收敛性能。

    algorithms = {'A', 'B', 'C', 'D'};
    fileNames = {'Results_A.mat', 'Results_B.mat', 'Results_C.mat', 'Results_D.mat'};
    finalValues = cell(numel(algorithms), 1);
    convergenceCurves = cell(numel(algorithms), 1);

    for i = 1:numel(algorithms)
        filePath = fullfile(dataDir, fileNames{i});
        data = load_numeric_matrix_from_mat(filePath);

        if size(data, 1) ~= 10 && size(data, 2) == 10
            data = data.';
        end
        if size(data, 1) ~= 10
            warning('%s 的行数为 %d，不是题目描述的10轮实验。', fileNames{i}, size(data, 1));
        end

        % 每行是一轮独立实验的历史最优适应度，最小值即该轮最终最佳收敛精度。
        finalValues{i} = min(data, [], 2);
        convergenceCurves{i} = mean(data, 1);
    end

    summary = build_summary_table(algorithms, finalValues);
    writetable(summary, fullfile(outputDir, 'task2_summary.csv'));

    draw_boxplot(algorithms, finalValues, fullfile(outputDir, 'task2_boxplot.png'));
    draw_convergence_curves(algorithms, convergenceCurves, fullfile(outputDir, 'task2_convergence.png'));

    rankTestTable = pairwise_ranksum(algorithms, finalValues);
    writetable(rankTestTable, fullfile(outputDir, 'task2_ranksum.csv'));
end

function summary = build_summary_table(algorithms, finalValues)
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

function draw_boxplot(algorithms, finalValues, fileName)
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
    export_figure(fileName);
end

function draw_convergence_curves(algorithms, convergenceCurves, fileName)
    colors = lines(numel(algorithms));
    lineStyles = {'-', '--', '-.', ':'};
    markers = {'o', 's', '^', 'd'};

    figure('Color', 'w');
    hold on;
    for i = 1:numel(algorithms)
        y = convergenceCurves{i};
        sampleIndex = unique(round(linspace(1, numel(y), min(2000, numel(y)))));
        markerIndex = unique(round(linspace(1, numel(sampleIndex), min(16, numel(sampleIndex)))));
        plot(sampleIndex, y(sampleIndex), ...
            'Color', colors(i, :), ...
            'LineStyle', lineStyles{i}, ...
            'LineWidth', 1.4);
        plot(sampleIndex(markerIndex), y(sampleIndex(markerIndex)), ...
            'Color', colors(i, :), ...
            'LineStyle', 'none', ...
            'Marker', markers{i}, ...
            'MarkerSize', 4);
    end

    grid on;
    xlabel('迭代评价次数');
    ylabel('10轮平均历史最优适应度');
    title('算法A-D在F1函数上的收敛曲线');
    legend(algorithms, 'Location', 'northeast');
    export_figure(fileName);
end

function rankTestTable = pairwise_ranksum(algorithms, finalValues)
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
                p = mann_whitney_pvalue(x, y);
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

function p = mann_whitney_pvalue(x, y)
%MANN_WHITNEY_PVALUE 无 ranksum 函数时使用的双侧近似检验。
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

