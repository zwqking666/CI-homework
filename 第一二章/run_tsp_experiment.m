function summary = run_tsp_experiment(outputDir)
%RUN_TSP_EXPERIMENT 穷举法求解不同规模 TSP，并保存统计结果和图片。

    rng(2026);
    cityCounts = 4:10;
    startCity = 1;
    coordinateScale = 100;
    repeatTimes = 3;

    bestDistances = zeros(numel(cityCounts), 1);
    elapsedTimes = zeros(numel(cityCounts), 1);
    routeCounts = zeros(numel(cityCounts), 1);
    bestRoutes = cell(numel(cityCounts), 1);

    % 预热一次，减少 MATLAB 首次调用函数带来的计时扰动。
    warmupCoords = coordinateScale * rand(4, 2);
    warmupDist = build_distance_matrix(warmupCoords);
    brute_force_tsp(warmupDist, startCity);

    for i = 1:numel(cityCounts)
        n = cityCounts(i);
        coords = coordinateScale * rand(n, 2);
        distMat = build_distance_matrix(coords);

        trialTimes = zeros(repeatTimes, 1);
        for r = 1:repeatTimes
            timerStart = tic;
            [bestRoute, bestDistance, routeCount] = brute_force_tsp(distMat, startCity);
            trialTimes(r) = toc(timerStart);
        end

        bestDistances(i) = bestDistance;
        elapsedTimes(i) = median(trialTimes);
        routeCounts(i) = routeCount;
        bestRoutes{i} = mat2str(bestRoute);

        if n == cityCounts(end)
            draw_tsp_route(coords, bestRoute, fullfile(outputDir, 'task1_tsp_best_route.png'));
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
    export_figure(fullfile(outputDir, 'task1_tsp_runtime.png'));
end

function distMat = build_distance_matrix(coords)
    n = size(coords, 1);
    distMat = zeros(n, n);
    for i = 1:n
        dx = coords(i, 1) - coords(:, 1);
        dy = coords(i, 2) - coords(:, 2);
        distMat(i, :) = sqrt(dx.^2 + dy.^2).';
    end
end

function draw_tsp_route(coords, route, fileName)
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
    export_figure(fileName);
end

