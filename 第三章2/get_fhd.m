function fhd = get_fhd(funcId)
% 获取测试函数句柄（独立文件，供DE/GA预提取以避免每次评估都过if-elseif链）
switch funcId
    case 1
        fhd = @(x) sum(x.^2, 2);
    case 2
        fhd = @schwefel_102_h;
    case 3
        fhd = @schwefel_102_noise_h;
    case 4
        fhd = @(x) max(abs(x), [], 2);
    case 5
        fhd = @(x) sum(abs(x), 2) + prod(abs(x), 2);
    case 6
        fhd = @high_cond_elliptic_h;
    case 7
        fhd = @(x) sum(floor(x + 0.5).^2, 2);
    case 8
        fhd = @Schwefel_h;
    case 9
        fhd = @rosenbrock_h;
    case 10
        fhd = @quartic_h;
    case 11
        fhd = @griewank_h;
    case 12
        fhd = @ackley_h;
    case 13
        fhd = @(x) sum(x.^2 - 10.*cos(2.*pi.*x) + 10, 2);
    case 14
        fhd = @rastrigin_noncont_h;
    case 15
        fhd = @weierstrass_h;
    otherwise
        error('funcId must be 1~15');
end
end

%% ---------- 辅助子函数 ----------
function f = schwefel_102_h(x)
    [~, D] = size(x);
    f = zeros(size(x, 1), 1);
    for i = 1:D
        f = f + sum(x(:, 1:i), 2).^2;
    end
end

function f = schwefel_102_noise_h(x)
    [ps, D] = size(x);
    f = zeros(ps, 1);
    for i = 1:D
        f = f + sum(x(:, 1:i), 2).^2;
    end
    f = f .* (1 + 0.4 .* abs(randn(ps, 1)));
end

function f = high_cond_elliptic_h(x)
    [~, D] = size(x);
    a = 1e+6;
    f = zeros(size(x, 1), 1);
    for i = 1:D
        f = f + a.^((i-1)/(D-1)) .* x(:, i).^2;
    end
end

function f = Schwefel_h(x)
    [~, D] = size(x);
    f = 418.982887272433799 * D - sum(x .* sin(sqrt(abs(x))), 2);
end

function f = rosenbrock_h(x)
    [~, D] = size(x);
    f = sum(100 .* (x(:, 1:D-1).^2 - x(:, 2:D)).^2 + (x(:, 1:D-1) - 1).^2, 2);
end

function f = quartic_h(x)
    [~, D] = size(x);
    v = 1:D;
    f = sum(v .* x.^4, 2);
end

function f = griewank_h(x)
    [~, D] = size(x);
    f = 1;
    for i = 1:D
        f = f .* cos(x(:, i) ./ sqrt(i));
    end
    f = sum(x.^2, 2) ./ 4000 - f + 1;
end

function f = ackley_h(x)
    [~, D] = size(x);
    f = sum(x.^2, 2);
    f = 20 - 20 .* exp(-0.2 .* sqrt(f ./ D)) - exp(sum(cos(2 .* pi .* x), 2) ./ D) + exp(1);
end

function f = rastrigin_noncont_h(x)
    x = (abs(x) < 0.5) .* x + (abs(x) >= 0.5) .* (round(x .* 2) ./ 2);
    f = sum(x.^2 - 10 .* cos(2 .* pi .* x) + 10, 2);
end

function f = weierstrass_h(x)
    [~, D] = size(x);
    x = x + 0.5;
    a = 0.5; b = 3; kmax = 20;
    c1 = a.^(0:kmax);
    c2 = 2 * pi * b.^(0:kmax);
    f = zeros(size(x, 1), 1);
    c = -w_h(0.5, c1, c2);
    for i = 1:D
        f = f + w_h(x(:, i)', c1, c2)';
    end
    f = f + c * D;
end

function y = w_h(x, c1, c2)
    y = zeros(length(x), 1);
    for k = 1:length(x)
        y(k) = sum(c1 .* cos(c2 .* x(:, k)));
    end
end
