% Tarea 1. benjamín Villasana Salazar
% Generar un Raster Plot y Obtener la matriz de similitud
clc, clear
[FileName,PathName]=uigetfile({'*.mat', 'MATLAB file'});
cd(PathName)
x=load(FileName,'-mat');
xx =cellfun(@double,struct2cell(x),'uni',false);
CurrentData=xx{1}; %Datos

clear x xx
theta=zeros(size(CurrentData,2),size(CurrentData,2));

for t=1:size(CurrentData,2) %Obtener la amtriz de similitud
    for tt=1:size(CurrentData,2)
        A=CurrentData(:,t); %Vector 1
        B=CurrentData(:,tt); %Vector 2
        PP(t,tt)=dot(A,B); %Producto Punto
        PTV(t,tt)=sqrt(sum(abs(A).^2))*sqrt(sum(abs(B).^2)); %producto del tamaño de los vectores
        MS(t,tt)=PP(t,tt)/PTV(t,tt); %Matriz de similitud
    end
end

%Graficación
figure(1)
imagesc(CurrentData)
colormap([1 1 1; 0 0 0])
xlabel('Frames (t)')
ylabel('Cells')
title('Raster Plot')
figure(2)
imagesc(MS)
colorbar
colormap jet
xlabel('Vectors (t)')
ylabel('Vectors (t)')
title('Similarity matrix')