;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules 
  (gnu) 
  (gnu packages linux)
  (nongnu packages linux)
  (nongnu system linux-initrd)
  )
(use-package-modules terminals certs wm xdisorg vim gl)
(use-service-modules cups desktop networking ssh xorg)

;; Modify configurations of default %desktop-services
(define %my-desktop-services
  (modify-services %desktop-services
                   ;; Configure the substitute server for the Nonguix repo
                   (guix-service-type
                    config =>
                    (guix-configuration
                     (inherit config)
                     (substitute-urls
		      (append (list "https://substitutes.nonguix.org")
			      %default-substitute-urls))
                     (authorized-keys
		      (append (list (plain-file "nonguix.pub" "(public-key
                                                                (ecc
                                                                 (curve Ed25519)
                                                                  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)
                                                                 )
                                                                )"))
			      %default-authorized-guix-keys))))))


(operating-system
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (locale "en_CA.utf8")
  (timezone "America/Toronto")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "Desktop")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "callam")
                  (comment "Callam Graham")
                  (group "users")
		  (uid 1000)
                  (home-directory "/home/callam")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list 
		      nss-certs
		      vim
		      sway
		      wofi
		      waybar
		      mesa
		      pipewire
		      wireplumber
		      alacritty)
                    %base-packages))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  ;; TODO remove original below
  ;(services
  ; (append (list (service network-manager-service-type)
  ;               (service wpa-supplicant-service-type)
  ;               (service ntp-service-type))
;
;           ;; This is the default list of services we
;           ;; are appending to.
;           %base-services))

  (services %my-desktop-services)
  
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "33c8856e-9d42-47b1-b75f-29277c7aab2e")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "7d0373cc-c552-41c0-acae-90f2ad8cc655"
                                  'ext4))
                         (type "ext4"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "B457-AEE1"
                                       'fat32))
                         (type "vfat")) 

		       ;; TODO need to add mount option to give user rw permissions, something tike (option "umask=0022,uid=1000")
                       (file-system
                         (mount-point "/extra/ssd1")
                         (device "/dev/sda1")
                         (type "ext4")
			 (create-mount-point? #t)
			 )

                       (file-system
                         (mount-point "/extra/nvme1")
                         (device "/dev/nvme0n1p1")
                         (type "ext4")
			 (create-mount-point? #t)
			 )
		       
		       %base-file-systems)))
