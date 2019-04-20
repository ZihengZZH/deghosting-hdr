# deghosting-hdr

HDRI is to bridge the gap between what is available in the real-world in terms of light levels and what we can do to represent it using digital equipment. However, as this technique has been increasingly employed to mobile devices, the moving objects or cameras may introduce ghosting effect. It therefore requires deghosting methodology to address this issue, especially under the circumstance of multi-exposure stack HDRI, a common approach for mobile devices.

## The motivations behind the deghosting algorithms

Obtaining a high quality High Dynamic Range (HDR) image with the motion from either the camera or the objects has been a long-standing challenge. The motion is quite common especially when it comes to the consumer products, such as smartphones. It compromises the image quality by introducing *ghosting* artifacts (large motion) or *blurring* artifacts (small motion).

First, we need to clarify three different approaches to obtain an HDR image (aka the *acquisition* stage):
1. by using specialized hardware to directly capture HDR data (**RAW**)
2. by reconstructing an HDR image from a **stack** of low dynamic range (*LDR*) images of the scene with different exposure settings
3. by expanding the dynamic range of a normally LDR image through **pseudo-multi-exposure** or **inverse tone mapping**.

All these approaches have been investigated for a long time and only the second one, multiple exposure method, will introduce *ghost* artifacts. The other two produce inherently ghost-free HDR images as they operate on data captured at **a single time instance**.

## The mathematics behind the *ghost* artifacts:

Let $L(p)$ represent an LDR image pixel $p$ and its irradiance $E(p)$ for $\Delta t$ units of time.

$L(p) = f(E(p) \cdot \Delta t)$

where $f$ represents the camera response function (CRF). The correct sensor irradiance from the image pixel intensity could be recovered from the following equation.

$E(p) = \frac{f^{-1}(L(p))}{\Delta t}$

Once $f$ is obtained, the HDR value $H(p)$ can be computed as follows.

$H(p) = \frac{\sum^{N}_{n=1} \alpha (L_n (p)) \cdot E(p)}{\sum^{N}_{n=1} \alpha (L_n (p))}$

where $\alpha$ is a weighting function which depends on the pixel intensity level. Many researches have paid attention to other factors that 'must' be taken into account when determining the optimal weighting function: e.g. camera noise.

However, the critical assumption of the equation above is that all the input images $L_1, L_2, ..., L_n$ measure the same scene radiance value for each pixel position $p$.

$\frac{f^{-1}(L_n(p))}{\Delta t_n} = \frac{f^{-1}(L_m(p))}{\Delta t_m}$             
$\forall n, m, p$

If this assumption, known as *reciprocity*, does not hold, $H(p)$ will be equal to the weighted sum of different sensor irradiance values, resulting in semi-transparent object appearances known as **ghosts**.

The requirement of a pixel measuring the **same** irradiance in all input exposures necessitates that the camera and the scene remain static throughout the capture process. 

More could refer to [tursun2015](https://onlinelibrary.wiley.com/doi/full/10.1111/cgf.12593)

> **radiance** -- amount of light that is emitted from a scene and falls within a given solid angle in a specified direction (ONE DIRECTION)

> **irradiance** -- radiant flux (power) received by a surface per unit area (ALL DIRECTIONS)

## The taxonomy of HDR deghosting methods

Both Sen2012 and Hu2013 are categorized into the *patch-based* **moving object registration methods**. **Moving object registration methods** focus on recovering or reconstructing the ghost pixels by searching for the best matching region in other exposures or in the affected image. The matching regions are used to transfer information to the problematic region.

The main difference between the registration-based deghosting algorithms is the **alignment strategy** (e.g. SIFT, Harris corner detector), or the **alignment quality metric** (e.g. Sum of Squared Difference, Cross-Correlation).

Patch-based methods use image patches and patch-based matching strategies to eliminate ghost regions.

Sen2012 is a state-of-the-art patch-based algorithm. The algorithm performs joint optimization of image alignment and HDR merging. Sen2012 also requires the definition of a reference image, which needs to be defined by the user.

Hu2013 is another patch-based algorithm that produces a registered stack from a sequence of misaligned images of dynamic scenes. The algorithm automatically selects an image with most well-exposed pixels to be the reference image.

## Sen2012 vs Hu2013

As opposed to Sen2012, Hu2013 does not require the CRFs of the input images to be linear. Hu2013 is more successful at producing noise-free outputs whereas Sen2012 is better at preserving texture details.

In Karaduzovic2014, authors reported the comparison between Sen2012 and Hu2013:

* Sen2012

The final results is greatly impacted by the selection of the reference image. The algorithm cannot extend the dynamic range of large saturated regions of the reference by using information from other exposures. In general, the algorithm produces images of high global contrast (dynamic range), with pure colors and low black level. The algorithm generates images with a higher amount of noise than other algorithms tested. It also struggles with non-rigid and high texture regions with motion if they contained HDR content. Usually, the algorithm successfully handles deghosting and occluded regions in the scene.

* Hu2013

The algorithm selects a reference image and performs alignment of remaining exposures. We observed that the algorithm produces images of lower contrast (dynamic range) than Sen2012. The black level is elevated. The algorithm sometimes distorts textures in the merged HDR image. Non-rigid scenes, rippling water surfaces with large portions of sun reflection contain visible artifacts and produce an unnatural HDR image. The algorithm is good in deghosting.

