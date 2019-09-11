function varargout = tarea4(varargin)
% Hecho por Benjamín Villasana-Salazar


% Edit the above text to modify the response to help tarea4

% Last Modified by GUIDE v2.5 11-Sep-2019 23:25:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tarea4_OpeningFcn, ...
                   'gui_OutputFcn',  @tarea4_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tarea4 is made visible.
function tarea4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tarea4 (see VARARGIN)

% Choose default command line output for tarea4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tarea4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tarea4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Abrir archivo y graficación del raster y de la coactividad
global CurrentData 
clc
CurrentData=[];

set(handles.text4,'String', 'Analizando')

[FileName,PathName]=uigetfile({'*.mat', 'MATLAB file'},'Seleccione el archivo');   
cd(PathName);

fprintf('Anlizando archivo: \n')
disp(FileName)

x=load(FileName,'-mat');
xx =cellfun(@double,struct2cell(x),'uni',false);
CurrentData=xx{1};

SumCoActivity=sum(CurrentData);

%Graficación
figure(1), clf
set(gcf,'Name','Data and Co-activity')

subplot(3,1,1:2)
imagesc(CurrentData)
colormap([1 1 1; 0 0 0])
ylabel('Cells')
title('Raster plot')
grid minor

subplot(3,1,3)
plot(SumCoActivity,'k','LineWidth',1.5)
xlabel('Frames(t)')
ylabel('Sum(Cells)/t')
title('Coactividad')
xlim([0 size(SumCoActivity,2)])
grid minor

set(handles.text4,'String', '<°.°>')

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% K-means clustering
global CurrentData score flag

disp('Agrupamiento k-means')
set(handles.text4,'String', 'Analizando')

answ=inputdlg('Selecciona el número de grupos (clusters):'); %Número de Clusters
nClusters=str2num(answ{1});
Colores=rand(nClusters,3);

[Clusters, Centroides]=kmeans(score,nClusters);

figure(4), clf
set(gcf,'Name','Agrupamiento K-means')
subplot(3,1,1)
for t=1:nClusters
    plot(score(Clusters==t,1),score(Clusters==t,2),'.','MarkerSize',12,'Color',Colores(t,:))
    hold on
end
plot(Centroides(:,1),Centroides(:,2),'kx','MarkerSize',8,'LineWidth',3) 
title 'Grupos y centroides'
if flag==0
    xlabel('PCA1')
    ylabel('PCA2')
elseif flag ==1
    xlabel('Dimension embedding 1')
    ylabel('Dimension embedding 2')
end
hold off
grid minor

for t=1:size(CurrentData,1)
    x(t,:)=Clusters;
end
for t=1:size(CurrentData,1)
    for tt=1:size(CurrentData,2)
        if CurrentData(t,tt) == 1
            xx(t,tt)= x(t,tt);
        else
            xx(t,tt) = 0;
        end
    end
end

subplot(3,1,2)
imagesc(xx)
ylabel('Cells')
title('Raster plot')
Colors=[1 1 1;Colores];
colormap(Colors)
grid minor

SumCoActivity=sum(CurrentData);

for C=1:nClusters
    a=Clusters==C;
    for t=1:size(SumCoActivity,2)
        if a(t) == 1
            aa(C,t)= SumCoActivity(t);
        else 
            aa(C,t)= min(SumCoActivity);
        end
    end
end

subplot(3,1,3)
hold on
for t=1:nClusters
    plot(aa(t,:),'Color',Colores(t,:),'LineWidth',1.5)
end
hold off
xlabel('Frames(t)')
ylabel('Co-activity (Sum(Cells)/t)')
xlim([0 size(SumCoActivity,2)])
title('Coactividad')
grid minor

set(handles.text4,'String', '<°.°>')

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% tSNE (t-Distributed Stochastic Neighbor Embedding)
global CurrentData flag score
score=[];
flag=1;

disp('t-Distributed Stochastic Neighbor Embedding (tSNE)')
set(handles.text4,'String', 'Analizando')

score = tsne(CurrentData','Algorithm','exact','Distance','euclidean');
%Graficación
figure(3), clf
set(gcf,'Name','tSNE')
scatter(score(:,1),score(:,2),8,'k','filled')
grid minor
xlabel('Dimension embedding 1')
ylabel('Dimension embedding 2')
title('Reducción dimensional')

set(handles.text4,'String', '<°.°>')

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% PCA
global CurrentData score flag
flag=0;
score=[];

disp('Principal Component Analysis (PCA)')
set(handles.text4,'String', 'Analizando')

[~,score] = pca(CurrentData','NumComponents',2,'Centered',true);

%Graficación
figure(2), clf
set(gcf,'Name','PCA')
scatter(score(:,1),score(:,2),8,'k','filled')
grid minor
xlabel('PCA1'),
ylabel('PCA2')
title('Reducción dimensional')

set(handles.text4,'String', '<°.°>')

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Agrupamiento Jerárquico
global CurrentData score flag

disp('Agrupamiento jerárquico')
set(handles.text4,'String', 'Analizando')

Distance=pdist(CurrentData');
Y=squareform(Distance);
Tree=linkage(Y,'ward');

figure(5), clf
set(gcf,'Name','Agrupamiento Jerárquico')
dendrogram(Tree,0)
title('Dendrograma')
xlabel('Frame(t)')
ylabel('Distancia euclidiana')

answ=inputdlg('Selecciona el número de grupos (clusters):'); %Número de Clusters
nClusters=str2num(answ{1});
Colores=rand(nClusters,3);

Clusters = cluster(Tree,'Maxclust',nClusters,'Criterion','distance');

figure(5), clf
set(gcf,'Name','Agrupamiento Jerárquico')

subplot(3,1,1)
for t=1:nClusters
    plot(score(Clusters==t,1),score(Clusters==t,2),'.','MarkerSize',8,'Color',Colores(t,:))
    hold on
end
hold off
title 'Grupos'
if flag==0
    xlabel('PCA1')
    ylabel('PCA2')
elseif flag ==1
    xlabel('Dimension embedding 1')
    ylabel('Dimension embedding 2')
end
hold off
grid minor

for t=1:size(CurrentData,1)
    x(t,:)=Clusters;
end
for t=1:size(CurrentData,1)
    for tt=1:size(CurrentData,2)
        if CurrentData(t,tt) == 1
            xx(t,tt)= x(t,tt);
        else
            xx(t,tt) = 0;
        end
    end
end

subplot(3,1,2)
imagesc(xx)
ylabel('Cells')
title('Raster plot')
Colors=[1 1 1;Colores];
colormap(Colors)
grid minor

SumCoActivity=sum(CurrentData);

for C=1:nClusters
    a=Clusters==C;
    for t=1:size(SumCoActivity,2)
        if a(t) == 1
            aa(C,t)= SumCoActivity(t);
        else 
            aa(C,t)= min(SumCoActivity);
        end
    end
end

subplot(3,1,3)
for t=1:nClusters
    plot(aa(t,:),'Color',Colores(t,:),'LineWidth',1.5)
    hold on
end
hold off
xlabel('Frames(t)')
ylabel('Co-activity (Sum(Cells)/t)')
xlim([0 size(SumCoActivity,2)])
title('Coactividad')
grid minor

set(handles.text4,'String', '<°.°>')
