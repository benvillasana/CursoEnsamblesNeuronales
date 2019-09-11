function [Matrix]=Tarea2(Data,Channel)
%INPUTS:
%Data=Matriz de datos, en donde cada fila representa un canal registrado y
%   cada columna un instante de tiempo.
%Channel=Canal a analizar.
%OUTPUT:
%Matrix=Matriz de semejanza entre los segmentos (25ms) de cada ráfaga encontrada en
%   el canal analizado.
% 
% Hecho por Benjamín Villasana-Salazar, Sc.M.
% Contacto: benvillasanasalazar@gmail.com

tic
%Datos a analizar
% load('15_Ene_2014_2condiciones_filtradoPasaBaja350Hz.mat')
X=Data(Channel,:);

if Channel > size(Data,1)
    errordlg('El número de canal es incrorrecto')
    return
end

% Downsampling de la señal (FS/10)
x=downsample(X,10);

disp('Disminuyendo la frecuencia de muestreo para acelerar el proceso de análisis')

% Frecuencia de muestreo y vector de tiempo
FS=25000/10; %Frecuencia de muestreo (pts/s)
xTime=linspace(0,size(x,2)*(1000/FS),size(x,2)); %Vector de tiempo (ms)

disp('Duración de la señal (ms)')
disp(max(xTime))

%Filtro pasa bajas (<350Hz) de 2o orden
[LPF1,LPF2] = butter(2, 350/(FS/2), 'low');
xF = filter(LPF1,LPF2,x);

disp('Aplicando filtro pasa bajas (<350 Hz)')

%Encontrar las ráfagas
Y=envelope(xF,10,'peak'); %Obtener la envolvente de la señal, promediando 10 pts (mayor resolución)
umbral=4; %Umbral para detectar rafagas (desviaciones estándar)
A=mean(Y)+std(Y)*umbral; %Media y desviación estándar
[~,locs] = findpeaks(Y,xTime,...
    'MinPeakHeight',A,'MinPeakDistance',FS); %Encontrar los picos de actividad poniendo un umbral A y con unda distancia entre pico dada por FS

%Extraer las ráfagas del trazo filtrado
rafagas=zeros(numel(locs),0.5*FS);
for t=1:numel(locs)
    if locs(t)+500 > xTime(end)
        rafagas(t,:)=xF(max(xTime)-(0.5*FS):max(xTime));
        continue
    end
    rafagas(t,1:0.5*FS)=xF(xTime>=locs(t) & xTime<=locs(t)+500);
end

%Concatenar las ráfagas (500 ms) en un vector
contador=1;
for t=1:size(rafagas,1)
    rafagasJuntas(1,contador:contador-1+0.5*FS)=rafagas(t,1:0.5*FS);
    contador=contador+0.5*FS;
end

%Extraer los segmentos de 25ms del vector de ráfagas
contador=1;
bines=zeros(numel(rafagasJuntas)/(0.025*FS),0.025*FS);
for t=1:numel(rafagasJuntas)/(0.025*FS)
    bines(t,:) = rafagasJuntas(contador:contador+(0.025*FS)-1);
    contador=contador+(0.025*FS);
end

disp('Número de ráfagas encontradas:')
disp(size(rafagas,1))
disp('Número de bines de 25ms:')
disp(size(bines,1))

% Correlación (zero lag) entre los segmentos de 25ms de todas las ráfagas
Matrix=zeros(size(bines,1),size(bines,1));
for t=1:size(bines,1)
    for tt=1:size(bines,1)
        [corr,lag]=xcorr(bines(t,:),bines(tt,:),1,'normalized');
        Matrix(t,tt) = corr(lag==0);
    end
end

% Graficación de la matriz de correlación entre semgentos de las ráfagas
figure(1)
clf
set(gcf,'Name','Tarea 2')
imagesc(Matrix)
colorbar
xlabel('Segments')
ylabel('Segments')
title(Channel)

disp('Tiempo del análisis (min):')
disp(toc/60)
