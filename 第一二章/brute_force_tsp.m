function [bestRoute, bestDistance, routeCount] = brute_force_tsp(distMat, startCity)
%BRUTE_FORCE_TSP 固定起点的 TSP 穷举求解。
%
% 输入：
%   distMat   - N x N 城市距离矩阵；
%   startCity - 固定出发和返回城市编号。
%
% 输出：
%   bestRoute    - 最短闭合路径，如 [1 3 2 4 1]；
%   bestDistance - 最短路径长度；
%   routeCount   - 枚举路径数量，固定起点时为 (N-1)!。

    if nargin < 2
        startCity = 1;
    end

    n = size(distMat, 1);
    if size(distMat, 2) ~= n
        error('distMat 必须是方阵。');
    end
    if startCity < 1 || startCity > n || startCity ~= floor(startCity)
        error('startCity 必须是 1 到 N 之间的整数。');
    end

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

