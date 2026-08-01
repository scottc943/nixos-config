{ pkgs, ... }:
{
  # The current Rofi setup is a multi-file Rasi theme. Managing the source
  # files directly preserves it exactly while keeping the result declarative.
  home.packages = [ pkgs.rofi ];

  xdg.configFile = {
    "rofi/config.rasi".source = ./config.rasi;
    "rofi/mango-grid.rasi".source = ./mango-grid.rasi;
    "rofi/mango-grid-readable.rasi".source = ./mango-grid-readable.rasi;
    "rofi/theme.rasi".source = ./theme.rasi;
  };
}
