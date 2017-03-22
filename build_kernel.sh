#!/bin/bash

export ARCH=arm64

ROOT_DIR=$(pwd)
OUT_DIR=$ROOT_DIR/out
BUILDING_DIR=$OUT_DIR/kernel_obj

JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
DATE=`date +%m-%d-%H:%M`

CROSS_COMPILER=/home/msdx321/workspace/android/toolchains/linaro-4.9.4/bin/aarch64-linux-gnu-

ANYKERNEL_DIR=$ROOT_DIR/misc/anykernel2
TEMP_DIR=$OUT_DIR/temp

DEFCONFIG=$1

FUNC_PRINT()
{
		echo ""
		echo "=============================================="
		echo $1
		echo "=============================================="
		echo ""
}

FUNC_CLEAN()
{
		FUNC_PRINT "Cleaning All"
		rm -rf $OUT_DIR
		mkdir $OUT_DIR
		mkdir -p $BUILDING_DIR
		mkdir -p $TEMP_DIR
}

FUNC_COMPILE_KERNEL()
{
		FUNC_PRINT "Start Compiling Kernel"
		make -C $ROOT_DIR O=$BUILDING_DIR $DEFCONFIG 
		make -C $ROOT_DIR O=$BUILDING_DIR -j$JOB_NUMBER ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILER
		FUNC_PRINT "Finish Compiling Kernel"
}


FUNC_PACK()
{
		FUNC_PRINT "Start Packing"
		cp -r $ANYKERNEL_DIR/* $TEMP_DIR
		cp $BUILDING_DIR/arch/arm64/boot/Image.gz-dtb $TEMP_DIR/zImage-dtb
        mkdir $TEMP_DIR/modules
        find . -type f -name "*.ko" | xargs cp -t $TEMP_DIR/modules
        find $TEMP_DIR -iname "*.ko" -exec /home/msdx321/workspace/android/toolchains/linaro-4.9.4/bin/aarch64-linux-gnu-strip --strip-debug {} \;
		cd $TEMP_DIR
		zip -r9 mKernel.zip ./*
		mv mKernel.zip $OUT_DIR/mKernel-$DATE.zip
		cd $ROOT_DIR
		FUNC_PRINT "Finish Packing"
}

START_TIME=`date +%s`
FUNC_CLEAN
FUNC_COMPILE_KERNEL
FUNC_PACK
END_TIME=`date +%s`

let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo "Total compile time is $ELAPSED_TIME seconds"
