{
  inputs,
  mkEnabledOption,
  ...
}: {
  lib,
  config,
  ...
}:
with lib; let
  name = "hunk";
  namespace = "programs";

  cfg = config.modules.${namespace}.${name};
in {
  imports = [inputs.hunk.homeManagerModules.default];

  options.modules.${namespace}.${name} = {
    enable = mkEnabledOption name;
  };

  config = mkIf cfg.enable {
    programs.hunk = {
      enable = true;
      enableGitIntegration = true;
      settings = {
        mode = "auto";
        wrap_lines = false;
        line_numbers = true;
        transparent_background = false;

        # Binding a key steals it from its default holder — rehome, don't drop.
        keybindings = {
          "hunk.review.scrollCodeLeft" = ["h" "left" "shift+left"];
          "hunk.review.scrollCodeRight" = ["l" "right" "shift+right"];
          "hunk.view.toggleLineNumbers" = "ctrl+l";
          "hunk.review.pageDown" = ["ctrl+f" "pagedown" "space"];
          "hunk.review.pageUp" = ["ctrl+b" "pageup" "shift+space"];
          "hunk.review.halfPageDown" = ["ctrl+d" "d"];
          "hunk.review.halfPageUp" = ["ctrl+u" "u"];
        };
      };
    };
  };
}
