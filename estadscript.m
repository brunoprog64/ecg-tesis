%%% crear CVS sin comas
cd('EKG-Analysis');
% lfile = dir('*.csv'); %listamos todos los .cvs
% 
% for i=1:length(lfile)
%     
%     %obtenemos el nombre del archivo
%     fdata = regexp(lfile(i).name, '([a-z-]){2,}-([0-9]){2,}', 'tokens');
%     
%     ncsv = strcat(fdata{1}{1}, '-');
%     ncsv = strcat(ncsv, fdata{1}{2});
%     ncsv = strcat(ncsv, '.txt');
%     
%     str = ['minised -n 3,$p ' lfile(i).name ' > ' ncsv];
%     
%     %str = strcat('minised -n 3,$p  ', lfile(i).name);
%     %str = strcat(str, ' > ');
%     %str = strcat(str, ncsv);
%     t = system(str);
% end

% ahora cargamos cada .csv con sus datos y ejecutamos las funciones
% formato salida:
% No.Archivo, No.Q, No.R, No.S, No.P, No. T

lfile = dir('*.txt');

fid = fopen('ecg_file2.csv', 'w');

for i=1:length(lfile)
    
    tmp = csvread(lfile(i).name, 0,1);
    disp(lfile(i).name);
    
    if (length(size(tmp)) == 2)
        tmp = tmp(:,1); %elegimos el EKG II
    end
    
    %los normal-ecg tiene 128 fs y los Arrytmia tiene 360 fs.
    
    if (isempty(strfind(lfile(i).name, 'normal')))
            [bp, diag, ddet, ranol, rranol] = diagnosticoQRS(tmp,360);
    else
            [bp, diag, ddet, ranol, rranol] = diagnosticoQRS(tmp, 128);
    end
    
    olin = strcat(lfile(i).name, ',', num2str(bp), ',', diag, ',', ddet);
    olin = strcat(olin, ',', num2str(ranol), ',', num2str(rranol));
    fprintf(fid, '%s\r\n', olin);
    
%     [q,r,s,b] = analizarQRS(tmp);
%     [p,t] = analizarPT(tmp);
%     
%     olin = [lfile(i).name ',' num2str(length(q)) ',' num2str(length(r)) ',' num2str(length(s)) ',' num2str(length(p)) ',' num2str(length(t)) ',' num2str(b)];
%     fprintf(fid, '%s\r\n', olin);
    
end

    fclose(fid);

cd('..');