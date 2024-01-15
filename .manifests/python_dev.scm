(specifications->manifest
 '(
   "sqlite"

   ;; for gui apps
   "libx11"
   "libxcursor"
   "libxrandr"
   "libxi"
   "libxcb"
   "mesa"  ; needed for egui
   "xf86-video-amdgpu"
   "amdgpu-firmware"
   "mesa-opencl"

   ;; Core Python stuff
   "python"
   "python-pip"
   "python-lsp-server"

   ;; additional python packages
   "python-numpy"
   "python-pytorch"

   ;; for ML
   "rocr-runtime"
   "rocm-opencl-runtime"
   ))
