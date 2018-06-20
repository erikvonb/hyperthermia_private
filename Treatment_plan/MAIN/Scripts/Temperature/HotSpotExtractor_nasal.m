
load 'temp_duke_nasal_400MHz'
Tempmatrix=mat;
%Byt index för all vävnad förutom tumören till 0
load 'tissue_mat_duke_nasal.mat';
ChangeIndex=tissue_Matrix;
ChangeIndex(ChangeIndex ~= 80) = 0;

%Se till att tumören är 0 i beräkningarna så att den inte klassas som
%frisk vävnad i viktning. Talet 20 är generiskt.
ChangeTemp=Tempmatrix-20*ChangeIndex;
% Blir negativ av någon anledning, byter tecken
ChangeTemp=-ChangeTemp;
%Ta bort allt förutom hot spots, gör till logical matris
ChangeTemp(ChangeTemp <=4.5) = 0;
ChangeTemp(ChangeTemp >=2) = 1;
%ChangeTemp
save('ChangeTemp.mat');
