function [Matrix]=Tarea2_2(rafagas)
%Por: Benjam�n Villasana-Salazar, MSc
% Septiembre, 2019

% Correlaci�n entre las r�fagas
for t=1:size(rafagas,1)
    for tt=1:size(rafagas,1)
    [corr(tt,:,t),lag]=xcorr(rafagas(t,:),rafagas(tt,:),10000,'normalized');
    end
end

%Graficaci�n de las correlaciones
figure(1)
clf
set(gcf,'Name','Correlaciones entre r�fagas')
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

%Concatenar las r�fagas (500 ms) en un vector
contador=1;
for t=1:size(rafagas,1)
    rafagasJuntas(1,contador:contador-1+size(rafagas,2))=rafagas(t,:);
    contador=contador+size(rafagas,2);
end

%Extraer los segmentos de 25ms del vector de r�fagas
contador=1;
binlength=ceil(25*size(rafagas,2))/500;
for t=1:numel(rafagasJuntas)/binlength
    bines(t,1:binlength) = rafagasJuntas(contador:contador+binlength-1);
    contador=contador+binlength;
end

% Correlaci�n (zero lag) entre los segmentos de 25ms de todas las r�fagas
Matrix=zeros(size(bines,1),size(bines,1));
for t=1:size(bines,1)
    for tt=1:size(bines,1)
        [corr,lag]=xcorr(bines(t,:),bines(tt,:),1,'normalized');
        Matrix(t,tt) = corr(lag==0);
    end
end

% Graficaci�n de la matriz de correlaci�n entre semgentos de las r�fagas
figure(2)
clf
set(gcf,'Name','Correlaci�n entre segmentos (25ms) de las r�fagas')
imagesc(Matrix)
colormap jet
colorbar
xlabel('Segmentos de 25ms')
ylabel('Segmentos de 25ms')
