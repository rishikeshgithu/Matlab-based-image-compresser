% Load the image
img = imread('image.jpeg');

% Convert the image to grayscale
img_gray = rgb2gray(img);

% Convert the grayscale image to double precision
img_gray = im2double(img_gray);

% Convert the grayscale image to the frequency domain using FFT
f = fft2(img_gray);

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
img_gray_filtered = real(ifft2(f_filtered));

% Rescale the filtered grayscale image to the range [0, 1]
img_gray_filtered = imadjust(img_gray_filtered, [], [], 0.5);

% Convert the compressed color image to double precision
img_compressed = im2double(img);

% Perform color balance adjustment by scaling the R, G, and B channels of the compressed image
img_compressed(:,:,1) = img_compressed(:,:,1) .* (img_gray_filtered ./ mean2(img_gray_filtered));
img_compressed(:,:,2) = img_compressed(:,:,2) .* (img_gray_filtered ./ mean2(img_gray_filtered));
img_compressed(:,:,3) = img_compressed(:,:,3) .* (img_gray_filtered ./ mean2(img_gray_filtered));

% Rescale the compressed color image to the range [0, 1]
img_compressed = imadjust(img_compressed, [], [], 0.5);

% Convert the compressed color image back to the uint8 data type
img_compressed = im2uint8(img_compressed);

% Display the original and compressed images side by side
figure;
subplot(1,2,1); imshow(img); title('Original Image');
subplot(1,2,2); imshow(img_compressed); title('Compressed Image');

% Save the compressed image to a file in JPEG format
imwrite(img_compressed, 'image_compressed.jpg', 'JPEG');
