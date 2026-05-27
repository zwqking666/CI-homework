function [newpop] =selection(pop,fitness)
% 选择操作：轮盘赌的方法选择出新的种群个体

[row,col]=size(pop);
newpop = zeros(size(pop));

% TSP is a minimization problem: smaller distance = better fitness
% Convert to maximization using inverse (add epsilon to avoid div by zero)
invFit = 1 ./ (fitness + eps);

switch randi(2)
    case 1 %轮盘赌方法
        % Calculate selection probabilities
        p = invFit ./ sum(invFit);
        cumP = cumsum(p);

        for i = 1:row
            r = rand;
            idx = find(r <= cumP, 1);
            newpop(i,:) = pop(idx,:);
        end

    case 2 %竞标赛方法
        tournamentSize = 2;
        for i = 1:row
            candidates = randperm(row, tournamentSize);
            [~, bestIdx] = min(fitness(candidates));
            newpop(i,:) = pop(candidates(bestIdx),:);
        end

end % end function