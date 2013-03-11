#!/bin/bash

VERSION="v5"
OUTDIR="../out"
ZIPDIR="../tools/zipfile"
PLACEHOLDER="Delete_before_compiling"
EXFAT_MOD="/home/ryuinferno/XXLSR_initramfs/lib/modules"
INITRAMFS_ANDROID="initramfs/ramdisk_boot"
INITRAMFS_RECOVERY="ramdisk_recovery"
INITRAMFS_RECOVERY_OLD="ramdisk_recovery_old"
INITRAMFS_RECOVERY_TOUCH="ramdisk_recovery_touch"
INITRAMFS_RECOVERY_MOD="ramdisk_recovery_mod"
MODULES=("fs/cifs/cifs.ko" "drivers/net/wireless/bcmdhd/dhd.ko" "drivers/scsi/scsi_wait_scan.ko" "drivers/samsung/j4fs/j4fs.ko")

  case "$1" in
  clean)
          make mrproper
          cp ${EXFAT_MOD}/exfat_fs.ko ${INITRAMFS_ANDROID}/lib/modules
          cp ${EXFAT_MOD}/exfat_core.ko ${INITRAMFS_ANDROID}/lib/modules
          rm -rf ${OUTDIR}
   ;;
   *)  
        mkdir -p ${OUTDIR}   
        make -j8 blazing_defconfig
       
        # create modules first to include in ramdisk
        make -j8 

        for module in "${MODULES[@]}" ; do
            cp "${module}" ${INITRAMFS_ANDROID}/lib/modules
        done  
        if [ ! -e ${INITRAMFS_ANDROID}/lib/modules/exfat_fs.ko ] || [ ! -e ${INITRAMFS_ANDROID}/lib/modules/exfat_core.ko ]; then   
          cp ${EXFAT_MOD}/exfat_fs.ko ${INITRAMFS_ANDROID}/lib/modules
          cp ${EXFAT_MOD}/exfat_core.ko ${INITRAMFS_ANDROID}/lib/modules
        fi
        chmod 644 ${INITRAMFS_ANDROID}/lib/modules/*

        # create the android ramdisk
        rm initramfs/stage1/boot.cpio
        cd ${INITRAMFS_ANDROID}
        find . | cpio -o -H newc > ../stage1/boot.cpio
        cd ..

        # create the recovery ramdisk, default is for 6.0.1.2, "old" is for 5.5.0.4, "touch" is for touch recovery, "mod" is for modified 6.0.2.8
      case "$1" in
      old)  
        rm stage1/recovery.cpio
        cd ${INITRAMFS_RECOVERY_OLD}
        cp recovery.cpio ../stage1/recovery.cpio
        cd ../..
      ;;
      touch)
        rm stage1/recovery.cpio
        cd ${INITRAMFS_RECOVERY_TOUCH}
        rm data/$PLACEHOLDER
        rm system/bin/$PLACEHOLDER
        rm tmp/$PLACEHOLDER
        find . | cpio -o -H newc > ../stage1/recovery.cpio
        echo > data/$PLACEHOLDER
        echo > system/bin/$PLACEHOLDER
        echo > tmp/$PLACEHOLDER
        cd ../..
      ;;
      mod)
        rm stage1/recovery.cpio
        cd ${INITRAMFS_RECOVERY_MOD}
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
        cd ${INITRAMFS_RECOVERY}
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
        cd ${OUTDIR}
      case "$1" in
      old)  
        tar -cf GT-I9100G_Blazing_Kernel_${VERSION}_CWM5.tar zImage
      ;;
      touch)  
        tar -cf GT-I9100G_Blazing_Kernel_${VERSION}_TOUCH.tar zImage
      ;;
      mod)  
        tar -cf GT-I9100G_Blazing_Kernel_${VERSION}_CWM6_MOD.tar zImage
      ;;
      *)
        tar -cf GT-I9100G_Blazing_Kernel_${VERSION}_CWM6.tar zImage
      ;;
      esac
      
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
      mod)  
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_CWM6_MOD.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_CWM6_MOD.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_CWM6_MOD.zip
      ;;
      *)
        echo "Creating flashable zip..."
        cd tools/zipfile
        zip -r Blazing_Kernel_${VERSION}_CWM6.zip *
        cd ..
        echo "Sigining zip..."
        java -jar signapk.jar -w testkey.x509.pem testkey.pk8 zipfile/Blazing_Kernel_${VERSION}_CWM6.zip ${OUTDIR}/Blazing_Kernel_${VERSION}_CWM6.zip
      ;;
      esac   
      rm zipfile/*.zip zipfile/zImage 
      cd ../kernel
   ;;
   esac
   
   
   
