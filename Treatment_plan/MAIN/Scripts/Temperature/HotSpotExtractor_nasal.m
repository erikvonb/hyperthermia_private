
load 'temp_duke_nasal_400MHz'
Tempmatrix=mat;
%Byt index f�r all v�vnad f�rutom tum�ren till 0
load 'tissue_mat_duke_nasal.mat';
ChangeIndex=tissue_Matrix;
ChangeIndex(ChangeIndex ~= 80) = 0;

%Se till att tum�ren �r 0 i ber�kningarna s� att den inte klassas som
%frisk v�vnad i viktning. Talet 20 �r generiskt.
ChangeTemp=Tempmatrix-20*ChangeIndex;
% Blir negativ av n�gon anledning, byter tecken
ChangeTemp=-ChangeTemp;
%Ta bort allt f�rutom hot spots, g�r till logical matris
ChangeTemp(ChangeTemp <=4.5) = 0;
ChangeTemp(ChangeTemp >=2) = 1;
%ChangeTemp
save('ChangeTemp.mat');
