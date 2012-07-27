function [ecgsg] = corrigeDeriva(ecgorsig, fs)
    ventana2 = 100; %ventana de 100 ms (Mitad de 200 ms)
    ventana_muestras = fs * ventana2 / 1000;
    ventana_muestras = round(ventana_muestras);
    linea0 = zeros(size(ecgorsig));
    
    for i=ventana_muestras:length(ecgorsig) - ventana_muestras,
        senyal = ecgorsig(i - ventana_muestras + 1:i+ventana_muestras);
        %i = round(i);
        linea0(i) = median(senyal);
    end
    
    ventana2 = 300; %ventana de 300 ms (Mitad de 600 ms)
    ventana_muestras = fs * ventana2 / 1000;
    ventana_muestras = round(ventana_muestras);
    linea = zeros(size(ecgorsig));
    
    for i=ventana_muestras:length(ecgorsig) - ventana_muestras,
        senyal = linea0(i - ventana_muestras + 1:i+ventana_muestras);
        %i = round(i);
        linea(i) = median(senyal);
    end
    
    ecgsg = ecgorsig - linea;   
