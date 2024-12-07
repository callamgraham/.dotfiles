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
  (gnu home services)
  (guix channels)
  (gnu packages linux)
  (nongnu packages linux)
  (nongnu system linux-initrd)
  )

;; Modify configurations of default %desktop-services
;; (define %my-desktop-services
;;   (modify-services %desktop-services
;;                    ;; Configure the substitute server for the Nonguix repo
;;                    (guix-service-type
;;                     config =>
;;                     (guix-configuration
;;                      (inherit config)
;;                      (substitute-urls
;; 		      (append (list "https://substitutes.nonguix.org")
;; 			      %default-substitute-urls))
;;                      (authorized-keys
;; 		      (append (list (plain-file "nonguix.pub" "(public-key
;;                                                                 (ecc
;;                                                                  (curve Ed25519)
;;                                                                   (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)
;;                                                                  )
;;                                                                 )"))
;; 			      %default-authorized-guix-keys))))

;; 		   (delete gdm-service-type)
;; 		   ))

(operating-system
 (kernel linux)
 (sudoers-file etc-sudoers-config)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))
 (locale "en_CA.utf8")
 (timezone "America/Toronto")
 (keyboard-layout (keyboard-layout "us"))
 (host-name "basement")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "callam")
                  (comment "Callam Graham")
                  (group "users")
                  (home-directory "/home/callam")
                  (supplementary-groups '("wheel" "netdev" "audio" "video" "docker")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list 
		     vim
		     )
                    %base-packages))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.

  (services (append (list
		     ;; configure env variables
		     ;; (service sddm-service-type
		     ;; 	      (sddm-configuration
		     ;; 	       ;; (display-server "wayland")
		     ;; 	       (themes-directory "/run/current-system/profile/share/sddm/themes")
		     ;; 	       (theme "abstractdark")
		     ;; 	       ;; (theme "sugar-dark")
		     ;; 	       ))

		     ;; containers
		     (service containerd-service-type)
		     (service docker-service-type)

		     ;; firewall
		     (service nftables-service-type)

		     ;; enable ssh
		     (service openssh-service-type
                                   (openssh-configuration
                                    (openssh openssh-sans-x)
                                    (port-number 4444)))
		     
		     ;; Channels
		     (simple-service 'variant-packages-service
				     home-channels-service-type
				     (list
				      (channel
				       (name 'nonguix)
				       (url "https://gitlab.com/nonguix/nonguix")
				       (introduction
					(make-channel-introduction
					 "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
					 (openpgp-fingerprint
					  "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
				      )))
		    %base-services))
  
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
		       (target "/dev/nvme0n1p2") ; need to update this!
		       )))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device "/dev/nvme0n1p3")
                         (type "ext4"))
		       
                       (file-system
                         (mount-point "/boot/efi")
                         (device "/dev/nvme0n1p1")
                         (type "vfat"))
		       
		       %base-file-systems)))
