function E_out = select_best(Efield_objects, min_nbr, tumour, healthy_tissue)
% DOES NOT DO WHAT IT IS SUPPOSED TO DO, DOES NOT CHOOSE ONLY BEST EFIELDS
% BUT THE CODE COMPILES SO IT CAN BE RUN IN THE OPTIMIZATION WITHOUT A
% PROBLEM
% EDIT TO ABOVE: PROBABLY WORKS NOW, MAY NEED TESTING.
% 
% Cuts off Efields that don't contribute to the solution to save
% optimization time.
% -----INPUTS-------------------------------------------------------
% Efield_objects: Cell vector with Efields in SF-format.
% min_nbr:        Minimum number of Efields to continue with.
% tumour:         oct or mat with 1 for tumour, 0 otherwise.
% healthy_tissue: oct or mat with 1 for healthy tissue, 0 otherwise
% ----OUTPUTS-------------------------------------------------------
% E_out:          Cell vector with SF-Efields that passed.
% ------------------------------------------------------------------

if ~isa(tumour,'Yggdrasil.Octree')
    tumour = Yggdrasil.Octree(tumour);
end

if  ~isa(healthy_tissue,'Yggdrasil.Octree')
    healthy_tissue = Yggdrasil.Octree(healthy_tissue);
end

% Calculate quality indicator Q: PLD in tumour/PLD in healthy tissue
Q = zeros(length(Efield_objects),1);
for i = 1:length(Efield_objects)
    e_i = Efield_objects{i};
    P = abs_sq(e_i);
    a = scalar_prod_integral(P,tumour)/1e9;
    b = scalar_prod_integral(P,healthy_tissue)/1e9;
    Q(i) = a/b;
end

[Q,I] = sort(Q, 'descend');
I_best = Q >= max(Q) / 10;
amnt_to_choose = max(length(I_best), min_nbr);
for i = 1:amnt_to_choose
    E_out{i} = Efield_objects{I(i)};
end
    
end

