{
  modules = [
    {
      name = "coreboot-24.12";
      url = "https://review.coreboot.org/coreboot.git";
      rev = "2f1e4e5e8515dd350cc9d68b48d32a5b6b02ae6a";
      hash = "sha256-EJrr9Spzbpdio7gwqtajkcOvojkit9VZAwVGbzvA6jA=";
    }
  ];
  pkgs = [
    {
      name = "bash-5.1.16.tar.gz";
      url = "https://ftpmirror.gnu.org/bash/bash-5.1.16.tar.gz";
      hash = "sha256-W6wXIY05EYNFINrRPNH4WrlE4cCa4aulWQa+H4GS9Vg=";
    }
    {
      name = "busybox-1.36.1.tar.bz2";
      url = "https://busybox.net/downloads/busybox-1.36.1.tar.bz2";
      hash = "sha256-uMwkyVdNgJ5yecO+NJeVxdXOtv3xnKcJ+AzeUOR94xQ=";
    }
    {
      name = "cairo-1.14.12.tar.xz";
      url = "https://www.cairographics.org/releases/cairo-1.14.12.tar.xz";
      hash = "sha256-jJDwDFALIpnAoyPdm+6tKgA1N1KyCS6tVYE5vWf3vxY=";
    }
    {
      name = "coreboot-crossgcc-acpica-unix-20241212.tar.gz";
      url = "https://mirror.math.princeton.edu/pub/libreboot/misc/acpica/acpica-unix-20241212.tar.gz";
      hash = "sha256-ncqDz+45C3EEhfvfeHBINwBJwFcjsQzCIM/vbhPDGWE=";
    }
    {
      name = "coreboot-crossgcc-binutils-2.43.1.tar.xz";
      url = "https://ftpmirror.gnu.org/binutils/binutils-2.43.1.tar.xz";
      hash = "sha256-E/dCAqPExREYt5ejnqQgDT9s++Ik2m0dlbuThIATLf0=";
    }
    {
      name = "coreboot-crossgcc-gcc-14.2.0.tar.xz";
      url = "https://ftpmirror.gnu.org/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz";
      hash = "sha256-p7Obxpy/niWCbFpgqyZHcAH3wI2FzsBLwOKcq+1vPMk=";
    }
    {
      name = "coreboot-crossgcc-gmp-6.3.0.tar.xz";
      url = "https://ftpmirror.gnu.org/gmp/gmp-6.3.0.tar.xz";
      hash = "sha256-o8K4AgG4nmhhb0rTC8Zq7kknw85Q4zkpyoGdXENTiJg=";
    }
    {
      name = "coreboot-crossgcc-mpc-1.3.1.tar.gz";
      url = "https://ftpmirror.gnu.org/mpc/mpc-1.3.1.tar.gz";
      hash = "sha256-q2QkkvXPiCt0qgy3MM1BCoHtzb7IlRg86TDnBsHHWbg=";
    }
    {
      name = "coreboot-crossgcc-mpfr-4.2.1.tar.xz";
      url = "https://ftpmirror.gnu.org/mpfr/mpfr-4.2.1.tar.xz";
      hash = "sha256-J3gHNTpnJpeJlpRa8T5Sgp46vXqaW3+yeTiU4Y8fy7I=";
    }
    {
      name = "coreboot-crossgcc-nasm-2.16.03.tar.bz2";
      url = "https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/nasm-2.16.03.tar.bz2";
      hash = "sha256-vvPeFZvNYa35i7fMh+6QRulEZErXa3Yz8YqwY+2ynlc=";
    }
    {
      name = "cryptsetup-2.6.1.tar.xz";
      url = "https://www.kernel.org/pub/linux/utils/cryptsetup/v2.6/cryptsetup-2.6.1.tar.xz";
      hash = "sha256-QQ3tZaEHKrnI5Brd7Te5cpwIf+9NLbArtO9SmtbaRpM=";
    }
    {
      name = "dropbear-2016.74.tar.bz2";
      url = "https://mirror.dropbear.nl/mirror/releases/dropbear-2016.74.tar.bz2";
      hash = "sha256-JyDqVO0AmvgScBvMKQoqYB1cEH0SmT5dksD1+B9xiJE=";
    }
    {
      name = "e2fsprogs-1.47.0.tar.xz";
      url = "https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v1.47.0/e2fsprogs-1.47.0.tar.xz";
      hash = "sha256-FEr1Pyu9khzvb4vqiLufrdyoZdo/vGV8ybTSABCX1ds=";
    }
    {
      name = "exfatprogs-1.2.1.tar.xz";
      url = "https://github.com/exfatprogs/exfatprogs/releases/download/1.2.1/exfatprogs-1.2.1.tar.xz";
      hash = "sha256-pvOx+0vTeDXI+MtCGqxOt1uIClE0KymFDEBjlzFiIns=";
    }
    {
      name = "fbwhiptail-1.3.tar.gz";
      url = "https://source.puri.sm/firmware/fbwhiptail/-/archive/1.3/fbwhiptail-1.3.tar.gz";
      hash = "sha256-Lrj639Pi1XTeUjJ7vIDtYxNzmj259Nh4QMU0NSxm31o=";
    }
    {
      name = "flashprog-eb2c04185f8f471c768b742d66e4c552effdd9cb.tar.gz";
      url = "https://github.com/SourceArcade/flashprog/archive/eb2c04185f8f471c768b742d66e4c552effdd9cb.tar.gz";
      hash = "sha256-DUGGvp8giNYkqacIw1LQ36+iJk4UNrEew8waNQ/UWnc=";
    }
    {
      name = "flashtools-d1e6f12568cb23387144a4b7a6535fe1bc1e79b1.tar.gz";
      url = "https://github.com/osresearch/flashtools/archive/d1e6f12568cb23387144a4b7a6535fe1bc1e79b1.tar.gz";
      hash = "sha256-pozbSi4xL5aGIRmm2CmskAtT0MvIDKpWMu/UO1t+7Ww=";
    }
    {
      name = "gnupg-2.4.0.tar.bz2";
      url = "https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.4.0.tar.bz2";
      hash = "sha256-HXkVjdAdmSQx3S4/rLif2slxJ/iXhOosthDGAPsMFIM=";
    }
    {
      name = "hidapi-e5ae0d30a523c565595bdfba3d5f2e9e1faf0bd0.tar.xz";
      url = "https://github.com/Nitrokey/hidapi/archive/e5ae0d30a523c565595bdfba3d5f2e9e1faf0bd0.tar.gz";
      hash = "sha256-rMKlCJqJFwhcKz6+lEYGWiHHYLp+E8tUkXBDxBIhiOA=";
    }
    {
      name = "json-c-0.14.tar.gz";
      url = "https://s3.amazonaws.com/json-c_releases/releases/json-c-0.14-nodoc.tar.gz";
      hash = "sha256-mZFOZEolIB2CzO+iBDD3UVwRCSM2D570Z1VSfAJBKvo=";
    }
    {
      name = "kexec-tools-2.0.26.tar.gz";
      url = "https://kernel.org/pub/linux/utils/kernel/kexec/kexec-tools-2.0.26.tar.gz";
      hash = "sha256-ib3ZQVQsZP7BYxGFjfME7To5CMGmCHTWnfXZvxYR4GI=";
    }
    {
      name = "libaio_0.3.113.orig.tar.gz";
      url = "https://deb.debian.org/debian/pool/main/liba/libaio/libaio_0.3.113.orig.tar.gz";
      hash = "sha256-LETRxf0NQ3Uih8muHrnAI/BO+EjqjUqvpG6a7bZ4IAs=";
    }
    {
      name = "libassuan-2.5.5.tar.bz2";
      url = "https://gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.5.tar.bz2";
      hash = "sha256-jowvzJgvnKZ9y7HZXi3HRrFzmkZovCCzo8W+Yy7bNOQ=";
    }
    {
      name = "libgcrypt-1.10.1.tar.bz2";
      url = "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.10.1.tar.bz2";
      hash = "sha256-7xSuVGsAhM2EJZ9hpV4Ho4w7U6/A9Ua//O8vAbr/6d4=";
    }
    {
      name = "libgpg-error-1.46.tar.bz2";
      url = "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.46.tar.bz2";
      hash = "sha256-t+EaZCRrvl7zd0jeQ7JFq9cs/NU8muXn/FylnxyBJo0=";
    }
    {
      name = "libksba-1.6.3.tar.bz2";
      url = "https://gnupg.org/ftp/gcrypt/libksba/libksba-1.6.3.tar.bz2";
      hash = "sha256-P3LGjbMJceu/FDZ1J3GUI/Ck1fgQP8n0ocAan6RA3lw=";
    }
    {
      name = "libpng-1.6.34.tar.gz";
      url = "https://github.com/glennrp/libpng-releases/raw/master/libpng-1.6.34.tar.gz";
      hash = "sha256-V0YjpJAamWkICrSi35Q3AmyKhxUN/VwjXijJSyEpZKc=";
    }
    {
      name = "libusb-1.0.21.tar.bz2";
      url = "https://github.com/libusb/libusb/releases/download/v1.0.21/libusb-1.0.21.tar.bz2";
      hash = "sha256-fc6czpqBGUtwZe6RK81V7v/rq2lOpAP/uRtn22axgks=";
    }
    {
      name = "linux-6.1.8.tar.xz";
      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.8.tar.xz";
      hash = "sha256-tgu1Ori6NwonBFSxHpPUGvKRJvxyvW7eUXZz4uV7gW0=";
    }
    {
      name = "LVM2.2.03.23.tgz";
      url = "https://mirrors.kernel.org/sourceware/lvm2/LVM2.2.03.23.tgz";
      hash = "sha256-dOeUqene4bz4ogZfZbkZbET98yHiLWO5jtfejJqhel0=";
    }
    {
      name = "mbedtls-2.4.2.tar.gz";
      url = "https://github.com/ARMmbed/mbedtls/archive/mbedtls-2.4.2.tar.gz";
      hash = "sha256-t6+rag+G4pxgVYSLcNGDxOJTHLDslVtmwOTht+SVS/Q=";
    }
    {
      name = "musl-cross-make-fd6be58297ee21fcba89216ccd0d4aca1e3f1c5c.tar.gz";
      url = "https://github.com/richfelker/musl-cross-make/archive/fd6be58297ee21fcba89216ccd0d4aca1e3f1c5c.tar.gz";
      hash = "sha256-FbjgoofXOKRuBp6Q1nqNliE7NXt5qvPozwzUDksjDZ4=";
    }
    {
      name = "ncurses-6.5.tar.gz";
      url = "https://invisible-island.net/archives/ncurses/ncurses-6.5.tar.gz";
      hash = "sha256-E22RvCaamleF5fnpgLx2q1dCj2BM4+WlqQzrx2eXHMY=";
    }
    {
      name = "nitrokey-hotp-verification-f4583b701a354dfa50c690075a568bc5cdf160e1.tar.gz";
      url = "https://github.com/Nitrokey/nitrokey-hotp-verification/archive/f4583b701a354dfa50c690075a568bc5cdf160e1.tar.gz";
      hash = "sha256-Qu/rqaYeSgDfVb9TN8FXlIvHbIlUEPx20CuH1s07OOs=";
    }
    {
      name = "npth-1.6.tar.bz2";
      url = "https://gnupg.org/ftp/gcrypt/npth/npth-1.6.tar.bz2";
      hash = "sha256-E5Or2a3PB2LTR5jcNP3PTQ0iqEEHIedvHjr80dqk4tE=";
    }
    {
      name = "pciutils-3.5.4.tar.xz";
      url = "https://www.kernel.org/pub/software/utils/pciutils/pciutils-3.5.4.tar.xz";
      hash = "sha256-ZCk8arkxjEDvJit22HvZCXUxdZdSusVW5Ql5seY8/mY=";
    }
    {
      name = "pinentry-1.1.0.tar.bz2";
      url = "https://www.gnupg.org/ftp/gcrypt/pinentry/pinentry-1.1.0.tar.bz2";
      hash = "sha256-aAdmhvpySikOpJzfDRwMFQCQfRt1mjvL++wCk+j1ZXA=";
    }
    {
      name = "pixman-0.34.0.tar.gz";
      url = "https://www.cairographics.org/releases/pixman-0.34.0.tar.gz";
      hash = "sha256-IbaySbUcaADclVO2UQbh430OJd+ULJBTHUw5l6ogqI4=";
    }
    {
      name = "popt-1.19.tar.gz";
      url = "https://fossies.org/linux/misc/popt-1.19.tar.gz";
      hash = "sha256-wlpIOPyOTByKrLi9Yg7bMISj1jv4mH/a08onWMYyQPk=";
    }
    {
      name = "qrencode-3.4.4.tar.gz";
      url = "https://fukuchi.org/works/qrencode/qrencode-3.4.4.tar.gz";
      hash = "sha256-55TiapYBkBPA42ZcsGsYmSZo81LFVT0KVT9dFE9/KnI=";
    }
    {
      name = "tpmtotp-4d63d21c8b7db2e92ddb393057f168aead147f47.tar.gz";
      url = "https://github.com/osresearch/tpmtotp/archive/4d63d21c8b7db2e92ddb393057f168aead147f47.tar.gz";
      hash = "sha256-6qwej2UvHaf1oe1qjP77ZRHx5eHav5O0TbOynBjFrlM=";
    }
    {
      name = "util-linux-2.39.tar.xz";
      url = "https://www.kernel.org/pub/linux/utils/util-linux/v2.39/util-linux-2.39.tar.xz";
      hash = "sha256-MrMKM2zakDGC7WH+s+m5CLdipeZv4U5D77iNNxYgdcs=";
    }
    {
      name = "zlib-1.2.11.tar.gz";
      url = "https://zlib.net/fossils/zlib-1.2.11.tar.gz";
      hash = "sha256-w+Xp/dUATctUL+2l7k8P8HRGKLr47S3V1m+MoRl8saE=";
    }
    {
      name = "zstd-1.5.5.tar.gz";
      url = "https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz";
      hash = "sha256-nEOWzIKc+uMZpuJhUgLoKq1BNyBzSC/OKG+seGRtPuQ=";
    }
  ];
  musl-cross-make-srcs = [
    {
      name = "binutils-2.33.1.tar.xz";
      url = "https://ftpmirror.gnu.org/gnu/binutils/binutils-2.33.1.tar.xz";
      hash = "sha256-q2b8LRw+wDWbjgiEPJ8ztj6HB+/f9eTMXCAOriRyLL8=";
    }
    {
      name = "config.sub";
      url = "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=3d5db9ebe860";
      hash = "sha256-ddXSVaKic7bmUfgu7Pq/bLzY6urnDoa0FzhMj0pY2NM=";
    }
    {
      name = "gcc-9.4.0.tar.xz";
      url = "https://ftpmirror.gnu.org/gnu/gcc/gcc-9.4.0/gcc-9.4.0.tar.xz";
      hash = "sha256-yV2jL0QDeNd1HdlVMxhvf8Bc60+2XrW4UjTmKZ65g44=";
    }
    {
      name = "gmp-6.1.2.tar.bz2";
      url = "https://ftpmirror.gnu.org/gnu/gmp/gmp-6.1.2.tar.bz2";
      hash = "sha256-UnW7BPSGOhNRay85OSrF4nL14buAV7GK7Bybedc9j7I=";
    }
    {
      name = "linux-headers-4.19.88-2.tar.xz";
      url = "https://ftp.barfooze.de/pub/sabotage/tarballs/linux-headers-4.19.88-2.tar.xz";
      hash = "sha256-3Hq/c0SHVTZEJYo4Is/UKddGVnSeMJ8rJfCfQoLgVYg=";
    }
    {
      name = "mpc-1.1.0.tar.gz";
      url = "https://ftpmirror.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz";
      hash = "sha256-aYXFOBQ8EgjcsaxCztrW/1LiZ7R+X5cBg6PnUSW0PC4=";
    }
    {
      name = "mpfr-4.0.2.tar.bz2";
      url = "https://ftpmirror.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.bz2";
      hash = "sha256-wF4/AtCeDpAZOEzdWODxnGTm2x/W9ez3e0scYcolOsw=";
    }
    {
      name = "musl-1.2.5.tar.gz";
      url = "https://musl.libc.org/releases/musl-1.2.5.tar.gz";
      hash = "sha256-qaEYu+hNh2TaDqDSizqz+uhHf8fkCF2QECuFlvx8deQ=";
    }
  ];
}
