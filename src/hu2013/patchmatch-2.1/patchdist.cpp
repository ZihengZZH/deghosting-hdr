
// MATLAB interface, for vote().

#include "allegro_emu.h"
#include "mex.h"
#include "nn.h"
//#include "matrix.h"
#include "mexutil.h"

void mexFunction(int nout, mxArray *pout[], int nin, const mxArray *pin[]) {
  if (nin < 3) { mexErrMsgTxt("votemex called with < 3 input arguments"); }

  const mxArray *A = pin[0], *B = pin[1], *Ann = pin[2];  
  BITMAP *a = NULL, *b = NULL;
  int aw, ah;
  
  
  a = convert_bitmap(A);
  aw = a->w; ah = a->h;
          
  b = convert_bitmap(B);

  Params *p = new Params();
  // [bnn=[]], [algo='cpu'], [patch_w=7], [bmask=[]], [bweight=[]], [coherence_weight=1], [complete_weight=1], [amask=[]], [aweight=[]]

  int i = 3;
  
  if (nin > i && !mxIsEmpty(pin[i])) {
    if			(mxStringEquals(pin[i], "cpu")) { p->algo = ALGO_CPU; }
    else if (mxStringEquals(pin[i], "gpucpu")) { p->algo = ALGO_GPUCPU; }
    else if (mxStringEquals(pin[i], "cputiled")) { p->algo = ALGO_CPUTILED; }
    else { mexErrMsgTxt("Unknown algorithm"); }
  } i++;
  if (nin > i && !mxIsEmpty(pin[i])) { p->patch_w = int(mxGetScalar(pin[i])); } i++;

  int aclip = 0;
  BITMAP *ann = convert_field(p, Ann, b->w, b->h, aclip);

  BITMAP *annd = init_dist(p, a, b, ann, NULL, NULL, NULL);
  
  
  mxArray *ans = NULL;
  mwSize dims[2] = { ah, aw };
  ans = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
  int *data = (int *) mxGetData(ans);
  int *dchan = &data[0];
  for (int y = 0; y < ah; y++) {
    int *annd_row = (int *) annd->line[y];
    for (int x = 0; x < aw; x++) {
      int pos = y + x * ah;
      dchan[pos] = annd_row[x];
    }
  }  
  
  pout[0] = ans;
  

  delete p;
  destroy_bitmap(a);
  destroy_bitmap(b);
  destroy_bitmap(ann);
  destroy_bitmap(annd);
}
