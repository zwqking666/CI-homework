function data = load_numeric_matrix_from_mat(filePath)
%LOAD_NUMERIC_MATRIX_FROM_MAT 从 .mat 文件中提取最大的二维数值矩阵。

    if exist(filePath, 'file') ~= 2
        error('找不到数据文件：%s', filePath);
    end

    loaded = load(filePath);
    names = fieldnames(loaded);
    selectedName = '';
    selectedSize = -1;

    for i = 1:numel(names)
        value = loaded.(names{i});
        if isnumeric(value) && ismatrix(value)
            if numel(value) > selectedSize
                selectedName = names{i};
                selectedSize = numel(value);
            end
        end
    end

    if isempty(selectedName)
        error('%s 中没有二维数值矩阵。', filePath);
    end

    data = double(loaded.(selectedName));
    if any(~isfinite(data(:)))
        error('%s 中包含 NaN 或 Inf。', filePath);
    end
end

