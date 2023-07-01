{ stdenv, lib, fetchFromGitHub, kernel, kmod }:

stdenv.mkDerivation rec {
  name = "filefreq-${version}-${kernel.version}";
  version = "1.0";

  src = ./src;

  # sourceRoot = "source/linux/v4l2loopback";
  hardeningDisable = [ "pic" "format" ];                                             # 1
  nativeBuildInputs = kernel.moduleBuildDependencies;                       # 2
  KERNEL = kernel.dev;
  KERNEL_VERSION = kernel.modDirVersion;
  buildInputs = [kernel.dev];

    # make -C $(nix-build -E '(import <nixpkgs> {}).linuxPackages_latest.kernel.dev' --no-out-link)/lib/modules/*/build M=$(pwd) modules obj-m=cpufreq.o
  # buildPhase = ''
  #   pwd
  #   ls -lah
  #   make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules obj-m=filefreq.o
  # '';
  # builder = ;
  installPhase = ''
    mkdir -p $out/lib/modules/${KERNEL_VERSION}/misc
    pwd
    ls -lah
    echo "${KERNEL_VERSION}/laaahh"

    ls -lah $out/lib/modules/${KERNEL_VERSION}/misc
    pwd
    # echo $out
    # chmod +755 ./filefreq.ko
    cp ./filefreq.ko $out/lib/modules/${KERNEL_VERSION}/misc
  '';

  # postInstall = ''
  # '';

  # dontFixup = true;

  meta = with lib; {
    description = "A kernel module to add a value a cpu frequency file for auto-cpufreq to be able to downthrottle";
    homepage = "";
    license = licenses.gpl2;
    maintainers = [ maintainers.makefu ];
    platforms = platforms.linux;
  };
}