#ifndef __QAGIF_ENC_API_H__
#define __QAGIF_ENC_API_H__

#include "QAGIFEncType.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef _BOOLANDBYTE_
#define _BOOLANDBYTE_
typedef enum {QFALSE, QTRUE}	QBOOL;
typedef unsigned char		QBYTE;
#endif // _BOOLANDBYTE_

int QAGIFEncInitHandle(QAGIFHandlePointer tmp);

void QAGIFEncSetUserTable(QAGIFHandlePointer tmp, QBYTE *palette, long size);

void QAGIFEncResetUserTable(QAGIFHandlePointer tmp);

QBOOL QAGIFEncAddFrame(QAGIFHandlePointer tmp, QBYTE* im, BitmapFormat format, int w, int h);

QBOOL QAGIFEncAddFrameMP(QAGIFHandlePointer tmp, QBYTE* im, BitmapFormat format, int w, int h);

QBOOL QAGIFEncAddFrameFast(QAGIFHandlePointer tmp, QBYTE* im, BitmapFormat format, int w, int h);

QBOOL QAGIFEncFinish(QAGIFHandlePointer tmp, int flag);

QBOOL QAGIFEncStart(QAGIFHandlePointer tmp, char* os);

void QAGIFEncSetMaxResolution(QAGIFHandlePointer tmp, int size);

void QAGIFEncSetDelay(QAGIFHandlePointer tmp, int ms);

void QAGIFEncSetDispose(QAGIFHandlePointer tmp, int code);

void QAGIFEncSetDither(QAGIFHandlePointer tmp, int ditherMethod);

void QAGIFEncSetRepeat(QAGIFHandlePointer tmp, int iter);

void QAGIFEncSetMaxTask(QAGIFHandlePointer tmp, int no);

QBOOL QAGIFEncSetMaxTaskTP(QAGIFHandlePointer tmp, int no);

void QAGIFEncSetTransparent(QAGIFHandlePointer tmp, int c);

void QAGIFEncSetTransparentIndex(QAGIFHandlePointer tmp, int c);

void QAGIFEncSetFrameRate(QAGIFHandlePointer tmp, float fps);

void QAGIFEncSetQuality(QAGIFHandlePointer tmp, int quality);

QBOOL QAGIFEncSetSize(QAGIFHandlePointer tmp, int w, int h);

QBOOL QAGIFEncSetGlobalSize(QAGIFHandlePointer tmp, int w, int h);

void QAGIFEncSetPosition(QAGIFHandlePointer tmp, int x, int y);

QBOOL QAGIFEncSetWriteFunc(QAGIFHandlePointer tmp, int type);

int QAGIFEncGetVersion(void);

#ifdef __cplusplus
}
#endif  /* __cplusplus */

#endif // __QAGIF_ENC_API_H__