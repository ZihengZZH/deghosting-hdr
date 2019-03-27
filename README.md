# HDRI (High Dynamic Range Imaging)

HDRI is to bridge the gap between what is available in the real-world in terms of light levels and what we can do to represent it using digital equipment. 

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

where $\alpha$ is a weighting function which depends on the pixel intensity level. 

However, the critical assumption of the equation above is that all the input images $L_1, L_2, ..., L_n$ measure the same scene radiance value for each pixel position $p$.

$\frac{f^{-1}(L_n(p))}{\Delta t_n} = \frac{f^{-1}(L_m(p))}{\Delta t_m}$             
$\forall n, m, p$

If this assumption, known as *reciprocity*, does not hold, $H(p)$ will be equal to the weighted sum of different sensor irradiance values, resulting in semi-transparent object appearances known as **ghosts**.


More could refer to [tursun2015](https://onlinelibrary.wiley.com/doi/full/10.1111/cgf.12593)

> **radiance** -- amount of light that is emitted from a scene and falls within a given solid angle in a specified direction (ONE DIRECTION)

> **irradiance** -- radiant flux (power) received by a surface per unit area (ALL DIRECTIONS)

