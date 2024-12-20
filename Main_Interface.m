function Main_Interface()
clc
screenSize = get(0, 'ScreenSize');
figWidth = 500;
figHeight = 500;
figX = (screenSize(3) - figWidth) / 2; % X轴居中  screenSize(3);   获取宽度
figY = (screenSize(4) - figHeight) / 2; % Y轴居中  screenSize(4);   获取高度

figure('Position', [figX, figY, figWidth, figHeight], 'MenuBar', 'none', ...
    'Name', '主界面', 'NumberTitle', 'off');

% 创建按钮，使用normalized单位来确保位置随窗口变化而相应调整
uicontrol('Style', 'pushbutton', 'String', '偏微分方程', ...
    'Units', 'normalized', ...
    'Position', [0.35, 0.75,  0.25, 0.13], ...
    'Callback', @(src, event) toPDE_Figure());

uicontrol('Style', 'pushbutton', 'String', '中值扩散', ...
    'Units', 'normalized', ...
    'Position', [0.35, 0.5, 0.25, 0.13], ...
    'Callback', @(src, event) toMedian_Figure());

uicontrol('Style', 'pushbutton', 'String', '高斯加权平均', ...
    'Units', 'normalized', ...
    'Position', [0.35, 0.25,  0.25, 0.13], ...
    'Callback', @(src, event) toGauss_Figure());

uicontrol('Style', 'pushbutton', 'String', '创建掩码mask图像', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.5, 0.25, 0.13], ...
    'Callback', @(src, event) toCreateMask_Figure());

textStr='程序使用说明:先使用原始图像创建一张掩码mask图像(要修复的区域)，在三个图像修复方法(偏微分方程,中值扩散,高斯加权平均)中传入原始图像和mask图像，即可进行图像修复。';
uicontrol('Style', 'text', ...
    'String', textStr, ...
    'Units', 'normalized',...
    'Position', [0.65, 0.2, 0.3, 0.5], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');

%！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
% 在“创建掩码 Mask 图像”上方添加按钮
uicontrol('Style', 'pushbutton', ...
          'Units', 'normalized', ...
          'Position', [0.05, 0.25, 0.25, 0.13], ... % 自行调整位置
          'String', '失焦模糊', ...
          'Callback', @(src, event) toCreateWiener_Figure());

% 在“创建掩码 Mask 图像”下方添加按钮
uicontrol('Style', 'pushbutton', ...
          'Units', 'normalized', ...
          'Position', [0.05, 0.75, 0.25, 0.13], ... % 自行调整位置
          'String', '运动模糊', ...
          'Callback', @(src, event) toCreateLY_Figure());

end

function toCreateWiener_Figure()
global radius smooth dering;  % 声明全局变量
screenSize = get(0, 'ScreenSize');
figWidth = 700;
figHeight = 500;
figX = (screenSize(3) - figWidth) / 2;
figY = (screenSize(4) - figHeight) / 2;

% 定义默认值
radius = 15.4;  % 默认半径
smooth = 50;   % 默认平滑值
dering = 'On'; % 默认去除环效应

generalFigure = figure('Position', [figX, figY, figWidth, figHeight], ...
    'MenuBar', 'none', 'Name','聚焦模糊复原', 'NumberTitle', 'off');

uicontrol('Style', 'pushbutton', 'String', '传入原始图像', ...
    'Units', 'normalized', ...
    'Position', [0.28, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) loadImage(src, 'original'));

uicontrol('Style', 'pushbutton', 'String', '退出', ...
    'Units', 'normalized', ...
    'Position', [0.65, 0.12, 0.3, 0.1], ...
    'Callback', @(src, event) close(generalFigure));



% radius输入框及标签
uicontrol('Style', 'text', ...
    'String', 'Radius:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.7, 0.2, 0.05], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.65, 0.2, 0.05], ...
    'String', num2str(radius), ...
    'Callback', @(src, event) setRadius(src));

% smooth输入框及标签
uicontrol('Style', 'text', ...
    'String', 'Smooth:', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.6, 0.2, 0.05], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.55, 0.2, 0.05], ...
    'String', num2str(smooth), ...
    'Callback', @(src, event) setSmooth(src));

