# Thinkpad E14 Fn Keys Fix  

# Run  
```./script.sh```  

# Installing acpi_override.img  
## Refind  
- If you use ```/boot/refind_linux.conf```:  
    - Add ```initrd=\boot\acpi_override.img``` as the **first** ```initrd``` option  
    - Example ```"Boot with ACPI override" "... ro quiet splash initrd=\boot\acpi_override.img initrd=\boot\initrd.img-%v-generic"```
- If you use ```refind.conf``` (```/boot/EFI/BOOT/refind.conf```)  
    - Edit menuentry like so:  
    ```conf
    menuentry "Arch Linux Zen with Fixed ACPI + Deep Sleep" {
        icon     /EFI/BOOT/refind-theme-regular/icons/128-48/os_arch.png
        volume   "EFI System"
        loader   /vmlinuz-linux-zen
        initrd   /initramfs-linux-zen.img
        options  "rd.luks.name=66a65737-4d5b-476f-8c5e-426497f35902=cryptsystem rd.luks.options=discard root=UUID=8e5f6248-0f6d-47c9-b106-dbb163a7184d rootflags=subvol=root nowatchdog mem_sleep_default=deep acpi_osi=Linux initrd=\acpi_override.img"
        submenuentry "Boot using fallback initramfs" {
            initrd /initramfs-linux-zen-fallback.img
        }
        submenuentry "Boot to terminal" {
            add_options "systemd.unit=multi-user.target"
        }
        enabled
    }
    ```

# Resources
- Refind automatic boot stanza with ACPI override: [link](https://askubuntu.com/a/1279476)
