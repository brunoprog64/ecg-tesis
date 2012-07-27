function [Q_locd, R_locd, S_locd, bpm] = analizarQRS(senyal, fs)
    
    ecgflt = corrigeDeriva(senyal,360);
    ecgflt = filterQRS(senyal);

    if (nargin < 2)
        fs = 360;
    end
    
    t = [1:length(senyal)] / fs;
    t1 = length(senyal) / fs;
    
    %vamos a crear el umbral para los complejos
    max_h = max(ecgflt);
    threshld = mean(ecgflt);
    poss_reg = (ecgflt>(threshld*max_h))'; %un operador
    
    left = find(diff([0 poss_reg])==1);
    right = find(diff([poss_reg 0])==-1);

    for i=1:length(left)
        
        [R_value(i) R_loc(i)] = max(senyal(left(i):right(i)));
        R_loc(i) = R_loc(i)-1+left(i);
        
        [Q_value(i) Q_loc(i)] = min(senyal(left(i):R_loc(i)));
        Q_loc(i) = Q_loc(i)-1+left(i);
        
        [S_value(i) S_loc(i)] = min(senyal(R_loc(i):right(i)));
%         S_loc(i) = R_loc(i) + S_loc(i) - 1;
        
        %heuristica -- es posible que la ventana se acabe antes del S.
        if (S_value(i) == senyal(right(i)))
            %S es el borde de la ventana, confirmamos...
            
            if (senyal(S_loc(i)+1) >= S_value(i))
                %expandimos la busqueda
                
                if (right(i) + 100) < length(senyal)
                    [S_value(i) S_loc(i)] = min(senyal(R_loc(i):right(i)+100));
                end %sino se queda igual
            end
            
        end
        
        S_loc(i) = R_loc(i) + S_loc(i) - 1;
    end
    
    Q_loc = Q_loc(Q_loc~=0);
    R_loc = R_loc(R_loc~=0);
    S_loc = S_loc(S_loc~=0);
    
    R_locd = R_loc;
    Q_locd = Q_loc;
    S_locd = S_loc ;

    bp = getBPM(senyal, R_loc, fs);
    disp(['BPM: ', num2str(bp)]);
    disp(['Dur. Sign: ', num2str(t1)]);
    
    bpm = bp;
    
    %Señal ECG ploteada
    
    title('ECG Signal');
    plot(t, senyal, t(R_loc), R_value, 'r^', t(S_loc) ,S_value, '*', t(Q_loc), Q_value, 'o');
    legend('ECG','R','S','Q');

function [bpm] = getBPM(signal, rcplx, fs)
        
        %asumimos que la Fs es de 360 Hz.
        
        if (nargin < 3)
            fs = 360;
        end
        
        %tomamos 2 segundos de señal
        
        tmpsg = [1:fs*2];
        j=1;
        
        for i=1:length(tmpsg)
           if i == rcplx(j)
               j = j + 1;
               
               if (j > length(rcplx))
                   %ya no hay mas que buscar
                   break;
               end
           end
        end
        
        bpm = (j - 1) * 30;
        

function [ecgsg] = corrigeDeriva(ecgorsig, fs)
    ventana2 = 100; %ventana de 100 ms (Mitad de 200 ms)
    ventana_muestras = fs * ventana2 / 1000;
    linea0 = zeros(size(ecgorsig));
    
    for i=ventana_muestras:length(ecgorsig) - ventana_muestras,
        senyal = ecgorsig(i - ventana_muestras + 1:i+ventana_muestras);
        linea0(i) = median(senyal);
    end
    
    ventana2 = 300; %ventana de 300 ms (Mitad de 600 ms)
    ventana_muestras = fs * ventana2 / 1000;
    linea = zeros(size(ecgorsig));
    
    for i=ventana_muestras:length(ecgorsig) - ventana_muestras,
        senyal = linea0(i - ventana_muestras + 1:i+ventana_muestras);
        linea(i) = median(senyal);
    end
    
    ecgsg = ecgorsig - linea;   
        
function [ecgfilt] = filterQRS(sigl)

%Filtro QRS
lsig = length(sigl);
fs = 360;
of = 1;

%0. Cancelar DC y normalizar

signal = sigl - mean(sigl);
signal = sigl / max(abs(sigl));

tmpecg = signal;

%1. Filtro pasa altas de 5 Hz.
[b,a] = butter(of, 5 /(fs/2), 'high');
tmpecg = filtfilt(b,a, signal);

%2. Filtro pasa bajas de 12 Hz.
    
[c,d] = butter(of, 12/(fs/2), 'low');
tmpecg = filtfilt(c,d, tmpecg);

%2.1 Filtro Derivacion
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