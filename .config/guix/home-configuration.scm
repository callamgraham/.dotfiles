;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

;; some utilities courtesy of David Wilson, for pulling manifests
(define (read-manifest manifest-path)
  (with-input-from-file manifest-path
    (lambda ()
      (read))))

(define (gather-manifest-packages manifests)
  (if (pair? manifests)
      (begin
        (let ((manifest (read-manifest (string-append
                                        "/home/callam/.dotfiles/.manifests/"
                                        (symbol->string (car manifests))
                                        ".scm"))))

          (append (map specification->package+output
                       (cadadr manifest))
                  (gather-manifest-packages (cdr manifests)))))
      '()))



(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (guix gexp)
	     (guix channels)
	     (gnu home services)
             (gnu home services shells)
	     (gnu home services guix)
	     (gnu home services ssh))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
 (packages
  (append (gather-manifest-packages '(emacs))
  (specifications->packages (list
				      ;; gaming
				      ;; "steam"
				      "dolphin-emu"
				      "xrandr" ; for the primary_monitor script
				      
				      ;; sys admin
                                      "parted"
                                      "stow"
				      "gnupg"
				      "openssh"
				      "pinentry"
				      "dunst"
				      "flatpak"
				      ;; "nix"
				      ;; "ntfs-3g" ; for ntfs drives
				      "zip"
				      "unzip"
				      "xdg-user-dirs"
				      "p7zip"
				      "neofetch" ; shows user info
				      "pantalaimon" ; for ement encrypted
				      
				      ;; browser
				      "firefox-wayland" ; might want to move this to a container?

				      ;; office
				      "libreoffice"
				      "evince"
				      
				      ;; fonts/icons
				      "font-google-noto"
                                      "font-adobe-source-code-pro"
				      "font-awesome"
				      "font-jetbrains-mono"
				      "breeze-icons"
				      "font-microsoft-web-core-fonts"

				      ;; media
				      "qpwgraph"
				      "pavucontrol"
				      "handbrake"
				      "transmission:gui"
				      "mpv"
				      "feh"
				      
				      ;; programming
				      "cmake"
				      "gcc-toolchain"
				      "gcc-objc:lib"
                                      "git"				   
				      "python"

				      ;; other...
                                      "vim"))))

  ;; Below is the list of Home services.  To search for available
  ;; services, run 'guix home search KEYWORD' in a terminal.
(services
  (list (service home-bash-service-type
                 (home-bash-configuration
                  (aliases '(("grep" . "grep --color=auto") ("ll" . "ls -l")
                             ("ls" . "ls -p --color=auto")))
                  ))
	 ;; setup ssh
	 (service home-ssh-agent-service-type)

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
		     "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))))

	 (simple-service 'some-useful-env-vars-service
		home-environment-variables-service-type
		`(("GUIX_SANDBOX_HOME" . "/extra/nvme1/sandbox")
		  ("EDITOR" . "emacsclient")
		  ("XDG_CURRENT_DESKTOP" . "sway")))
	 
	 ;; setup dotfiles - this is effecively gnu stow, will need to flesh this out...
	 (service home-xdg-configuration-files-service-type
		  
		  `(
		    ;; sway
		    ("sway/config" ,(local-file "/home/callam/.dotfiles/.config/sway/config"))

		    ;; helix
		    ("helix/config.toml" ,(local-file "/home/callam/.dotfiles/.config/helix/config.toml"))

		    ;; waybar
		    ("waybar/config" ,(local-file "/home/callam/.dotfiles/.config/waybar/config"))
		    ("waybar/style.css" ,(local-file "/home/callam/.dotfiles/.config/waybar/style.css"))
		    
		    ;; wofi
		    ("wofi/config" ,(local-file "/home/callam/.dotfiles/.config/wofi/config"))
		    ("wofi/style.css" ,(local-file "/home/callam/.dotfiles/.config/wofi/style.css"))

		    ;; xdg
		    ("user-dirs.dirs" ,(local-file "/home/callam/.dotfiles/.config/user-dirs.dirs"))
		    ("user-dirs.locale" ,(local-file "/home/callam/.dotfiles/.config/user-dirs.locale"))
		    ))

	 (service home-files-service-type
		  
		  `(
		    (".tmux.conf" ,(local-file "/home/callam/.dotfiles/.tmux.conf"))
		    (".gitconfig" ,(local-file "/home/callam/.dotfiles/.gitconfig"))))
	 
	 
	 ))
 
 )
