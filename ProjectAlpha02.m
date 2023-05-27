% Load the image
img = imread('image.jpg');

% Convert the image to YCbCr color space
img_ycbcr = rgb2ycbcr(img);

% Extract the luminance (Y) component
img_y = img_ycbcr(:,:,1);

% Convert the luminance component to double precision
img_y = im2double(img_y);

% Convert the luminance component to the frequency domain using FFT
f = fft2(img_y);

% Shift the zero-frequency component to the center of the spectrum
fshift = fftshift(f);

% Compute the magnitude spectrum
magnitude = log(1 + abs(fshift));

% Set a threshold value for frequency filtering
threshold = 0.1 * max(magnitude(:));

% Perform frequency filtering by setting coefficients with magnitude below the threshold to zero
fshift_filtered = fshift .* (magnitude > threshold);

% Shift the zero-frequency component back to the top-left corner of the spectrum
f_filtered = ifftshift(fshift_filtered);

% Convert the filtered spectrum back to the spatial domain using inverse FFT
img_y_filtered = real(ifft2(f_filtered));

% Rescale the luminance component to the range [0, 1]
img_y_filtered = imadjust(img_y_filtered, [], [], 0.5);

% Replace the luminance component in the YCbCr image with the filtered luminance component
img_ycbcr_filtered = img_ycbcr;
img_ycbcr_filtered(:,:,1) = img_y_filtered;

% Convert the filtered YCbCr image back to RGB color space
img_filtered = ycbcr2rgb(img_ycbcr_filtered);

% Display the original and compressed images side by side
figure;
subplot(1,2,1); imshow(img); title('Original Image');
subplot(1,2,2); imshow(img_filtered); title('Compressed Image');

% Save the compressed image to a file in JPEG format
imwrite(img_filtered, 'image_compressed.jpg', 'JPEG');