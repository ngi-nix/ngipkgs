{pkgs, ...}: {
  # https://libre-soc.org/nlnet_2022_ongoing/
  packages = {inherit (pkgs) libresoc-nmigen libresoc-verilog;};
}
