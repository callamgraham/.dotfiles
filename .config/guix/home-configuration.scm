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
	     (gnu packages gnupg)
             (gnu services)
             (guix gexp)
	     (guix channels)
	     (gnu home services)
             (gnu home services shells)
	     (gnu home services guix)
	     (gnu home services gnupg)
	     (gnu home services ssh))

(home-environment
  ;; Below is the list of packages that will show up in your
  ;; Home profile, under ~/.guix-home/profile.
 (packages
  (append (gather-manifest-packages '(emacs))
  (specifications->packages (list
				      ;; gaming
				      "steam"
				      "protonup-ng"
				      "dolphin-emu"
				      "xrandr" ; for the primary_monitor script
				      "citra" ; from my personal channel
				      "desmume" ; gba games
				      "mgba"
				      
				      ;; sys admin
                                      "parted"
                                      "stow"
				      "gnupg"
				      "openssh"
				      ;; "pinentry" ;; not needed with the gpg service below
				      "dunst"
				      "flatpak"
				      "zip"
				      "unzip"
				      "xdg-user-dirs"
				      "p7zip"
				      "neofetch" ; shows user info
				      "pantalaimon" ; for ement encrypted
				      "ripgrep"
				      "rsync"
				      "htop"
				      "ntfs-3g"
				      "udiskie"
				      
				      ;; browser
				      "firefox" ; might want to move this to a container?

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
				      "libheif"
				      
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
		  ;; (environment-variables '("PATH" . "$PATH:/home/callam/.bin"))
                  (aliases '(("grep" . "grep --color=auto")
			     ("ll" . "ls -l")
                             ("ls" . "ls -p --color=auto")
			     ("update-home" . "guix home reconfigure ~/.dotfiles/.config/guix/home-configuration.scm")
			     ("update-system" . "sudo -E guix system reconfigure /home/callam/.dotfiles/.config/guix/system.scm")
			     ("cleanup" . "sudo guix gc -d 2m -F 50G")
			     ("rust" . "cd ~
guix shell --network --container --emulate-fhs \
     -m /home/callam/.dotfiles/.manifests/rust_dev.scm \
     -m /home/callam/.dotfiles/.manifests/prog.scm \
     -m /home/callam/.dotfiles/.manifests/emacs.scm \
     --preserve='^DISPLAY$' \
     --share=$HOME/Projects/Rust=$HOME \
     --expose=$HOME/.emacs.d/init.el=$HOME/.emacs.d/init.el \
     --expose=$HOME/.ssh=$HOME/.ssh \
     --expose=$HOME/.gnupg=$HOME/.gnupg \
     --expose=$HOME/.gitconfig=$HOME/.gitconfig \
     --expose=$HOME/.dotfiles/.bin/rust-shell-init=$HOME/.bin/rust-shell-init \
     --expose=$HOME/.dotfiles/.config/guix/rust-profile=$HOME/.profile \
     -- ~/.bin/rust-shell-init 
")
			     ("pydev" . "cd ~
guix shell --network --container --emulate-fhs \
     -m /home/callam/.dotfiles/.manifests/python_dev.scm \
     -m /home/callam/.dotfiles/.manifests/prog.scm \
     -m /home/callam/.dotfiles/.manifests/emacs.scm \
     --preserve='^DISPLAY$' \
     --share=$HOME/Projects/Python=$HOME \
     --expose=$HOME/.emacs.d/init.el=$HOME/.emacs.d/init.el \
     --expose=$HOME/.ssh=$HOME/.ssh \
     --expose=$HOME/.gnupg=$HOME/.gnupg \
     --expose=$HOME/.gitconfig=$HOME/.gitconfig \
     --expose=$HOME/.dotfiles/.bin/python-shell-init=$HOME/.bin/python-shell-init \
     --expose=$HOME/.dotfiles/.config/guix/python-profile=$HOME/.profile \
     -- ~/.bin/python-shell-init 
")
			     ))
                  ))
	;; setup ssh
	;; (service home-ssh-agent-service-type)

	;; gnupg
	(service home-gpg-agent-service-type
		 (home-gpg-agent-configuration
		  (pinentry-program
		   (file-append pinentry-emacs "/bin/pinentry-emacs"))
		  (ssh-support? #t)
		  (default-cache-ttl 28800)
		  (max-cache-ttl 28800)
		  (default-cache-ttl-ssh 28800)
		  (max-cache-ttl-ssh 28800)
		  (extra-content
		   "allow-emacs-pinentry
allow-loopback-pinentry")
		  ))

	;; Setup additional channels
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
		 (channel
		  (name 'cig-guix)
		  (url "https://github.com/callamgraham/cig-guix")
		  (branch "main")
		  (introduction
		   (make-channel-introduction
		    "ac662eaca8b75b91adbf685904d308a7f34c32c2"
		    (openpgp-fingerprint
		     "6DF3 6F47 6B7F 26E1 6861  5C2A 173B 393D E95E D1AE"))))

		 ))

	 ;; setup env variables
	 (simple-service 'some-useful-env-vars-service
		home-environment-variables-service-type
		`(("GUIX_SANDBOX_HOME" . "/extra/nvme1/sandbox") ;; used for nonguix containers
		  ("XDG_DATA_DIRS" . "$XDG_DATA_DIRS:/home/callam/.local/share/flatpak/exports/share") ;; so wofi can launch flatpaks
		  ("EDITOR" . "emacsclient")
		  ("PATH" . "$PATH:/home/callam/.bin")
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
		    (".tmux.conf" ,(local-file "/home/callam/.dotfiles/tmux.conf"))
		    (".gitconfig" ,(local-file "/home/callam/.dotfiles/gitconfig"))

		    ;; emacs
		    (".emacs.d/init.el" ,(local-file "/home/callam/.dotfiles/.emacs.d/init.el"))

		    ;; gpg superceded by the gpg service above?
		    ;; (".gnupg/gpg-agent.conf" ,(local-file "/home/callam/.dotfiles/.gnupg/gpg-agent.conf"))
		    ))
	 
	 
	 ))
 
 )
