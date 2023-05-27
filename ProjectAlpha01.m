% Load the image
img = imread('image.jpg');
img = rgb2gray(img);

% Convert the image to double precision
img = im2double(img);

% Convert the image to the frequency domain using FFT
f = fft2(img);

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
img_filtered = real(ifft2(f_filtered));

% Display the original and compressed images side by side
figure;
subplot(1,2,1); imshow(img); title('Original Image');
subplot(1,2,2); imshow(img_filtered); title('Compressed Image');

% Save the compressed image to a file in JPEG format
imwrite(img_filtered, 'image_compressed.jpg', 'JPEG');
