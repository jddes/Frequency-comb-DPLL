
%% Example code to read and plot the measured transfer functions:

%% Read file:
strFileName = 'transfer_functions\01_30_2014_11_07_34_no_000.txt';
strFileName = 'O:\68601\fiber frequency comb\Python code\SuperLaserLand_JD_v2_Jan28th_2014\transfer_functions\01_30_2014_13_21_37_no_001.txt';

f = fopen(strFileName, 'r');
header_string = fgetl(f); % read header
vertical_units = sscanf(header_string, 'Frequency [Hz]\tReal_part [%s]\tImag_part [%s]');
vertical_units = vertical_units(1:end-1);   % strips off the ']'
rep = textscan(f, '%f %f %f');
fclose(f);

%% Put data into meaningful names:

frequency = rep{1};
transfer_function = rep{2} + 1j*rep{3};

%% Display

figure;
ax = subplot(211);
semilogx(frequency, abs(transfer_function), '.-');
xlabel('Frequency [Hz]');
ylabel(sprintf('Magnitude dB[(%s)^2]', vertical_units));
ax(2) = subplot(212);
semilogx(frequency, angle(transfer_function), '.-');
xlabel('Frequency [Hz]');
ylabel('Phase [rad]');
linkaxes(ax, 'x');
