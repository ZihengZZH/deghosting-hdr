# multi-exposure image stack for HDRI

According to the README.txt, this dataset contains a set of RAW and JPEG image stacks of multi-exposure image sequences that could be used for testing HDR reconstruction and deghosting methods. The **unique** feature of this dataset is that it contains both test image stacks, with motion and misalignment, and motion-free reference image stacks, which can be used with full-reference image quality metrics. 

The complete dataset consists of 36 scenes, provided as:
* RAW (*Canon*) image stacks
* JPEG image stacks
* Merged HDR image (*based on several methods*)

The 36 scenes are organized into **9** categories of motion types, each containing **4** image sets. The category of the motion types are as follow. 

| type          | description               | 
| --            | --                        |
| complex       | Highly dynamic scene with small/large motion displacement of small/large objects, non-rigid motion, occlusion, and several independently moving objects |
| hand-hold     | Static scene captured with a hand-hold camera |
| lolm          | Large object displacement with large motion   |
| losm          | Large object displacement with small motion   |
| multiview     | Multi-view sequence of a static scene         |
| nrm           | Motion of non-rigid and high texture objects  |
| occlusion     | Scene containing occlusion                    |
| solm          | Small object displacement with large motion   |
| sosm          | Small object displacement with small motion   |
