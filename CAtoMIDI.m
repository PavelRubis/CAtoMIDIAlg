function [eventsMatr] = CAtoMIDI(arr,lastNoteStartPoint)
%arr(массив)-отслеживаемая строка или столбец (с элементами наименьших периодов)

ConsonanceSemitone=[0 3 4 5 7 8 9 12 14 15 16 17 18 19 21 22 23 24];% прямо говоря - балгозвучные расстояния между нотами (в полутонах)
lowBorder=60;

iterPlus1Arr=arr;
iterPlus1Arr(1)=[];
iterPlus1Arr=[iterPlus1Arr arr(1)];

%цикл обработки массива и, соответвенно, генерации нот. ноты начинают
%отстоять друг от друга на ближайшее к разности их номеров благозвучное
%число тонов

noteStart = zeros(length(arr),1);
noteEnd = zeros(length(arr),1);
% noteEnd(1)=0.5;

for i=1:length(arr)-1
    
    semitoneDelta=abs(arr(i)-iterPlus1Arr(i));
    arr(i+1)=arr(i) + ConsonanceSemitone(find(abs(ConsonanceSemitone-semitoneDelta)==min(abs(ConsonanceSemitone-semitoneDelta)),1,'First'));
    if(arr(i)>lowBorder)
        arr(i+1)=arr(i) - ConsonanceSemitone(find(abs(ConsonanceSemitone-semitoneDelta)==min(abs(ConsonanceSemitone-semitoneDelta)),1,'First'));
    end
    
    dur=0.5;
    if arr(i+1)-arr(i)>24
        dur=1;
    end
    
    if i>1
        noteEnd(i)=noteEnd(i-1)+dur;
        noteStart(i)=noteEnd(i-1);
    else
        noteEnd(i)=lastNoteStartPoint + dur;
        noteStart(i)=lastNoteStartPoint;
    end
    
end
noteStart(length(arr))=noteEnd(length(arr)-1);
noteEnd(length(arr))=noteStart(length(arr))+0.5;

notesNums = arr;%массив с номерами нот
%создание участка звукоряда
eventsMatr = zeros(length(notesNums),6);
eventsMatr(:,1) = 1;         
eventsMatr(:,2) = 1;        
eventsMatr(:,3) = notesNums;
eventsMatr(1:1:length(notesNums),4) = 100;% 80; 
eventsMatr(2:1:length(notesNums),4) = 100;

eventsMatr(:,5) = noteStart;
eventsMatr(:,6) = noteEnd;
% eventsMatr(:,5) = (lastNoteStartPoint:0.5:lastNoteStartPoint-0.5+length(arr)/2)'; 
% eventsMatr(:,6) = eventsMatr(:,5) + 0.5;

end