% dering输入框及标签
uicontrol('Style', 'text', ...
    'String', 'Dering (On/Off):', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.5, 0.2, 0.05], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.45, 0.2, 0.05], ...
    'String', dering, ...
    'Callback', @(src, event) setDering(src));

uicontrol('Style', 'pushbutton', 'String', '执行wiener去模糊', ...
    'Units', 'normalized', ...
    'Position', [0.65, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) execute_wiener(src,radius,smooth,dering));

%参数解释说明
% 在右侧空白区域添加描述文字

uicontrol('Style', 'text', ...
    'String', 'Radius: 用于生成psf的半径。', ...
    'Units', 'normalized', ...
    'Position', [0.75, 0.75, 0.2, 0.1], ...
    'FontSize', 10, ...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'text', ...
    'String', 'Smooth: 平滑因子，越大越平滑也损失更多细节，越小越细节但容易引入噪声。', ...
    'Units', 'normalized', ...
    'Position', [0.75, 0.66, 0.2, 0.12], ...
    'FontSize', 10, ...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'text', ...
    'String', 'Dering: 是否去除环效应。', ...
    'Units', 'normalized', ...
    'Position', [0.75, 0.55, 0.2, 0.1], ...
    'FontSize', 10, ...
    'HorizontalAlignment', 'left');


% axes用于显示加载的图像
originalImageAxes = axes('Position', [0.43, 0.42, 0.3, 0.38]);


% 隐藏原始图像的坐标轴数字
set(originalImageAxes, 'XTick', [], 'YTick', []);


% 将axes和参数变量保存到图形的UserData
set(generalFigure, 'UserData', struct('originalAxes', originalImageAxes, ...
    'originalImagePath', [], ...
    'maskImagePath', [], ...
    'radius', radius, ...
    'smooth', smooth, ...
    'dering', dering));

    % 回调函数
    function setRadius(src)
        val = str2double(src.String);
        if isnan(val) || val <= 0
            errordlg('请输入一个正数作为Radius!', '输入错误');
            src.String = num2str(radius);
        else
            radius = val;
        end
    end

    function setSmooth(src)
        val = str2double(src.String);
        if isnan(val) || val < 0
            errordlg('请输入一个非负数作为Smooth!', '输入错误');
            src.String = num2str(smooth);
        else
            smooth = val;
        end
    end

    function setDering(src)
        val = lower(strtrim(src.String));
        if ~ismember(val, {'on', 'off'})
            errordlg('请输入On或Off作为Dering的值!', '输入错误');
            src.String = dering;
        else
            dering = val;
        end
    end
end

function execute_wiener(src,radius,smooth,dering)
global radius smooth dering;  % 声明全局变量
currentFig = src.Parent;
structData = get(currentFig, 'UserData');

% 获取已加载的图像
if isfield(structData, 'originalImagePath') && ~isempty(structData.originalImagePath)
    originalImagePath = structData.originalImagePath; % 获取原始图像路径

    Demo_out_of_focus_deblur(originalImagePath,radius,smooth,dering);
else
    errordlg('请先传入原始图像');
end
end

%1111111111111111111111111111111111111111111111111111111111111111111111
function toCreateLY_Figure()
screenSize = get(0, 'ScreenSize');
figWidth = 700;
figHeight = 500;
figX = (screenSize(3) - figWidth) / 2;
figY = (screenSize(4) - figHeight) / 2;

% 定义默认值
len = 60;  % 模糊长度
theta = 315;   % 模糊角度
IterNum = 40; % 迭代次数

generalFigure = figure('Position', [figX, figY, figWidth, figHeight], ...
    'MenuBar', 'none', 'Name','运动模糊复原', 'NumberTitle', 'off');

uicontrol('Style', 'pushbutton', 'String', '传入原始图像', ...
    'Units', 'normalized', ...
    'Position', [0.28, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) loadImage(src, 'original'));

uicontrol('Style', 'pushbutton', 'String', '退出', ...
    'Units', 'normalized', ...
    'Position', [0.65, 0.12, 0.3, 0.1], ...
    'Callback', @(src, event) close(generalFigure));

% len输入框及标签
uicontrol('Style', 'text', ...
    'String', '模糊长度', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.7, 0.2, 0.05], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.65, 0.2, 0.05], ...
    'String', num2str(len), ...
    'Callback', @(src, event) setlen(src));

