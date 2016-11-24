# Quantum-Efficiency
Script for Matlab to calculate QE by Raw Bayer data, captured by Raspberry Pi script.

------------------------
Creative Commons license: https://goo.gl/Bt9Pwr
------------------------

### Program's tree:

**bayer_all.py** : Raspberry Pi script for capture images with space bar.  

        This Script must have intalled in a Rasp:  
          * py-getch: https://goo.gl/jeLuDv  
          * picamera: https://goo.gl/QFMRFa  
        
On Rasp's console: python camera.py  

**BayerRgb_to_RGB** : folder with MatLab script.  

        Open it on MatLab and follow the instruction on top.  
        
### Study step by step:  

**Raspberry setup**:  

1. Load the *bayer_all.py* on raspberry, you could use ```scp *folderName.zip* pi@IP:``` .

2. Put in front of raspberry camera the slit of monochromator.  

3. Run the script and follow the istruction on monitor. Step by step, move the trigger on monochromator and take a pic with space bar.  

4. The Rasp's script will save a *folderName.zip* file with your Raw Bayer data, called *numberX.npy* .  

5. You could use ```scp pi@IP:*folderName.zip* . ``` to grub the file from the raspberry to your Unix terminal destination pc ( linux or mac ) .  
