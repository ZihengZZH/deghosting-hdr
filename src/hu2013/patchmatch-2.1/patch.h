
/* Patch distance templates. */

// Three groups of functions
// fast_patch_dist:			taking adata, b_bitmap, and do early termination according to maxval
// fast_patch_nobranch:	taking adata, b_bitmap, but NO early termination
// patch_dist_ab:				taking a_bitmap, b_bitmap, and do early termination according to maxval
// 
// Use template specialization to speed up for smaller patch sizes
//

#ifndef _patch_h
#define _patch_h

#include "allegro_emu.h"
#include "nn.h"

//All Added by Jun Hu
//#define TRUNCATION_VALUE 13
//#define TRUNCATION(X)  ((X) < TRUNCATION_VALUE ? (X) : TRUNCATION_VALUE)
//#define MIN(a,b) (((a)<(b))?(a):(b))

#define USE_TRUNCATED 1 //Added by Jun Hu

#if USE_TRUNCATED 
#define NORM1(dr, d) MIN(abs(dr), d)
#define NORM2(dr, d) MIN(dr*dr, d) 
#else
#define NORM1(dr, d) abs(dr)
#define NORM2(dr, d) dr*dr
#endif


#define USE_L1 0

#define ALLOC_ADATA int adata[PATCH_W*PATCH_W];

#if USE_L1 //Revisited By Jun Hu
#define DELTA_TERM_R(dr, d) (NORM1(dr, d))
#define DELTA_TERM_RGB_ex(dr, dg, db, d) (NORM1(dr, d)+NORM1(dg, d)+NORM1(db, d))
#else
#define DELTA_TERM_R(dr, d) (NORM2(dr, d))
#define DELTA_TERM_RGB_ex(dr, dg, db, d) (NORM2(dr, d)+NORM2(dg, d)+NORM2(db, d))
#endif
//#define DELTA_TERM DELTA_TERM_RGB_ex(dr, dg, db)
//#define DELTA_TERM_RGB(dr, dg, db) DELTA_TERM_RGB_ex(dr, dg, db)
#define DELTA_TERM DELTA_TERM_RGB_ex(dr, dg, db, INT_MAX)
#define DELTA_TERM_RGB(dr, dg, db) DELTA_TERM_RGB_ex(dr, dg, db,INT_MAX)


template<int TPATCH_W, int IS_WINDOW>
//int fast_patch_dist(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p) { Revisited by Jun Hu
int fast_patch_dist(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p, int d = INT_MAX) {
	if (IS_WINDOW) {
		int ans = 0;
		for (int dy = 0; dy < TPATCH_W; dy++) {
			int *row2 = ((int *) b->line[by+dy])+bx;
			for (int dx = 0; dx < TPATCH_W; dx++) {
				unsigned int c1 = adata[dx];
				unsigned int c2 = row2[dx];
				int dr = (c1&255)-(c2&255);
				int dg = ((c1>>8)&255)-((c2>>8)&255);
				int db = (c1>>16)-(c2>>16);
				dr *= p->weight_r;
				dg *= p->weight_g;
				db *= p->weight_b;
				ans += DELTA_TERM_RGB_ex(dr,dg,db,d);    //ans += dr*dr+dg*dg+db*db;  Revisited by Jun Hu
				if (ans > maxval) { return ans; } // early termination, the only difference from fast_patch_nobranch
			}
			adata += TPATCH_W; // trick here to advance pointer adata
		}
		return ans;
	} // end of (IS_WINDOW == true)
	else {
		int ans = 0;
		for (int dy = 0; dy < TPATCH_W; dy++) {
			int *row2 = ((int *) b->line[by+dy])+bx;
			for (int dx = 0; dx < TPATCH_W; dx++) {
				unsigned int c1 = adata[dx];
				unsigned int c2 = row2[dx];
				int dr = (c1&255)-(c2&255);
				int dg = ((c1>>8)&255)-((c2>>8)&255);
				int db = (c1>>16)-(c2>>16);
				ans += DELTA_TERM_RGB_ex(dr,dg,db,d);    //ans += dr*dr+dg*dg+db*db;  Revisited by Jun Hu
				if (ans > maxval) { return ans; }
			}
			adata += TPATCH_W;
		}
		return ans;
	}
}