% theta输入框及标签
uicontrol('Style', 'text', ...
    'String', '模糊角度', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.6, 0.2, 0.05], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.55, 0.2, 0.05], ...
    'String', num2str(theta), ...
    'Callback', @(src, event) settheta(src));

% IterNum输入框及标签
uicontrol('Style', 'text', ...
    'String', '迭代次数', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.5, 0.2, 0.05], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');

uicontrol('Style', 'edit', ...
    'Units', 'normalized', ...
    'Position', [0.05, 0.45, 0.2, 0.05], ...
    'String', num2str(IterNum), ...
    'Callback', @(src, event) setIterNum(src));

% axes用于显示加载的图像
originalImageAxes = axes('Position', [0.43, 0.42, 0.3, 0.38]);

% 隐藏原始图像的坐标轴数字
set(originalImageAxes, 'XTick', [], 'YTick', []);

% 将axes和参数变量保存到图形的UserData
set(generalFigure, 'UserData', struct('originalAxes', originalImageAxes, ...
    'originalImagePath', [], ...
    'maskImagePath', [], ...
    'len', len, ...
    'theta', theta, ...
    'IterNum', IterNum));

% 回调函数
function setlen(src)
    val = str2double(src.String);
    if isnan(val) || val <= 0
        errordlg('请输入一个正数作为len!', '输入错误');
        src.String = num2str(len);
    else
        len = val;
        updateUserData();  % 更新UserData
    end
end

function settheta(src)
    val = str2double(src.String);
    if isnan(val) || val < 0
        errordlg('请输入一个非负数作为theta!', '输入错误');
        src.String = num2str(theta);
    else
        theta = val;
        updateUserData();  % 更新UserData
    end
end

function setIterNum(src)
    val = str2double(strtrim(src.String)); 
    if isnan(val) || val < 0 || floor(val) ~= val
        errordlg('请输入非负整数作为 IterNum 的值!', '输入错误');
        src.String = num2str(IterNum);
    else
        IterNum = val;
        updateUserData();  % 更新UserData
    end
end

% 更新UserData中的值
function updateUserData()
    structData = get(gcf, 'UserData');
    structData.len = len;
    structData.theta = theta;
    structData.IterNum = IterNum;
    set(gcf, 'UserData', structData);  % 更新UserData
end

uicontrol('Style', 'pushbutton', 'String', '执行运动去模糊', ...
    'Units', 'normalized', ...
    'Position', [0.65, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) execute_LY(src));
end

function execute_LY(src)
currentFig = src.Parent;
structData = get(currentFig, 'UserData');

% 获取更新后的参数
len = structData.len;
theta = structData.theta;
IterNum = structData.IterNum;

% 获取已加载的图像
if isfield(structData, 'originalImagePath') && ~isempty(structData.originalImagePath)
    originalImagePath = structData.originalImagePath; % 获取原始图像路径
    % 调用目标函数
    Demo_motion_deblur(originalImagePath,len,theta,IterNum);
else
    errordlg('请先传入原始图像');
end
end




function toCreateMask_Figure()
screenSize = get(0, 'ScreenSize');
figWidth = 500;
figHeight = 500;
figX = (screenSize(3) - figWidth) / 2;
figY = (screenSize(4) - figHeight) / 2;

createMask_Figure = figure('Position', [figX, figY, figWidth, figHeight], 'MenuBar', 'none', ...
    'Name', '创建mask界面', 'NumberTitle', 'off');

uicontrol('Style', 'pushbutton', 'String', '手动绘制mask', ...
    'Units', 'normalized', ...
    'Position', [0.1, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) execute_createMaskManually(src));

uicontrol('Style', 'pushbutton', 'String', '根据图像中的颜色生成mask', ...
    'Units', 'normalized', ...
    'Position', [0.55, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event)execute_getColor_getText(src));

uicontrol('Style', 'pushbutton', 'String', '传入原始图像', ...
    'Units', 'normalized', 'Position', [0.05, 0.5, 0.3, 0.1], ...
    'Callback', @(src, event) loadImage(src,'original'));

uicontrol('Style', 'pushbutton', 'String', '退出', ...
    'Units', 'normalized','Position', [0.1, 0.12, 0.3, 0.1], ...
    'Callback', @(src, event) close(createMask_Figure));

originalImageAxes = axes('Parent', createMask_Figure, 'Units', 'normalized', ...
    'Position', [0.42, 0.42,0.45, 0.45]);

