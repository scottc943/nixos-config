{ pkgs, ... }:

{
  # Gear Lever prefers gtk-launch when launching an integrated AppImage.
  #
  # gtk-launch is provided by GTK 3. Installing GTK 3 here does NOT
  # install GNOME or replace Mango; it simply makes the GTK utilities
  # available on the host.
  environment.systemPackages = [
    pkgs.gtk3
  ];

  services.flatpak = {
    enable = true;

    packages = [
      "com.github.flxzt.rnote"
      "com.github.tchx84.Flatseal"
      "com.jgraph.drawio.desktop"
      "info.cemu.Cemu"
      "io.github.gopher64.gopher64"
      "it.mijorus.gearlever"
      "md.obsidian.Obsidian"
      "net.ankiweb.Anki"
      "net.lutris.Lutris"
      "org.kde.okular"
      "org.qbittorrent.qBittorrent"
      "org.vinegarhq.Sober"
    ];

    # Nix is the source of truth for system Flatpaks.
    uninstallUnmanaged = true;

    update = {
      onActivation = false;

      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };
}
