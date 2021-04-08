# Thinkpad E14 Fn Keys Fix  
I wrote this script to be a more universal way of fixing Fn keys on Thinkpad E14 gen. 2.  
Please note that there is an another [script](https://github.com/masksshow/Thinkpad-E14-15-AMD-Gen-2-FIX), but it works only with GRUB and touches system (which I don't like)

# Run  
```./script.sh```  

# Installing acpi_override.img  
## Refind  
- If you use ```/boot/refind_linux.conf```:  
    - Add ```initrd=\boot\acpi_override.img``` (notice backslashes) as the **first** ```initrd``` option  
    - Example: <pre>"Boot with ACPI override" "<... splash <b>initrd=\boot\acpi_override.img</b> initrd=\boot\initrd.img-%v-generic"</pre>
- If you use ```refind.conf``` (```/boot/EFI/BOOT/refind.conf```)   
    - Add ```initrd=\boot\acpi_override.img``` (notice backslashes) at the end of the options:  
<pre>
menuentry "Arch Linux" {
    icon     /EFI/refind/icons/os_arch.png
    volume   "Arch Linux"
    loader   /boot/vmlinuz-linux
    initrd   /boot/initramfs-linux.img
    options  "root=PARTUUID=5028fa50-0079-4c40-b240-abfaf28693ea rw add_efi_memmap <b>initrd=\boot\acpi_override.img</b>"
    submenuentry "Boot using fallback initramfs" {
        initrd /boot/initramfs-linux-fallback.img
    }
    submenuentry "Boot to terminal" {
        add_options "systemd.unit=multi-user.target"
    }
    disabled
}
</pre>


# Resources
- ASL tutorial: [link](https://acpica.org/sites/acpica/files/asl_tutorial_v20190625.pdf)
- Refind automatic boot stanza with ACPI override: [link](https://askubuntu.com/a/1279476)
- Thinkpad Carbon X1 Gen6, S3 state fix: [link](https://delta-xi.net/blog/#056)
- Another working script (but it is GRUB only): [link](https://github.com/masksshow/Thinkpad-E14-15-AMD-Gen-2-FIX)
