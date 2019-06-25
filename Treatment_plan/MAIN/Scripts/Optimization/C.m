function val = C(P1, P2, weight_nominator, weight_denominator)

P1P2_scalar_prod = Yggdrasil.Math.scalar_prod(P1, P2);
nominator   = Yggdrasil.Math.scalar_prod_integral(P1P2_scalar_prod, weight_nominator);
denominator = Yggdrasil.Math.scalar_prod_integral(P1, weight_denominator) ...
           .* Yggdrasil.Math.scalar_prod_integral(P2, weight_denominator);

val = nominator / denominator;

end
