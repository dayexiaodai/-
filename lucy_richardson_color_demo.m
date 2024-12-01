function lucy_richardson_color_demo()
    % 读取模糊彩色图像
    img_blur = im2double(imread('mohu3.jpg')); % 替换为你的模糊图像路径

    % 检查是否为彩色图像
    if size(img_blur, 3) ~= 3
        error('输入图像必须为彩色图像（RGB）！');
    end

    % 定义点扩散函数 (PSF)
    psf = fspecial('gaussian', [10, 10], 3); % 高斯模糊 PSF，尺寸和标准差可调整

    % 设置迭代次数
    num_iterations = 30;

    % 分别处理 R、G、B 通道
    img_restored = zeros(size(img_blur));
    for c = 1:3
        img_restored(:, :, c) = lucy_richardson(img_blur(:, :, c), psf, num_iterations);
    end

    % 显示结果
    figure;
    subplot(1, 2, 1);
    imshow(img_blur);
    title('模糊图像');

    subplot(1, 2, 2);
    imshow(img_restored);
    title('恢复后的图像');
end

function img_restored = lucy_richardson(img_blur, psf, num_iterations)
    % 初始恢复图像（与模糊图像相同）
    img_restored = img_blur;

    % PSF 的翻转（180°旋转）
    psf_flipped = rot90(psf, 2);

    % 迭代恢复
    for i = 1:num_iterations
        % 计算卷积 J_k * PSF
        conv_result = imfilter(img_restored, psf, 'conv', 'same');
        
        % 计算比值 I / (J_k * PSF)
        ratio = img_blur ./ (conv_result + eps); % 加 eps 避免除零

        % 更新恢复图像 J_k+1
        correction = imfilter(ratio, psf_flipped, 'conv', 'same');
        img_restored = img_restored .* correction;
    end
end
