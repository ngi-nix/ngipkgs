{
  lib,
  pkgs,
  ...
}:
{
  # Enable X11
  services.xserver.enable = true;

  programs.pagedjs.enable = true;

  environment.systemPackages = with pkgs; [
    evince # PDF viewer
  ];

  environment.etc."pagedjs.html".text = ''
    <!DOCTYPE html>
    <html>
      <head>
        <title>PagedJS Example</title>
      </head>
      <body>
        <h1>Hello, PagedJS!</h1>
        <p>This is a simple example of using PagedJS.</p>
      </body>
    </html>
  '';
}
