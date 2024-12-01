function MedianDiffusion(imgPath, maskPath,convoKernel)
img = imread(imgPath);
mask = imread(maskPath);

% 将掩码转换为二值图像，白色区域为1(需要修复的区域)，黑色区域为0
mask = imbinarize(mask);

mask = double(mask);
outImg = double(img);
kernSize = convoKernel;

% padarray 函数可以在数组的边缘添加指定数量的行或列的0 (或其他值)，从而扩展数组的大小
% padarray：将原始图像的每个颜色通道进行边界填充，以防止在处理边缘像素时超出图像边界。填充大小为 floor(kernSize/2)，
imgExtend(:,:,1) = padarray(img(:,:,1), [floor(kernSize/2) floor(kernSize/2)]);
imgExtend(:,:,2) = padarray(img(:,:,2), [floor(kernSize/2) floor(kernSize/2)]);
imgExtend(:,:,3) = padarray(img(:,:,3), [floor(kernSize/2) floor(kernSize/2)]);

% 获取填充后的图像的尺寸
[h, w, ~] = size(imgExtend);

% 对掩码 mask 同样进行边界填充，以匹配扩展后的 img 图像尺寸
maskExtend = padarray(mask, [floor(kernSize/2) floor(kernSize/2)]);

% 这两个嵌套循环遍历扩展后的图像的每一个像素，确保在修复中不会超出边界
% 循环起始值为 floor(kernSize/2)，结束值为 img 图像高度和宽度 减去 填充的大小
for i = floor(kernSize/2):h-floor(kernSize/2)-1
    for j = floor(kernSize/2):w-floor(kernSize/2)-1
        % 检查当前像素及其周围的 8 个邻域像素是否有任一像素被掩码标记为1(白色区域，需要修复的区域)
        if maskExtend(i,j) == 1 || maskExtend(i-1,j) == 1 || maskExtend(i,j-1) == 1 || maskExtend(i+1,j) == 1 || maskExtend(i,j+1) == 1 ...
                || maskExtend(i-1,j-1) == 1 || maskExtend(i-1,j+1) == 1 || maskExtend(i+1,j-1) == 1 || maskExtend(i+1,j+1) == 1

            % 提取当前像素的 kernSize x kernSize 邻域(包括自己和周围的像素)用于计算中值
            neighbour = imgExtend(i-floor(kernSize/2)+1:i+floor(kernSize/2)+1,j-floor(kernSize/2)+1:j+floor(kernSize/2)+1,:);

            % 将邻域分离为三个颜色通道：红色，绿色，蓝色
            neighbour_1 = neighbour(:,:,1);
            neighbour_2 = neighbour(:,:,2);
            neighbour_3 = neighbour(:,:,3);

            % 使用 median函数 计算每个通道的中值，并将中值赋值回 outImg 的对应位置
            outImg(i-floor(kernSize/2)+1,j-floor(kernSize/2)+1,1) = median(neighbour_1(:));
            outImg(i-floor(kernSize/2)+1,j-floor(kernSize/2)+1,2) = median(neighbour_2(:));
            outImg(i-floor(kernSize/2)+1,j-floor(kernSize/2)+1,3) = median(neighbour_3(:));
        end
    end
end

figure('Name', '原始图像', 'NumberTitle', 'off');
imshow(uint8(img));
title('原始图像');

figure('Name', 'Diffusion修复后的图像', 'NumberTitle', 'off');
imshow(uint8(outImg));
titleStr = sprintf('Diffusion修复后的图像，卷积核的大小: %d', convoKernel);
title(titleStr);

uicontrol('Style', 'pushbutton', 'String', '保存图像', ...
    'Units', 'normalized', ...
    'Position', [0.35, 0.02, 0.3, 0.1], ...
    'FontSize', 10,...
    'Callback', @(src, event) saveImage(outImg,convoKernel));
end

function saveImage(outpImg,convoKernel)
% 保存处理后的图像
baseFileName = 'Diffusion';  % 基础文件名
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

fullFileName = fullfile(targetDir, [baseFileName,'-kern',num2str(convoKernel), '_', timeStamp, suffix]);
imwrite(uint8(outpImg), fullFileName);

msgbox('处理后的图像已保存');
end




