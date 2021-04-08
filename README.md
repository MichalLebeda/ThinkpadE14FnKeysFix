# Thinkpad E14 Fn Keys Fix  
## Intro
**NOTICE:** This currently does **NOT work** with **automatically generated GRUB config** file  
Please use the linked script bellow or create PR as I don't use GRUB at all.   

I wrote this script as a more universal way of fixing Fn keys on Thinkpad E14 gen. 2.  
Please note that there is an another [script](https://github.com/masksshow/Thinkpad-E14-15-AMD-Gen-2-FIX), but it only works with GRUB and touches system (which I don't like)

## Run  
Run script to generate acpi_override.img:  
```./create_img.sh```  

## Installing acpi_override.img  
Copy the file to ```/boot``` first
```sudo cp acpi_override.img /boot```
### GRUB
- **Currently works only if you manage your GRUB config file manually**  
- Edit ```/boot/grub/grub.cfg```
    <pre>
    ...
    echo 'Loading initial ramdisk'
    initrd <b>/boot/acpi_override.img</b> /boot/initramfs-linux.img
    ...
    </pre>
###  Refind  
- If you use ```/boot/refind_linux.conf```:  
    - Add ```initrd=\boot\acpi_override.img``` (notice backslashes) as the **first** ```initrd``` option:  
        <pre>"Some name" "<... splash <b>initrd=\boot\acpi_override.img</b> initrd=\boot\initrd.img-%v-generic"</pre>
- If you use ```refind.conf``` (```/boot/EFI/BOOT/refind.conf```)   
    - Add ```initrd=\boot\acpi_override.img``` (notice backslashes) at the end of the options:  
        <pre>
        menuentry "Arch Linux" {
            icon     /EFI/refind/icons/os_arch.png
            volume   "Arch Linux"
            loader   /boot/vmlinuz-linux
            initrd   /boot/initramfs-linux.img
            options  "root=PARTUUID=... rw add_efi_memmap <b>initrd=\boot\acpi_override.img</b>"
            submenuentry "Boot using fallback initramfs" {
                initrd /boot/initramfs-linux-fallback.img
            }
            submenuentry "Boot to terminal" {
                add_options "systemd.unit=multi-user.target"
            }
            disabled
        }
        </pre>


## Resources
- ASL tutorial: [link](https://acpica.org/sites/acpica/files/asl_tutorial_v20190625.pdf)
- Refind automatic boot stanza with ACPI override: [link](https://askubuntu.com/a/1279476)
- Thinkpad Carbon X1 Gen6, S3 state fix: [link](https://delta-xi.net/blog/#056)
- Another working script (but it is GRUB only): [link](https://github.com/masksshow/Thinkpad-E14-15-AMD-Gen-2-FIX)