set(originalImageAxes, 'XTick', [], 'YTick', []);

set(createMask_Figure, 'UserData', struct('originalAxes', originalImageAxes,'originalImagePath',[]));
end

function execute_getColor_getText(src)
currentFig = get(src, 'Parent');
structData = get(currentFig, 'UserData');
% 获取已加载的图像
if isfield(structData, 'originalImagePath') && ~isempty(structData.originalImagePath)
    originalImagePath = structData.originalImagePath;
    getColor_getText(originalImagePath);
else
    errordlg('请先传入原始图像');
end
end

function execute_createMaskManually(src)
currentFig = get(src, 'Parent');
structData = get(currentFig, 'UserData');
% 获取已加载的图像
if isfield(structData, 'originalImagePath') && ~isempty(structData.originalImagePath)
    originalImagePath = structData.originalImagePath;
    createMaskManually(originalImagePath);
else
    errordlg('请先传入原始图像');
end
end

function toGauss_Figure()
screenSize = get(0, 'ScreenSize');
figWidth = 700;
figHeight = 500;
figX = (screenSize(3) - figWidth) / 2;
figY = (screenSize(4) - figHeight) / 2;
Gauss_Figure = figure('Position', [figX, figY, figWidth, figHeight], ...
    'MenuBar', 'none', 'Name', '高斯加权平均界面', 'NumberTitle', 'off');

uicontrol('Style', 'pushbutton', 'String', '传入原始图像', ...
    'Units', 'normalized',...
    'Position', [0.28, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) loadImage(src, 'original'));

uicontrol('Style', 'pushbutton', 'String', '传入mask图像', ...
    'Units', 'normalized',...
    'Position', [0.65, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) loadImage(src, 'mask'));

uicontrol('Style', 'pushbutton', 'String', '退出', ...
    'Units', 'normalized',...
    'Position', [0.28, 0.12, 0.3, 0.1], ...
    'Callback', @(src, event) close(Gauss_Figure));

uicontrol('Style', 'pushbutton', 'String', '执行高斯加权平均', ...
    'Units', 'normalized',...
    'Position', [0.65, 0.12, 0.3, 0.1], ...
    'Callback', @(src, event)execute_GaussWeightAverage(src));
%默认滤波器
filter = [0.073235 0.176765 0.073235;0.176765 0 0.176765;0.073235 0.176765 0.073235];
% 创建下拉框（弹出菜单）
options = {'边缘平滑滤波器(默认)', '均匀平滑滤波器', '标准高斯滤波器','均值滤波器'};
uicontrol('Style', 'popupmenu', ...
    'Units', 'normalized',...
    'String', options, ...
    'Position', [0.05, 0.45, 0.18, 0.3], ...
    'Callback', @(src, event) selectFilter(src));
% 默认迭代次数
iteration_Gauss = 120;
% 创建一个文本框
uicontrol('Style', 'edit', ...
    'Units', 'normalized',...
    'Position', [0.05, 0.42, 0.15, 0.1], ...
    'String', num2str(iteration_Gauss), ... % 设置默认数字
    'Callback', @(src, event) validateIterInput(src, iteration_Gauss));

