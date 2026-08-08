{ ... }:

{
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

    # This Nix configuration is the source of truth for system Flatpaks.
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