// !!!Note: this speeds up greatly
template<>
int fast_patch_dist<1, 0>(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p, int d); //Revisited by Jun Hu
//int fast_patch_dist<1, 0>(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p);

template<>
int fast_patch_dist<2, 0>(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p, int d);

template<>
int fast_patch_dist<3, 0>(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p, int d);

template<>
int fast_patch_dist<4, 0>(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p, int d);

template<>
int fast_patch_dist<5, 0>(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p, int d);

template<>
int fast_patch_dist<6, 0>(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p, int d);

template<>
int fast_patch_dist<7, 0>(int *adata, BITMAP *b, int bx, int by, int maxval, Params *p, int d);

// !!!notice that "err", "xbest", "ybest" might be changed in this function
template<int PATCH_W, int IS_MASK, int IS_WINDOW>
void attempt_n(int &err, int &xbest, int &ybest, int *adata, BITMAP *b, int bx, int by, BITMAP *bmask, RegionMasks *region_masks, int src_mask, Params *p) {
	if ((bx != xbest || by != ybest) &&
		(unsigned) bx < (unsigned) (b->w-PATCH_W+1) &&
		(unsigned) by < (unsigned) (b->h-PATCH_W+1)) 
	{
		if (IS_MASK && region_masks && src_mask != ((int *) region_masks->bmp->line[by])[bx]) { return; }
		if (IS_MASK && bmask && ((int *) bmask->line[by])[bx]) { return; }
		
		//Revisited by Jun Hu
		//int current = fast_patch_dist<PATCH_W, IS_WINDOW>(adata, b, bx, by, err, p); 
		int current = fast_patch_dist<PATCH_W, IS_WINDOW>(adata, b, bx, by, err, p, INT_MAX);
		if (current < err) {
			err = current;
			xbest = bx;
			ybest = by;
		}
	}
}

template<int TPATCH_W, int IS_WINDOW>
int fast_patch_nobranch(int *adata, BITMAP *b, int bx, int by, Params *p) {
	//if (IS_MASK && bmask && ((int *) bmask->line[by])[bx]) { return INT_MAX; }
	if (IS_WINDOW) {
		int ans = 0;
		for (int dy = 0; dy < TPATCH_W; dy++) {
			int *row2 = ((int *) b->line[by+dy])+bx;
			for (int dx = 0; dx < TPATCH_W; dx++) {
				unsigned int c1 = adata[dx];
				unsigned int c2 = row2[dx];
				int dr = (c1&255)-(c2&255);
				int dg = ((c1>>8)&255)-((c2>>8)&255);
				int db = (c1>>16)-(c2>>16);
				dr *= p->weight_r;
				dg *= p->weight_g;
				db *= p->weight_b;
				ans += DELTA_TERM_RGB_ex(dr,dg,db,INT_MAX);    //ans += dr*dr+dg*dg+db*db;  Revisited by Jun Hu
			}
			adata += TPATCH_W; // this is the trick!!!
		}
		return ans;
	} else {
		int ans = 0;
		for (int dy = 0; dy < TPATCH_W; dy++) {
			int *row2 = ((int *) b->line[by+dy])+bx;
			for (int dx = 0; dx < TPATCH_W; dx++) {
				unsigned int c1 = adata[dx];
				unsigned int c2 = row2[dx];
				int dr = (c1&255)-(c2&255);
				int dg = ((c1>>8)&255)-((c2>>8)&255);
				int db = (c1>>16)-(c2>>16);
				ans += DELTA_TERM_RGB_ex(dr,dg,db,INT_MAX);    //ans += dr*dr+dg*dg+db*db;  Revisited by Jun Hu
			}
			adata += TPATCH_W;
		}
		return ans;
	}
}

