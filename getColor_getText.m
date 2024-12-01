function getColor_getText(imgPath)  
    % 读取图像  
    img = imread(imgPath);  
    % 将图像转换为双精度格式  
    imgDouble = im2double(img);  

    screenSize = get(0, 'ScreenSize');  
    figWidth = 750;  
    figHeight = 750;  
    figX = (screenSize(3) - figWidth) / 2;   
    figY = (screenSize(4) - figHeight) / 2;   
    figure('Position', [figX, figY, figWidth, figHeight], ...  
                 'Name', '手动绘制掩膜mask', 'NumberTitle', 'off');    
    imshow(img);  
    title('点击图像中文本的颜色');  

    % 获取鼠标点击的位置  
    [x, y] = ginput(1); % 允许点击一次  
    x = round(x); % 四舍五入到最近的整数  
    y = round(y);  

    % 获取对应位置的颜色  
    pixelColor = imgDouble(y, x, :); % 注意 y 在前，x 在后  

    getImageText(imgPath,pixelColor);
end  

function getImageText(imgPath, colorRGB)    
    img = imread(imgPath);    

    % 将图像转换为双精度格式 
    imgDouble = im2double(img);  

    % 分离颜色通道  
    R = imgDouble(:,:,1); % 红色通道  
    G = imgDouble(:,:,2); % 绿色通道  
    B = imgDouble(:,:,3); % 蓝色通道  

    % 创建一个逻辑掩模，提取指定颜色区域  
    colorMask = (R >= colorRGB(1) - 0.1) & (R <= colorRGB(1) + 0.1) & ...  
                (G >= colorRGB(2) - 0.1) & (G <= colorRGB(2) + 0.1) & ...  
                (B >= colorRGB(3) - 0.1) & (B <= colorRGB(3) + 0.1);  

    % 创建输出图像  
    outputImage = zeros(size(imgDouble));  % 初始化黑色图像  

    % 将指定颜色区域设置为白色  
    outputImage(:,:,1) = colorMask;  % 红色通道  
    outputImage(:,:,2) = colorMask;  % 绿色通道  
    outputImage(:,:,3) = colorMask;  % 蓝色通道  

    % 显示处理后的图像  
    figure();  
    imshow(outputImage);  
    title('处理后的图像');  
    uicontrol('Style', 'pushbutton', 'String', '保存图像', ...  
                     'Units', 'normalized', ...  
                     'Position', [0.35, 0.02, 0.3, 0.1], ... 
                     'FontSize', 10,...
                     'Callback', @(src, event) saveImage(outputImage));
end  

function saveImage(outpImg)
% 保存处理后的图像
baseFileName = 'MaskgetColor';  % 基础文件名  
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
imwrite(outpImg, fullFileName);

msgbox('处理后的图像已保存');
end




