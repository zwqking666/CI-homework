function export_figure(fileName)
%EXPORT_FIGURE 保存当前图窗为 PNG，并尽量隐藏坐标区工具栏。

    fig = gcf;
    axesHandles = findall(fig, 'Type', 'axes');
    for i = 1:numel(axesHandles)
        try
            axesHandles(i).Toolbar.Visible = 'off';
        catch
        end
    end

    [folder, ~, ~] = fileparts(fileName);
    if exist(folder, 'dir') ~= 7
        mkdir(folder);
    end

    saveas(fig, fileName);
end

