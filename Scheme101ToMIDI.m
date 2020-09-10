clear;
clc;
%% Прототип алгоритма генерации звукорядов при помощи двумерных клеточных автоматов пермутации матриц %%
%  
%  Алгоритм генерирует звукоряд длины, n*iter*duration*pause, где n-порядок
%  матрицы КА, iter-число элементарных итераций КА, duration-длительность
%  одной ноты, pause - длительность паузы между двумя нотами. Последние две
%  величины пока являются постоянными.
%
%  Для генерации звукового ряда алгоритмом начинает отслеживатсья
%  определенная строка или столбец матрицы, элементы которого имеют
%  наименьшие периоды КА-алгоритма. Это делается для достижения цикличности
%  достаточно длинного звукоряда.
%  
%  Так как в MIDI доступны ноты условных номеров от 0 до 128 (от высоких к 
%  низким), высота нот звукоряда ограничивается заданным числом - для
%  смягчения звуковых контрастов и не выхода за 128, что черевато тишиной.
%  
%  Алгоритм преобразует массив чисел из отслеживаемой строки КА. Номера нот 
%  генерируются из данных таким образом, чтобы две соседние ноты
%  были благозвучны вместе. Это достигается благодаря заданному
%  массиву благозвучных интервалов между нотами (в полутонах).
%
%  В итоге после каждой итерации КА, и, соответственно алгоритма создается
%  строка-отрывок звукоряда с номерами нот.
%
%% поиск в матрице строки или столбца с наименьшей суммой элементов

n=7;%порядок матрицы
iters=5;% число итераций генерирования звукоряда (по n но за итерацию)

C=(1:n)';
[X,Y]=meshgrid(C,C-1);

%матрица КА, в которой будет отслеживаться строка или столбец для генерации
%звукоряда. Отслеживаться будет строка или столбец с элементами наименьших
%периодов для цикличности в длинных звукорядах 
Matr=X+n*Y;

nMatr=zeros(1,n*n);
nMatr(:)=n;

traceIterMatr=nMatr;
traceIterMatr(:)=500;

rowsIndxs=reshape(X,[n*n,1]);
columnsIndxs=1:n;

nRange=1:n;
for i=2:n
    columnsIndxs=[columnsIndxs nRange];
end

[periodsMatr] = arrayfun(@traceElement,nMatr, rowsIndxs', columnsIndxs, traceIterMatr);
periodsMatr = reshape(periodsMatr,[],n)';

colSum=nRange;
rowSum=nRange;

for i=1:n
    colSum(i)=sum(periodsMatr(:,i));
    rowSum(i)=sum(periodsMatr(i,:));
end
minRowOrColSum=min([min(colSum) min(rowSum)]);

caRowORCol=[];%строка или столбец с элементами наименьших периодов
rowOrColCheck=true;
rowOrColInd=find(rowSum==minRowOrColSum,1,'first');

%% инициализация матрицы, установка ограничителя высоты и генерация звукоряда

lowBorder=60; % ограничитель высоты нот (номер самой низкой ноты это ограничитель+24)

Matr(:)=mod(Matr(:)+lowBorder,lowBorder);
randIndxs=randperm(n*n);
Matr(:)=Matr(randIndxs);

if isempty(rowOrColInd)
    rowOrColCheck=false;
    rowOrColInd=find(colSum==minRowOrColSum,1,'first');
end

eventsMatr=[];
%матрицы флагов схемы 101
newF_v=zeros(n,n);
newF_g=zeros(n,n);

newF_v(:,1:3:n)=1;
newF_v(:,2:3:n)=0;
newF_v(:,3:3:n)=-1;

newF_g(1:3:n,:)=1;
newF_g(2:3:n,:)=0;
newF_g(3:3:n,:)=-1;
%

NewNotesStartPoint=0.5;%момент начала нового участка звукоряда длины n нот
for it=1:iters
    if isempty(rowOrColInd)
        caRowORCol=Matr(:,rowOrColInd);
    else
        caRowORCol=Matr(rowOrColInd,:);
    end
    
    eventsMatr=[eventsMatr;CAtoMIDI(caRowORCol,NewNotesStartPoint)];
    NewNotesStartPoint = eventsMatr(end,end);
%     NewNotesStartPoint=NewNotesStartPoint+length(caRowORCol)/2;
    
    [newF_v,newM] = Schema101(Matr,newF_v);
    Matr=newM;

    if isempty(rowOrColInd)
        caRowORCol=Matr(:,rowOrColInd);
    else
        caRowORCol=Matr(rowOrColInd,:);
    end
    
    eventsMatr=[eventsMatr;CAtoMIDI(caRowORCol,NewNotesStartPoint)];
    NewNotesStartPoint = eventsMatr(end,end);
%     NewNotesStartPoint=NewNotesStartPoint+length(caRowORCol)/2;
    [newF_g,newM] = Schema101(Matr,newF_g);
    Matr=newM;
end

midi_new = matrix2midi(eventsMatr);
writemidi(midi_new, 'testout.mid');


