function [Matrix]=Tarea2_2(rafagas)
%Por: Benjamín Villasana-Salazar, MSc
% Septiembre, 2019

% Correlación entre las ráfagas
for t=1:size(rafagas,1)
    for tt=1:size(rafagas,1)
    [corr(tt,:,t),lag]=xcorr(rafagas(t,:),rafagas(tt,:),10000,'normalized');
    end
end

%Graficación de las correlaciones
figure(1)
clf
set(gcf,'Name','Correlaciones entre ráfagas')
contador = 1;
for tt = 1:size(rafagas,1)
    for t = 1:size(rafagas,1)
        subplot(size(rafagas,1),size(rafagas,1),contador)
        plot(lag,corr(t,:,tt),'k','LineWIdth',2)
        title(strcat(string(tt),'-',string(t)))
        ylabel('Corr')
        xlabel('lag')
        grid on
        contador=contador+1;
    end
end

%Concatenar las ráfagas (500 ms) en un vector
contador=1;
for t=1:size(rafagas,1)
    rafagasJuntas(1,contador:contador-1+size(rafagas,2))=rafagas(t,:);
    contador=contador+size(rafagas,2);
end

%Extraer los segmentos de 25ms del vector de ráfagas
contador=1;
binlength=ceil(25*size(rafagas,2))/500;
for t=1:numel(rafagasJuntas)/binlength
    bines(t,1:binlength) = rafagasJuntas(contador:contador+binlength-1);
    contador=contador+binlength;
end

% Correlación (zero lag) entre los segmentos de 25ms de todas las ráfagas
Matrix=zeros(size(bines,1),size(bines,1));
for t=1:size(bines,1)
    for tt=1:size(bines,1)
        [corr,lag]=xcorr(bines(t,:),bines(tt,:),1,'normalized');
        Matrix(t,tt) = corr(lag==0);
    end
end

% Graficación de la matriz de correlación entre semgentos de las ráfagas
figure(2)
clf
set(gcf,'Name','Correlación entre segmentos (25ms) de las ráfagas')
imagesc(Matrix)
colormap jet
colorbar
xlabel('Segmentos de 25ms')
ylabel('Segmentos de 25ms')
