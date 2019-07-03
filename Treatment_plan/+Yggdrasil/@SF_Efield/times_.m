function [a] = times_(a, b)
%[a] = MTIMES_(a, b) 
%   Overloads * for SF_Efield
    if ~isa(a,'Yggdrasil.SF_Efield')
        tmp = a;
        a = b;
        b = tmp;
    end
    
    if ~Yggdrasil.Utils.isscalar(b)
        error('Can only multiply SF_Efield with a numeric scalar.');
    end
    
    if a.is_content_local
        % Cast a from SF_Efield to Octree
        a_oct = Yggdrasil.Octree(a);
%         a = mtimes_@Yggdrasil.Octree(a,b);
        a_oct = Yggdrasil.Octree.mtimes_(a_oct,b);
        a.data = a_oct.data;
    end
    a.C = a.C * b;
end
