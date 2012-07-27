function [bpm, diagnos, diagdetal, ranol, rranol] = diagnosticoQRS(signal, fs)
%valores retornados
%bpm - latidos por minuto
%diagnos - Diagnostico (Arrtimia / Normal)
%diagdetal - Diagnostico detallado (Taquicardia - Bradicardia /
%... Ritmo R anomalo / Intervalos R-R Anomalos
%ranol - No. Ritmos R anomalos
%rranol - Intervalos R-R anomalos

if nargin < 2
    fs = 360;
end

%primero obtenemos info de la señal
[qd, rd, st, bd] = analizarQRS(signal,fs);

%testeamos por alteracion del ritmo cardiaco
if (bd > 100)
    ritmo_str = 'Taquicardia';
end

if (bd < 60)
    ritmo_str = 'Bradicardia';
end

if (bd >= 60 && bd <= 100)
    ritmo_str = 'Latidos Normales';
end

signal = corrigeDeriva(signal, fs);

%ahora buscamos alguna arritmia
%basada en la altura del complejo R

rpos = zeros(1,length(rd));

for i=1:length(rd)
    rpos(i) = signal(rd(i)) * 1000; %eliminar decimales
end

umbralr = std(rpos);
promr = mean(rpos);
ranormal = 0;

for i=1:length(rpos)
    
    if (rpos(i) > promr + umbralr + 100) || (rpos(i) < promr - umbralr - 100) 
        ranormal = ranormal + 1;
    end
end
    
if ranormal > 0
    ranormal_str = sprintf('Se han encontrado %d ritmos R anomalos', ranormal);
else
    ranormal_str = 'Ritmos R normales';
end

%buscamos alguna arrtimia basada en distancia R-R

rdist = zeros(1,length(rd) - 1);

for i=1:length(rdist)
    rdist(i) = rd(i+1) - rd(i);
end

umbralr = std(rdist);
promr = mean(rdist);
rranormal = 0;

for i=1:length(rdist)
    
    if (rdist(i) > promr + umbralr + 50 || rdist(i) < promr - umbralr - 50 )
        rranormal = rranormal + 1;
    end 
end

if rranormal > 0
    rranormal_str = sprintf('Se han encontrado %d intveralos R-R anomalos', rranormal);
else
    rranormal_str = 'Intervalos R-R normales';
end

%diagnostico
%Normal = Ritmo Normal, No arritmia R, Intervalo R-R Normal
%Arritmia = Alguno de los 3 con cambios

if (rranormal == 0) && (ranormal == 0) && (bd >= 60 && bd <= 100)
    str_diagnost = 'Ritmo Normal';
else
    %arritmia
    str_diagnost = 'Arritmia';
end

%retornamos valores

    tmp = strcat(ritmo_str, '/', ranormal_str, '/', rranormal_str);
    
    bpm = bd;
    diagnos = str_diagnost;
    diagdetal = tmp;
    ranol = ranormal;
    rranol = rranormal;