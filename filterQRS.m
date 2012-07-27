function [ecgfilt] = filterQRS(signal)

fs = 360;
of = 1;

%Filtro QRS
lsig = length(signal);

%1. Filtro pasa altas de 5 Hz.
[b,a] = butter(of, 5 /(fs/2), 'high');
tmpecg = filtfilt(b,a, signal);

%2. Filtro pasa bajas de 12 Hz.

[c,d] = butter(of, 12/(fs/2), 'low');
tmpecg = filtfilt(c,d, tmpecg);

%2.1 Filtro Derivacio
tmpecg = diff(tmpecg);

%3. Elevacion al cuadrado senyal
recg = tmpecg.^2;

%4. Ventana de filtrado
vfil = recg / max(abs(recg));
h = ones(1,31) / 31;
ecgf1 = conv(vfil,h);
ecgf1 = ecgf1(15+[1:lsig]);
ecgf1 = ecgf1 / max(abs(ecgf1));

%5. Retornamos la senyal para aplicar ventanas, cada pico es un QRS.
ecgfilt = ecgf1;