uicontrol('Style', 'text', ...
    'String', '迭代次数(建议大于100次)', ...
    'Units', 'normalized',...
    'Position', [0.05, 0.52, 0.2, 0.08], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');

% 创建两个axes用于显示加载的图像
originalImageAxes = axes('Position', [0.28, 0.42, 0.3, 0.38]);
maskImageAxes = axes('Position', [0.65, 0.42, 0.3, 0.38]);
% 隐藏原始图像的坐标轴数字
set(originalImageAxes, 'XTick', [], 'YTick', []);
set(maskImageAxes, 'XTick', [], 'YTick', []);
% 将axes保存到图形的UserData
set(Gauss_Figure, 'UserData', struct('originalAxes', originalImageAxes, ...
    'maskAxes', maskImageAxes,...
    'originalImagePath',[],...
    'maskImagePath',[],...
    'filter',filter,...
    'iteration_Gauss',iteration_Gauss));
end

function validateIterInput(src, defauIterInput)
currentFig = get(src, 'Parent');
structData = get(currentFig, 'UserData');

% 获取输入字符串并转换为数字
inputStr = get(src, 'String');
inputValue = str2double(inputStr);

% 检查输入是否有效：必须是正整数
if isempty(inputStr) || isnan(inputValue) || inputValue <= 0 || mod(inputValue, 1) ~= 0
    % 如果输入无效或文本框为空，设置为默认数字
    errordlg('输入格式错误，请输入一个正整数');
    % 重置为默认数字
    set(src, 'String', num2str(defauIterInput));

    if isfield(structData, 'iteration_Gauss') && ~isempty(structData.iteration_Gauss)
        structData.iteration_Gauss = defauIterInput;
    elseif isfield(structData, 'iteration_PDE') && ~isempty(structData.iteration_PDE)
        structData.iteration_PDE = defauIterInput;
    end

else

    if isfield(structData, 'iteration_Gauss') && ~isempty(structData.iteration_Gauss)
        structData.iteration_Gauss = inputValue;
    elseif isfield(structData, 'iteration_PDE') && ~isempty(structData.iteration_PDE)
        structData.iteration_PDE = inputValue;
    end

end

% 更新 UserData
set(currentFig, 'UserData', structData);
% display(structData)
end

function validateKernInput(src, defauKernInput)
currentFig = get(src, 'Parent');
structData = get(currentFig, 'UserData');

% 获取输入字符串并转换为数字
inputStr = get(src, 'String');
inputValue = str2double(inputStr);

% 检查输入是否有效：必须是大于3的正整数
if isempty(inputStr) || isnan(inputValue) || inputValue <= 3 || mod(inputValue, 1) ~= 0
    % 如果输入无效或文本框为空，设置为默认数字
    errordlg('输入格式错误，卷积核的大小必须大于3');
    % 重置为默认数字
    set(src, 'String', num2str(defauKernInput));
    structData.convoKernel = defauKernInput;
else
    structData.convoKernel = inputValue;
end

% 更新 UserData
set(currentFig, 'UserData', structData);
% display(structData)
end

function validateThresholdInput(src, defauThreshInput)
currentFig = get(src, 'Parent');
structData = get(currentFig, 'UserData');

% 获取输入字符串并转换为数字
inputStr = get(src, 'String');
inputValue = str2double(inputStr);

if isempty(inputStr) || isnan(inputValue)% || inputValue <= 3 || mod(inputValue, 1) ~= 0
    % 如果输入无效或文本框为空，设置为默认数字
    errordlg('输入格式错误');
    % 重置为默认数字
    set(src, 'String', num2str(defauThreshInput));
    structData.thresh_PDE = defauThreshInput;
else

    structData.thresh_PDE = inputValue;
end


% 更新 UserData
set(currentFig, 'UserData', structData);
% display(structData)
end


function execute_GaussWeightAverage(src)
currentFig = get(src, 'Parent');
structData = get(currentFig, 'UserData');
% 获取已加载的图像
if isfield(structData, 'originalImagePath') && ~isempty(structData.originalImagePath) ...
        && isfield(structData, 'maskImagePath') && ~isempty(structData.maskImagePath)

    originalImagePath = structData.originalImagePath;
    maskImagePath = structData.maskImagePath;
    iteration_Gauss=structData.iteration_Gauss;
    filter=structData.filter;

    GaussWeightAverage(originalImagePath,maskImagePath,filter,iteration_Gauss);

else
    errordlg('请先传入原始图像和mask图像，(高斯加权平均)');
end
end

function selectFilter(src)
currentFig = get(src, 'Parent');
structData = get(currentFig, 'UserData');

selectedIndex = src.Value;  % 获取选择的索引（从 1 开始）
selectedOption = src.String{selectedIndex};  % 获取所选的选项

switch selectedOption
    case '边缘平滑滤波器(默认)'
        defaultFilter = [0.0732 0.1767 0.0732;0.1767 0 0.1767;0.0732 0.1767 0.0732];
        structData.filter=defaultFilter;
        % disp('边缘平滑滤波器(默认)');

    case '均匀平滑滤波器'
        smoothFilter=[0.125 0.125 0.125;0.125 0 0.125;0.125 0.125 0.125];
        structData.filter=smoothFilter;
        % disp('均匀平滑滤波器' );

    case '标准高斯滤波器'
        standardGauss=[1/16 2/16 1/16;2/16 4/16 2/16;1/16 2/16 1/16];
        structData.filter=standardGauss;
        % disp('标准高斯滤波器' );

    case '均值滤波器'
        averageFilter=[1/9 1/9 1/9;1/9 1/9 1/9;1/9 1/9 1/9];
        structData.filter=averageFilter;
        % disp('均值滤波器' );

    otherwise
        disp('switch-case语句有逻辑错误');
end

set(currentFig, 'UserData', structData);
end

function toMedian_Figure()
screenSize = get(0, 'ScreenSize');
figWidth = 700;
figHeight = 500;
figX = (screenSize(3) - figWidth) / 2;
figY = (screenSize(4) - figHeight) / 2;

generalFigure = figure('Position', [figX, figY, figWidth, figHeight], ...
    'MenuBar', 'none', 'Name','中值扩散界面', 'NumberTitle', 'off');

uicontrol('Style', 'pushbutton', 'String', '传入原始图像', ...
    'Units', 'normalized', ...
    'Position', [0.28, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) loadImage(src, 'original'));

uicontrol('Style', 'pushbutton', 'String', '传入mask图像', ...
    'Units', 'normalized', ...
    'Position', [0.65, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) loadImage(src, 'mask'));

uicontrol('Style', 'pushbutton', 'String', '退出', ...
    'Units', 'normalized', ...
    'Position', [0.28, 0.12, 0.3, 0.1], ...
    'Callback', @(src, event) close(generalFigure));

uicontrol('Style', 'pushbutton', 'String', '执行中值扩散', ...
    'Units', 'normalized', ...
    'Position', [0.65, 0.12, 0.3, 0.1], ...
    'Callback', @(src,event)execute_MedianDiffusion(src));

% 默认卷积核的大小
convoKernel = 40;

uicontrol('Style', 'edit', ...
    'Units', 'normalized',...
    'Position', [0.05, 0.42, 0.15, 0.1], ...
    'String', num2str(convoKernel), ...
    'Callback', @(src, event) validateKernInput(src, convoKernel));

uicontrol('Style', 'text', ...
    'String', '卷积核的大小(建议大于30)', ...
    'Units', 'normalized',...
    'Position', [0.05, 0.52, 0.2, 0.08], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');


% axes用于显示加载的图像
originalImageAxes = axes('Position', [0.28, 0.42, 0.3, 0.38]);
maskImageAxes = axes('Position', [0.65, 0.42, 0.3, 0.38]);
% 隐藏原始图像的坐标轴数字
set(originalImageAxes, 'XTick', [], 'YTick', []);
set(maskImageAxes, 'XTick', [], 'YTick', []);

% 将axes保存到图形的UserData
set(generalFigure, 'UserData', struct('originalAxes', originalImageAxes, ...
    'maskAxes', maskImageAxes,...
    'originalImagePath',[],...
    'maskImagePath',[],...
    'convoKernel',convoKernel));
end

function toPDE_Figure()
screenSize = get(0, 'ScreenSize');
figWidth = 700;
figHeight = 500;
figX = (screenSize(3) - figWidth) / 2;
figY = (screenSize(4) - figHeight) / 2;

generalFigure = figure('Position', [figX, figY, figWidth, figHeight], ...
    'MenuBar', 'none', 'Name','偏微分方程界面', 'NumberTitle', 'off');

uicontrol('Style', 'pushbutton', 'String', '传入原始图像', ...
    'Units', 'normalized', ...
    'Position', [0.28, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) loadImage(src, 'original'));

uicontrol('Style', 'pushbutton', 'String', '传入mask图像', ...
    'Units', 'normalized', ...
    'Position', [0.65, 0.25, 0.3, 0.1], ...
    'Callback', @(src, event) loadImage(src, 'mask'));

uicontrol('Style', 'pushbutton', 'String', '退出', ...
    'Units', 'normalized', ...
    'Position', [0.28, 0.12, 0.3, 0.1], ...
    'Callback', @(src, event) close(generalFigure));

uicontrol('Style', 'pushbutton', 'String', '执行偏微分方程', ...
    'Units', 'normalized', ...
    'Position', [0.65, 0.12, 0.3, 0.1], ...
    'Callback', @(src,event)execute_PDE_Inpaint(src));

% 默认阈值
thresh_PDE=0;


uicontrol('Style', 'edit', ...
    'Units', 'normalized',...
    'Position', [0.05, 0.65, 0.15, 0.1], ...
    'String', num2str(thresh_PDE), ...
    'Callback', @(src, event) validateThresholdInput(src, thresh_PDE));

uicontrol('Style', 'text', ...
    'String', '阈值：正阈值越大，修复区域越白。负阈值越小，修复区域越黑。(一般图像，阈值为0效果较好)', ...
    'Units', 'normalized',...
    'Position', [0.05, 0.75, 0.2, 0.16], ...
    'FontSize', 10, ...
    'HorizontalAlignment', 'left');

% 默认迭代次数
iteration_PDE = 5000;

uicontrol('Style', 'edit', ...
    'Units', 'normalized',...
    'Position', [0.05, 0.42, 0.15, 0.1], ...
    'String', num2str(iteration_PDE), ...
    'Callback', @(src, event) validateIterInput(src, iteration_PDE));

uicontrol('Style', 'text', ...
    'String', '偏微分迭代次数(建议大于5000次)', ...
    'Units', 'normalized',...
    'Position', [0.05, 0.52, 0.2, 0.08], ...
    'FontSize', 12, ...
    'HorizontalAlignment', 'left');


% axes用于显示加载的图像
originalImageAxes = axes('Position', [0.28, 0.42, 0.3, 0.38]);
maskImageAxes = axes('Position', [0.65, 0.42, 0.3, 0.38]);
% 隐藏原始图像的坐标轴数字
set(originalImageAxes, 'XTick', [], 'YTick', []);
set(maskImageAxes, 'XTick', [], 'YTick', []);

% 将axes保存到图形的UserData
set(generalFigure, 'UserData', struct('originalAxes', originalImageAxes, ...
    'maskAxes', maskImageAxes,...
    'originalImagePath',[],...
    'maskImagePath',[],...
    'iteration_PDE',iteration_PDE,...
    'thresh_PDE',thresh_PDE));
end


function loadImage(src, imageType)
currentFig = src.Parent;
structData = get(currentFig, 'UserData');

[filename, pathname] = uigetfile({'*.png;*.jpg;*.bmp', '选择文件(*.png,*.jpg,*.bmp)'});

if isequal(filename, 0)
    return; % 用户取消选择
end

img = imread(fullfile(pathname, filename));

% 根据imageType决定加载的图像
if strcmp(imageType, 'original')
    axes(structData.originalAxes);
    imshow(img);
    structData.originalImagePath = fullfile(pathname, filename); % 保存原始图像路径
    % structData.originalImage = img;  % 保存原始图像

elseif strcmp(imageType, 'mask')
    axes(structData.maskAxes);
    imshow(img);
    structData.maskImagePath = fullfile(pathname, filename); % 保存mask图像路径
    % structData.maskImage = img;  % 保存mask图像

end

set(currentFig, 'UserData', structData);
end

function execute_PDE_Inpaint(src)
currentFig = src.Parent;
structData = get(currentFig, 'UserData');

% 获取已加载的图像
if isfield(structData, 'originalImagePath') && ~isempty(structData.originalImagePath) ...
        && isfield(structData, 'maskImagePath') && ~isempty(structData.maskImagePath)

    originalImagePath = structData.originalImagePath; % 获取原始图像路径
    maskImagePath = structData.maskImagePath; % 获取mask图像路径
    iteration_PDE=structData.iteration_PDE;
    thresh_PDE=structData.thresh_PDE;

    PDE_Inpaint(originalImagePath,maskImagePath,iteration_PDE,thresh_PDE);
else
    errordlg('请先传入原始图像和mask图像，(偏微分方程)');
end
end

function execute_MedianDiffusion(src)
currentFig = src.Parent;
structData = get(currentFig, 'UserData');

if isfield(structData, 'originalImagePath') && ~isempty(structData.originalImagePath) ...
        && isfield(structData, 'maskImagePath') && ~isempty(structData.maskImagePath)

    originalImagePath = structData.originalImagePath; % 获取原始图像路径
    maskImagePath = structData.maskImagePath; % 获取mask图像路径
    convoKernel=structData.convoKernel;

    MedianDiffusion(originalImagePath,maskImagePath,convoKernel);
else
    errordlg('请先传入原始图像和mask图像，(中值扩散)');
end

end



