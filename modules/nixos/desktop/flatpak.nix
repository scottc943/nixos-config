{ ... }:
{
  # These are managed system-wide. Applications installed manually outside
  # this declaration are removed during activation.
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
