import h5py
from dolfin import *
import numpy as np

import time

Tstart = time.time()

class DataLoader(UserExpression):
    sidelen = 1 / 1000
    def __init__(self, data):
        self.data = data
        self.sizex = len(data)
        self.sizey = len(data[0])
        self.sizez = len(data[0][0])
        super().__init__()
    
    def eval(self, values, x):
        xind = int(round(x[0] / self.sidelen))
        yind = int(round(x[1] / self.sidelen))
        zind = int(round(x[2] / self.sidelen))
        xind = max(0, min(xind, self.sizex-1))
        yind = max(0, min(yind, self.sizey-1))
        zind = max(0, min(zind, self.sizez-1))
        
        d = self.data
        values[0] = d[xind][yind][zind]
#        values[0] = self.data[0][0][0]
    
    def value_shape(self):
        return []

def load_data2(filename, degree=0):
    # Load the .mat file
    f = h5py.File(filename, "r")
    data = np.array(list(f.items())[0][1], dtype=float)
    f.close()
    
    return DataLoader(data)

def load_data(filename, degree=0):
    # Load the .mat file
    f = h5py.File(filename, "r")
    data = np.array(list(f.items())[0][1], dtype=float)
    f.close()

    # Load the intepolation c++ code
    f = open('TheGreatInterpolator2.cpp', "r")
    code = f.read()
    f.close()

    # Amend axis ordering to match layout in memory
    size = tuple(reversed(np.shape(data)))

    P = CompiledExpression(
            compile_cpp_code(code).TheGrandInterpolator(),
            stridex = size[0],
            stridexy = size[0] * size[1],
            sizex = size[0],
            sizey = size[1],
            sizez = size[2],
            sidelen = 1.0 / 1000,
            degree = 1)

    # As the last step, add the data
    P.set_data(data)
    return P
#k_mat  = load_data("../Input_to_FEniCS/thermal_cond.mat")
#v  = np.array([0,0,0], dtype=np.float64)
#x = np.array([0, 0, 0], dtype=np.float64)
#k_mat.eval(v, x)
"""
# --------------------------------------
k_mat  = load_data("../Input_to_FEniCS/thermal_cond.mat")
k2_mat = load_data2("../Input_to_FEniCS/thermal_cond.mat")
v  = np.array([0,0,0], dtype=np.float64)
v2 = [0]

f = h5py.File("../Input_to_FEniCS/thermal_cond.mat", "r")
rawdata = np.array(list(f.items())[0][1], dtype=float)
f.close()

for i in range(0, 200, 10):
    for j in range(0, 200, 10):
        for k in range(0, 200, 10):
            ii = i * 1e-3
            jj = j * 1e-3
            kk = k * 1e-3
            
            x = np.array([ii, jj, kk], dtype=np.float64)
            k_mat.eval(v, x)
            k2_mat.eval(v2, x)
            a = rawdata[i, j, k]
            print("v[0] = %f, v2[0] = %f, true data = %f" % (v[0], v2[0], a))
            if abs(v[0] - v2[0]) > 5*DOLFIN_EPS:
                print("Found mismatch at %d, %d, %d" % (i, j, k))
print("Done")
# --------------------------------------
"""

# Load mesh
print("Reading and unpacking mesh...")
mesh = Mesh('../Input_to_FEniCS/mesh.xml')

# Define material properties
# -------------------------
# T_b:      blood temperature [K relative body temp]
# P:        power loss density [W/m^3]
# k_tis:    thermal conductivity [W/(m K)]
# w_c_b:    volumetric perfusion times blood heat capacity [W/(m^3 K)]
# alpha:    boundary heat transfer constant [W/(m^2 K)]
# T_out_ht  alpha times ambient temperature [W/(m^2)]

print('Importing material properties...')
T_b = Constant(0.0) # Blood temperature relative body temp
#P1       = load_data("../Input_to_FEniCS/P1.mat")
#P2       = load_data("../Input_to_FEniCS/P2.mat")
#P3       = load_data("../Input_to_FEniCS/P3.mat")
P        = load_data2("../Input_to_FEniCS/P.mat")
k_tis    = load_data2("../Input_to_FEniCS/thermal_cond.mat")
w_c_b    = load_data2("../Input_to_FEniCS/perfusion_heatcapacity.mat")
alpha    = load_data2("../Input_to_FEniCS/bnd_heat_transfer.mat")
T_out_ht = load_data2("../Input_to_FEniCS/bnd_temp_times_ht.mat")

#P = Constant(1.0)  # Evals up to ~1000
#k_tis = load_data2("../Input_to_FEniCS/thermal_cond.mat")
#k_tis = Constant(0.427)  # Evals up to ~0.5
#w_c_b = Constant(1.0)  # Evals up to ~20 000
#alpha = Constant(1.0)  # Evals to 0, 70, 800 or 80 000
#T_out_ht = Constant(1.0)  # Evals to 0, -1190 or -17 600

#-----------------------
Tmax= 5 # 0 = 37C, 8 if head and neck, 5 if brain
Tmin= 4.5 # 0 = 37C
#scale= 1
maxIter=180
#-----------------------

print("Done loading.")

V = FunctionSpace(mesh, "CG", 1)
u = TrialFunction(V)
v = TestFunction(V)
# Variation formulation of Pennes heat equation
a = v*u*alpha*ds + k_tis*inner(grad(u), grad(v))*dx + w_c_b*v*u*dx
L = T_out_ht*v*ds + P*v*dx # + w_c_b*T_b*v*dx not needed due to T_b = 0

u = Function(V)
solve(a == L, u, solver_parameters={'linear_solver':'gmres', 'preconditioner':'ilu'}) #gmres is fast

T = u.vector().get_local()
Coords = mesh.coordinates()
Cells  = mesh.cells()

f = h5py.File('../FEniCS_results/temperature.h5','w')
f.create_dataset(name='Temp', data=T)
f.create_dataset(name='P',    data=Coords)
f.create_dataset(name='T',    data=Cells)
# Need a dof(degree of freedom)-map to permutate Temp
f.create_dataset(name='Map',  data=dof_to_vertex_map(V))
f.close()

Tend = time.time()
print("Timed at %f seconds" % (Tend - Tstart))

