#ifndef __QAGIF_TYPE_H__
#define __QAGIF_TYPE_H__

#ifndef _BOOLANDBYTE_
#define _BOOLANDBYTE_
typedef enum {QFALSE, QTRUE}	QBOOL;
typedef unsigned char		QBYTE;
#endif // _BOOLANDBYTE_

#ifndef _STDIO_H__
#define _STDIO_H__
#include <stdio.h>
#endif

typedef struct
{
	int left;
	int right;
	int top;
	int bottom;
} QRect;

typedef enum  {
    BITMAP_FORMAT_NONE      = 0,
    BITMAP_FORMAT_RGBA_8888 = 1,
    BITMAP_FORMAT_RGB_565   = 4,
    BITMAP_FORMAT_RGBA_4444 = 7,
    BITMAP_FORMAT_A_8       = 8,
} BitmapFormat;

typedef struct
{
	//int useJNIEnv;
	void* env;
	void* obj;
	void* methodID;

	int buffersize;
	int bufferpoint;
	unsigned char* buffer;

} QuramJNIEnv;

typedef struct _tastargs 
{
	QBYTE *img;
	BitmapFormat format;
	int w;
	int h;
	int currentTask;
	int isFirst;
	void *parent;
	int isDone;
	int finishF;
	int finishF2;
	unsigned long taskID;
	int curFrame;
	QuramJNIEnv* jniEnv1;
	int flag;
	int CFcnt;
	int maxTP;
	
} QuramTaskArgs;

typedef struct quramtaskhandle
{
	int maxTask;
	int currentTask;
	QuramTaskArgs *taskList;
	int curFrame;
	int flag;
	int MPflag;
} QuramTaskHandle;

typedef enum  {
    IO_FILE		= 0,
    IO_BUFFER		= 1,
} OutputType;

typedef int (*AGIFWriteFunc) (QuramJNIEnv*, int, void *);

typedef struct{

	int globalFrameWidth;

	int globalFrameHeight;
	 
	int width;

	int height;

	int x;
	
	int y;

	int transparent;

	int transIndex;

	int transIndexSetFlag;

	int repeat;					// 매 사진 돌아가는 반복 횟수

	int delay;					// 각 그림마다의 간격

	QBOOL started;

	FILE* out;				long outSize;

	QBYTE* srcImage;

	QBYTE* image;			long imageSize;

	QBYTE* pixels;			long pixelsSize;

	QBYTE* indexedPixels;	long indexedPixelsSize;

	int colorDepth;

	QBYTE* colorTab;			long colorTabSize;

	QBYTE *userTab;			long userTabSize;

	QBOOL usedEntry[256];

	int palSize;

	int dispose;

	int dither;

	QBOOL closeStream;

	QBOOL firstFrame;

	QBOOL sizeSet;

	int sample;
	
	int flag;

	int quantizeMethod;

	AGIFWriteFunc 		writeFunc;

	QuramJNIEnv*		jniEnv;
	QuramJNIEnv*		jniEnv1;

	OutputType		outType;

	int threadflag;

	QBYTE *onScreenImage;

	QuramTaskHandle taskInfo;

	QuramTaskHandle *tpInfo;

	struct threadpool *pool;

	int isMP;
	
	int Done;

	int maxResolution;

}QAGIFHandle;

typedef QAGIFHandle* QAGIFHandlePointer;

#endif //__QAGIF_TYPE_H__