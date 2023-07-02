{ stdenv, lib, kernel }:

stdenv.mkDerivation rec {
  name = "filefreq-${version}-${kernel.version}";
  version = "1.0";

  src = ./src;

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  KERNEL = kernel.dev;
  KERNEL_VERSION = kernel.modDirVersion;
  buildInputs = [kernel.dev];

  installPhase = ''
    mkdir -p $out/lib/modules/${KERNEL_VERSION}/misc
    cp ./filefreq.ko $out/lib/modules/${KERNEL_VERSION}/misc
  '';

  meta = with lib; {
    description = "A kernel module to add a value a cpu frequency file for auto-cpufreq to be able to downthrottle - limited by architecture";
    homepage = "";
    license = licenses.gpl2;
    maintainers = [ maintainers.makefu ];
    platforms = platforms.linux;
  };
}