template<>
int fast_patch_nobranch<1, 0>(int *adata, BITMAP *b, int bx, int by, Params *p);

template<>
int fast_patch_nobranch<2, 0>(int *adata, BITMAP *b, int bx, int by, Params *p);

template<>
int fast_patch_nobranch<3, 0>(int *adata, BITMAP *b, int bx, int by, Params *p);

template<>
int fast_patch_nobranch<4, 0>(int *adata, BITMAP *b, int bx, int by, Params *p);

template<>
int fast_patch_nobranch<5, 0>(int *adata, BITMAP *b, int bx, int by, Params *p);

template<>
int fast_patch_nobranch<6, 0>(int *adata, BITMAP *b, int bx, int by, Params *p);

template<>
int fast_patch_nobranch<7, 0>(int *adata, BITMAP *b, int bx, int by, Params *p);

template<int TPATCH_W, int IS_WINDOW, int HAS_MASKS>
//int patch_dist_ab(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks) { Revisited by Jun Hu
int patch_dist_ab(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks, int d = INT_MAX) {
  if (region_masks && ((int *) region_masks->bmp->line[ay])[ax] != ((int *) region_masks->bmp->line[by])[bx]) { return INT_MAX; }
	
	if (IS_WINDOW) {
		int ans = 0;
		for (int dy = 0; dy < TPATCH_W; dy++) {
			int *row1 = ((int *) a->line[ay+dy])+ax;
			int *row2 = ((int *) b->line[by+dy])+bx;
			for (int dx = 0; dx < TPATCH_W; dx++) {
				int c1 = row1[dx];
				int c2 = row2[dx];
				int dr = (c1&255)-(c2&255);
				int dg = ((c1>>8)&255)-((c2>>8)&255);
				int db = (c1>>16)-(c2>>16);
				dr *= p->weight_r;
				dg *= p->weight_g;
				db *= p->weight_b;
				ans += DELTA_TERM_RGB_ex(dr,dg,db,d);    //ans += dr*dr+dg*dg+db*db;  Revisited by Jun Hu
				if (ans > maxval) { return ans; }
			}
		}
		return ans;
	} else {
		int ans = 0;
		for (int dy = 0; dy < TPATCH_W; dy++) {
			int *row1 = ((int *) a->line[ay+dy])+ax;
			int *row2 = ((int *) b->line[by+dy])+bx;
			for (int dx = 0; dx < TPATCH_W; dx++) {
				int c1 = row1[dx];
				int c2 = row2[dx];
				int dr = (c1&255)-(c2&255);
				int dg = ((c1>>8)&255)-((c2>>8)&255);
				int db = (c1>>16)-(c2>>16);
				ans += DELTA_TERM_RGB_ex(dr,dg,db,d);    //ans += dr*dr+dg*dg+db*db;  Revisited by Jun Hu
				if (ans > maxval) { return ans; }
			}
		}
		return ans;
	}
}

template<>
//int patch_dist_ab<1, 0, 0>(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks); Revisited by Jun Hu
int patch_dist_ab<1, 0, 0>(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks, int d);


template<>
int patch_dist_ab<2, 0, 0>(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks, int d);

template<>
int patch_dist_ab<3, 0, 0>(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks, int d);

template<>
int patch_dist_ab<4, 0, 0>(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks, int d);

template<>
int patch_dist_ab<5, 0, 0>(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks, int d);

template<>
int patch_dist_ab<6, 0, 0>(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks, int d);

template<>
int patch_dist_ab<7, 0, 0>(Params *p, BITMAP *a, int ax, int ay, BITMAP *b, int bx, int by, int maxval, RegionMasks *region_masks, int d);

#endif
