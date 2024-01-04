(specifications->manifest
 '(
   "bash"
   "gnupg"

   ;; utilities
   "coreutils"
   "findutils"
   "tar"
   "gawk"
   "sed"
   "which"
   "curl"
   "grep"
   "ripgrep"

   ;; networking
   "nss-certs"        ;internet access
   "openssh"
   "openssl"
   
   ;; libs
   "gcc-objc:lib"
   "gcc-toolchain"
   "pkg-config"
   "glib"
   "glibc:static"

   ;; build tools
   "git"
   "cmake"
   "make"
   "clang"
   
   ;; fonts/icons
   "font-jetbrains-mono"
   ))
