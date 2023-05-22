;; This is an operating system configuration template
;; for a "desktop" setup without full-blown desktop
;; environments.

(use-modules
 (gnu)
 (gnu system nss)
 (nongnu packages linux)
 (nongnu system linux-initrd))

(use-service-modules desktop)
(use-package-modules bootloaders certs emacs emacs-xyz ratpoison suckless wm
                     xorg)

(operating-system

  ;; use the non-guix stuff
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))

  (host-name "Desktop")
  (timezone "America/Toronto")
  (locale "en_US.utf8")

  ;; Use the UEFI variant of GRUB with the EFI System
  ;; Partition mounted on /boot/efi.
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/boot/efi"))))

  ;; Use the block device names
  (file-systems (append
                 (list (file-system
                         (device "/dev/nvme1n1p3")
                         (mount-point "/")
                         (type "ext4"))
                       (file-system
                         (device "/dev/nvme1n1p1")
                         (mount-point "/boot/efi")
                         (type "vfat")))
                 %base-file-systems))

  (swap-space (target (device "/dev/nvme1n1p2")))

  (users (cons (user-account
                (name "callam")
                (group "users")
                (supplementary-groups '("wheel"      ;; sudo
					"netdev"     ;; network devices
					"input"      ;; input devices
					"tty"        ;; tty access
					"kvm"        ;; VMs
					"netdev"     ;; network devices
                                        "audio"      ;; control audio 
					"video")))   ;; control video
               %base-user-accounts))

  ;; Add a bunch of window managers; we can choose one at
  ;; the log-in screen with F1.
  (packages (append (list
                     ;; sway??
                     alacritty                   ;; terminal emulator
                     git
		     stow
		     vim
		     nano
		     emacs
		     pipewire
		     wireplumber
		     sway
		     waybar
		     wofi
                     nss-certs)                  ;; for HTTPS access
                    %base-packages))

  ;; Use the "desktop" services, which include the X11
  ;; log-in service, networking with NetworkManager, and more.
  ;; (services %desktop-services)

  ;; setup nonguix substitutes
 (services (modify-services %desktop-services
             (guix-service-type config => (guix-configuration
               (inherit config)
               (substitute-urls
                (append (list "https://substitutes.nonguix.org")
                  %default-substitute-urls))
               (authorized-keys
                (append (list (local-file "./signing-key.pub"))
                  %default-authorized-guix-keys))))))


 ;; Allow resolution of '.local' host names with mDNS.
  (name-service-switch %mdns-host-lookup-nss))

;; Channel info
;; add the following to ~/.config/guix/channels.scm
;; (cons* (channel
;;         (name 'nonguix)
;;         (url "https://gitlab.com/nonguix/nonguix")
;;         ;; Enable signature verification:
;;         (introduction
;;          (make-channel-introduction
;;           "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
;;           (openpgp-fingerprint
;;            "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
;;        %default-channels)
;; **** then run guix pull afterwards to update!
