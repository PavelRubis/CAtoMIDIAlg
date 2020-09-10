clear;
clc;
%% �������� ��������� ��������� ���������� ��� ������ ��������� ��������� ��������� ���������� ������ %%
%  
%  �������� ���������� �������� �����, n*iter*duration*pause, ��� n-�������
%  ������� ��, iter-����� ������������ �������� ��, duration-������������
%  ����� ����, pause - ������������ ����� ����� ����� ������. ��������� ���
%  �������� ���� �������� �����������.
%
%  ��� ��������� ��������� ���� ���������� �������� �������������
%  ������������ ������ ��� ������� �������, �������� �������� �����
%  ���������� ������� ��-���������. ��� �������� ��� ���������� �����������
%  ���������� �������� ���������.
%  
%  ��� ��� � MIDI �������� ���� �������� ������� �� 0 �� 128 (�� ������� � 
%  ������), ������ ��� ��������� �������������� �������� ������ - ���
%  ��������� �������� ���������� � �� ������ �� 128, ��� �������� �������.
%  
%  �������� ����������� ������ ����� �� ������������� ������ ��. ������ ��� 
%  ������������ �� ������ ����� �������, ����� ��� �������� ����
%  ���� ����������� ������. ��� ����������� ��������� ���������
%  ������� ������������ ���������� ����� ������ (� ���������).
%
%  � ����� ����� ������ �������� ��, �, �������������� ��������� ���������
%  ������-������� ��������� � �������� ���.
%
%% ����� � ������� ������ ��� ������� � ���������� ������ ���������

n=7;%������� �������
iters=5;% ����� �������� ������������� ��������� (�� n �� �� ��������)

C=(1:n)';
[X,Y]=meshgrid(C,C-1);

%������� ��, � ������� ����� ������������� ������ ��� ������� ��� ���������
%���������. ������������� ����� ������ ��� ������� � ���������� ����������
%�������� ��� ����������� � ������� ���������� 
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

caRowORCol=[];%������ ��� ������� � ���������� ���������� ��������
rowOrColCheck=true;
rowOrColInd=find(rowSum==minRowOrColSum,1,'first');

%% ������������� �������, ��������� ������������ ������ � ��������� ���������

lowBorder=60; % ������������ ������ ��� (����� ����� ������ ���� ��� ������������+24)

Matr(:)=mod(Matr(:)+lowBorder,lowBorder);
randIndxs=randperm(n*n);
Matr(:)=Matr(randIndxs);

if isempty(rowOrColInd)
    rowOrColCheck=false;
    rowOrColInd=find(colSum==minRowOrColSum,1,'first');
end

eventsMatr=[];
%������� ������ ����� 101
newF_v=zeros(n,n);
newF_g=zeros(n,n);

newF_v(:,1:3:n)=1;
newF_v(:,2:3:n)=0;
newF_v(:,3:3:n)=-1;

newF_g(1:3:n,:)=1;
newF_g(2:3:n,:)=0;
newF_g(3:3:n,:)=-1;
%

NewNotesStartPoint=0.5;%������ ������ ������ ������� ��������� ����� n ���
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


