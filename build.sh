#!/bin/bash

VERSION="v10"
OUTDIR="../out"
ZIPDIR="../tools/zipfile"
PLACEHOLDER="Delete_before_compiling"
ANDROID="initramfs/ramdisk_boot"
ANDROID2="ramdisk_boot1"
RECOVERY="ramdisk_recovery"
RECOVERY_OLD="ramdisk_recovery_old"
RECOVERY_TOUCH="ramdisk_recovery_touch"
RECOVERY_MOD="ramdisk_recovery_mod"
RECOVERY_TWRP="ramdisk_recovery_twrp"
RECOVERY_PHILZ="ramdisk_recovery_philz"
MODULES_EXT=("fs/cifs/cifs.ko" "drivers/samsung/j4fs/j4fs.ko" "net/sunrpc/sunrpc.ko" "net/sunrpc/auth_gss/auth_rpcgss.ko" "fs/nfs/nfs.ko" "fs/lockd/lockd.ko")
MODULES=("drivers/net/wireless/bcmdhd/dhd.ko" "drivers/scsi/scsi_wait_scan.ko")
START=$(date +%s)

  case "$1" in
  clean)
          make mrproper
          rm -rf ${OUTDIR}
          rm -f ../tools/zipfile/system/lib/modules/cifs.ko
          rm -f ../tools/zipfile/system/lib/modules/dhd.ko
          rm -f ../tools/zipfile/system/lib/modules/j4fs.ko
          rm -f ../tools/zipfile/system/lib/modules/scsi_wait_scan.ko
          rm -f ../tools/zipfile/system/lib/modules/pvrsrvkm_sgx540_120.ko
          rm -f ../tools/zipfile/system/lib/modules/auth_rpcgss.ko
          rm -f ../tools/zipfile/system/lib/modules/nfs.ko.ko
          rm -f ../tools/zipfile/system/lib/modules/lockd.ko
          rm -f ../tools/zipfile/system/lib/modules/sunrpc.ko
   ;;
   *)  
        mkdir -p ${OUTDIR}   
        make -j8 blazing_defconfig
       
        # create modules first to include in ramdisk
        make -j8 

        for module in "${MODULES[@]}" ; do
            cp "${module}" ${ANDROID}/lib/modules
            cp "${module}" ../tools/zipfile/system/lib/modules
        done  
        chmod 644 ${ANDROID}/lib/modules/*
        
        for module in "${MODULES_EXT[@]}" ; do
            cp "${module}" ../tools/zipfile/system/lib/modules
        done
        chmod 644 ../tools/zipfile/system/lib/modules/*

        cd usr/pvr-source/eu*/bu*/li*/om*
        make -j8 ARCH=arm KERNEL_CROSS_COMPILE=/opt/arm-eabi-4.6/bin/arm-eabi- CROSS_COMPILE=/opt/arm-eabi-4.6/bin/arm-eabi- KERNELDIR=~/Repos/Dual/kernel TARGET_PRODUCT="blaze_tablet" BUILD=release TARGET_SGX=540 PLATFORM_VERSION=4.0
        mv ../../../bi*/target/pvrsrvkm_sgx540_120.ko ../../../../../../../tools/zipfile/system/lib/modules
        rm -r ../../../bi*
        cd ../../../../../..

        # create the android ramdisk
        rm initramfs/stage1/boot.cpio
        cd ${ANDROID}
        rm lib/modules/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/boot.cpio
        echo > lib/modules/$PLACEHOLDER
        cd ..

        rm stage1/boot1.cpio
        cd ${ANDROID2}
        rm data/$PLACEHOLDER
        rm system/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/boot1.cpio
        echo > data/$PLACEHOLDER
        echo > system/$PLACEHOLDER
        cd ..

        # create the recovery ramdisk, "cwm6" is for 6.0.1.2, "old" is for 5.5.0.4, "touch" is for touch recovery, "twrp" for TWRP 2.5; default is modified 6.0.3.1
      case "$1" in
      old)  
        rm stage1/recovery.cpio
        cd ${RECOVERY_OLD}
        cp recovery.cpio ../stage1/recovery.cpio
        cd ../..
      ;;
      touch)
        rm stage1/recovery.cpio
        cd ${RECOVERY_TOUCH}
        rm data/$PLACEHOLDER
        rm system/bin/$PLACEHOLDER
        rm tmp/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/recovery.cpio
        echo > data/$PLACEHOLDER
        echo > system/bin/$PLACEHOLDER
        echo > tmp/$PLACEHOLDER
        cd ../..
      ;;
      cwm6)
        rm stage1/recovery.cpio
        cd ${RECOVERY}
        rm data/$PLACEHOLDER
        rm system/bin/$PLACEHOLDER
        rm tmp/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/recovery.cpio
        echo > data/$PLACEHOLDER
        echo > system/bin/$PLACEHOLDER
        echo > tmp/$PLACEHOLDER
        cd ../..
      ;;
      twrp)
        rm stage1/recovery.cpio
        cd ${RECOVERY_TWRP}
        rm data/$PLACEHOLDER
        rm system/bin/$PLACEHOLDER
        rm tmp/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/recovery.cpio
        echo > data/$PLACEHOLDER
        echo > system/bin/$PLACEHOLDER
        echo > tmp/$PLACEHOLDER
        cd ../..
      ;;
      philz)
        rm stage1/recovery.cpio
        cd ${RECOVERY_PHILZ}
        rm data/$PLACEHOLDER
        rm system/bin/$PLACEHOLDER
        rm tmp/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/recovery.cpio
        echo > data/$PLACEHOLDER
        echo > system/bin/$PLACEHOLDER
        echo > tmp/$PLACEHOLDER
        cd ../.. 
      ;;
      *)
        rm stage1/recovery.cpio
        cd ${RECOVERY_MOD}
        rm data/$PLACEHOLDER
        rm system/bin/$PLACEHOLDER
        rm tmp/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/recovery.cpio
        echo > data/$PLACEHOLDER
        echo > system/bin/$PLACEHOLDER
        echo > tmp/$PLACEHOLDER
        cd ../.. 
      ;;
      esac
        
        # build the zImage
        echo 0 > .version
        make -j8
        cp arch/arm/boot/zImage ${OUTDIR}
        cp arch/arm/boot/zImage ${ZIPDIR}
     
      cd ..

      case "$1" in
      old)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_CWM5.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_CWM5.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_CWM5.zip
      ;;
      touch)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_TOUCH.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_TOUCH.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_TOUCH.zip
      ;;
      cwm6)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_CWM6.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_CWM6.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_CWM6.zip
      ;;
      twrp)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_TWRP.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_TWRP.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_TWRP.zip
      ;;
      philz)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_PHILZ.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_PHILZ.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_PHILZ.zip
      ;;
      *)
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_CWM6_MOD.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_CWM6_MOD.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_CWM6_MOD.zip
      ;;
      esac   
      rm zipfile/*.zip zipfile/zImage 
      cd ../kernel
   ;;
   esac

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
echo -ne "\033[32mElapsed: "
[ $E_MIN != 0 ] && echo -ne "$E_MIN min(s) "
echo -e "$E_SEC sec(s)\033[0m"
