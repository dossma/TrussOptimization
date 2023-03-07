# TrussOptimization
Weight optimization of a truss structure via evolution strategy

## Motivation
Truss structures have a weight for which its weight optimal design is not intuitively to determine. This optimization procedure can find the optimal design for minimal weight.  

## Procedure and result

First, the magnitude of the applied force is being set, which is 100 N by default (line 8).
Then, the node coordinates of the truss is being set (lines 11-13). By default, the nodes are such which manifest an equilateral triangle.
All nodes must be included in the node matrix (´Knotenmatrix´) in line 16.
Each rod is connected to two nodes; this configuration is defined in lines 18-21.
After, the degrees of freedom of the bearings are set (lines 26-29). "1" stands for fixed and "0" stands for loose. The default is a fixed bearing at the bottom left node and a floating bearing at the bottom right node. 

<img src="https://github.com/dossma/TrussOptimization/blob/main/Modell.jpg" width=30% height=30%>

While the design of this procedure is such, that parameters are defined right before they are being used in contrast to an approach that all parameters are defined at the top, the material parameters are defined in lines 102-107. By default, material parameters of steel type S235 is used. In addition, a security factor is set towards yielding of, by default, 1.5. 

The profile areas of the rods are defined in lines 109-112. By default, the rods have a circular solid profile surface.

The starting step size of the node variation is defined in line 141 under the variable `d`. 

The optimization procedure takes place within the generation loop starting from line 154.

__The detailed procedure is being described in the attached pdf document.__ 

## Summary and Result

With a small step size (i.e. 3 or lower), the optimization is converging towards a local minimum with a weight reduction of 56%. 
With a greater step size (i.e. 6), the optimization is converging towards the global minimum with a weight reduction of 89%. 

In the plots, the yellow dots represent the step size and the blue dots the weight (kg). Below is a visualization of the truss design with dimensions.
|<img src="https://github.com/dossma/TrussOptimization/blob/main/Lokales_Optimum%2Cd%3D2.jpg" width=100% height=100%>|<img src="https://github.com/dossma/TrussOptimization/blob/main/Globales_Optimum%2Cd%3D6.jpg" width=100% height=100%>
|----------------------------------------------------|-----------------------------------------------------|
| optimization procedure converging to local minimum | optimization procedure converging to global minimum |

## Get started
Modify, if you wish, the parameters described above or run it unmodified with default configuration.

## Development setup
- [Matlab](https://www.mathworks.com/products/matlab.html)
or
- [Octave](https://octave.org/)

## Meta

Author: Jonas Dossmann

Distributed under the MIT license.

[https://github.com/dossma/](https://github.com/dossma/)
