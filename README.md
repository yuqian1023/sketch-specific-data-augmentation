# sketch-specific data-augmentation

###Introduction

This repository contains the code for the implementation of sketch-specific data augmentation strategies proposed in the paper: 
"Sketch Me *That* Shoe" (stroke removal, stroke deformation) and "Sketch-a-Net: A Deep Neural Network that Beats Humans" (sketch deformation)

And if you use the code for your research, please cite our paper:

    @inproceedings{yu2016sketch,
            title={Sketch me that shoe},
            author={Yu, Qian and Liu, Feng and Song, Yi-Zhe and Xiang, Tao and Hospedales, Timothy M and Loy, Chen Change},
            booktitle={Computer Vision and Pattern Recognition (CVPR), 2016 IEEE Conference on},
            pages={799--807},
            year={2016},
            organization={IEEE}
    }

    @article{yu2017sketch,
            title={Sketch-a-net: A deep neural network that beats humans},
            author={Yu, Qian and Yang, Yongxin and Liu, Feng and Song, Yi-Zhe and Xiang, Tao and Hospedales, Timothy M},
            journal={International Journal of Computer Vision},
            volume={122},
            number={3},
            pages={411--425},
            year={2017},
            publisher={Springer}
    }

	
####Contents

1. [Stroke removal]

2. [Sketch deformation]

3. [Run the code]

3. [Extra comment]


###stroke removal

script file: deformation_script.m
  
main function: stroke_deformation.m
  
bezier_def.m

###sketch deformation

script file: removal_script.m

main function: stroke_removal.m

###Run the code

1. Create the folder 'def_local', 'def_local_global' and 'rm' to save the generated sketches.

2. Run ``` deformation_script.m``` to generate new sketches with deformation (both stroke-level and sketch-level), and run ``` removal_script.m``` to get sketches with stroke removel.
	
###Extra comment

1. 'altmany-export_fig-e1b8666' is the toolbox used to export PNG files. The output images with sketch deformation is a little bit of different with our previous implementations (position shifts a bit and the stroke is thicker than before). This is caused by the updated version of the toolbox.

2. 'MLS'(http://uk.mathworks.com/matlabcentral/fileexchange/12249-moving-least-squares) is used for sketch/stroke deformation.

3. In the folder 'svg', there are several example sketches used as the source sketches. They are all from TU-Berlin dataset(http://cybertron.cg.tu-berlin.de/eitz/pdf/2012_siggraph_classifysketch.pdf).

4. Due to the export operation, the function of sketch deformation works slowly.

