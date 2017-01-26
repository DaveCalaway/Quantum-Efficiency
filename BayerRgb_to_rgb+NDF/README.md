# Quantum-Efficiency
Script for Matlab to calculate QE by Raw Bayer data end NDF Filter, captured by Raspberry Pi [script](https://goo.gl/5aY3ID).  

Remember to compose your Raw Bayer folder with inside:  
* the *NDF* folder ( please respect the name's folder ) with Monochromator Spectrum response with specific NDFilter.  
* the *OP_X.xlsx* file Optical Density. If you have used a multiple NDFilter don't worry, add all xlsx files.

Folder example:
![Folder Example](https://raw.githubusercontent.com/DaveCalaway/Quantum-Efficiency/master/BayerRgb_to_rgb+NDF/folder_example.png)

Useful formula for convert Optical Density to Optical Transmission%:

    OD  = log10(100/OT%)

**Status:** Alpha.

------------------------
Creative Commons license: https://goo.gl/Bt9Pwr
