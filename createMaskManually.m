function createMaskManually(imgPath)
img = imread(imgPath);

% 灰度图像，通道数：1
% 彩色图像(RGB图像)，通道数：3
[~, ~, channelNum] = size(img); % 获取掩码图像的通道数

% 检查掩码图像是否为灰度图像
if channelNum > 1
    img = rgb2gray(img); % 转换为灰度图像
end

screenSize = get(0, 'ScreenSize');
figWidth = 750;
figHeight = 750;
figX = (screenSize(3) - figWidth) / 2;
figY = (screenSize(4) - figHeight) / 2;

fig = figure('Position', [figX, figY, figWidth, figHeight], 'MenuBar', 'none', ...
    'Name', '手动绘制掩膜mask', 'NumberTitle', 'off');

uicontrol('Style', 'pushbutton', 'String', '保存掩膜mask', ...
    'Units', 'normalized', ...
    'Position', [0.1, 0.05, 0.35, 0.1], ...
    'FontSize', 10,...
    'Callback', @(src, event) saveMask(src));
uicontrol('Style', 'pushbutton', 'String', '查看掩膜mask', ...
    'Units', 'normalized', ...
    'Position', [0.55, 0.05, 0.35, 0.1], ...
    'FontSize', 10,...
    'Callback', @(src, event) viewMask(src));

axes('Position', [0.1, 0.2, 0.8, 0.8]);
imshow(img);
title('使用鼠标圈出掩膜mask');

% 使用 drawfreehand 绘制掩膜
fh = drawfreehand();

if isvalid(fh)  % 检查 fh 是否有效
    % 初始化掩膜
    mask = false(size(img));
    set(fig, 'UserData', struct('mask', mask, 'fh', fh));
end
end

function viewMask(src)
currentFig = get(src, 'Parent');
structData = get(currentFig, 'UserData');

if isfield(structData, 'fh')
    fh = structData.fh; % 获取 freehand 对象
    lmask = fh.createMask(); % 创建局部掩膜
    mask = structData.mask | lmask; % 将当前掩膜与总掩膜进行逻辑或操作

    figure('MenuBar', 'none');
    imshow(uint8(mask * 255));
    title('掩膜mask图像');
else
    errordlg('请先使用鼠标圈出掩膜mask，才能查看掩膜mask');
end
end

function saveMask(src)
currentFig = get(src, 'Parent');
structData = get(currentFig, 'UserData');

if isfield(structData, 'fh')
    fh = structData.fh;
    lmask = fh.createMask();
    mask = structData.mask | lmask;

    % 保存处理后的图像
    baseFileName = 'MaskManually';  % 基础文件名
    timeStamp = datestr(now,'yyyymmdd-HHMMSS');  % 获取当前时间的字符串
    suffix = '.png';

    % 目标保存路径
    targetDir = 'C:\Users\86173\Desktop\数图课设\test';

    % 检查目标路径是否存在
    if ~exist(targetDir, 'dir')
        % 如果不存在，使用当前文件的目录
        currentDir = fileparts(mfilename('fullpath'));  % 获取当前文件的目录
        targetDir = currentDir;  % 设置为当前目录
    end

    fullFileName = fullfile(targetDir, [baseFileName,'_', timeStamp, suffix]);
    imwrite(uint8(255 * mask), fullFileName);

    msgbox('处理后的图像已保存');
else
    errordlg('请先使用鼠标圈出掩膜mask，才能保存掩膜mask图像');
end
end





