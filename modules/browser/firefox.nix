{
  inputs,
  pkgs,
  ...
}:
{
  programs.firefox = {
    enable = true;
    profiles.default = {
      name = "Default";
      settings = {
        "accessibility.typeaheadfind.manual" = false;
        "accessibility.typeaheadfind.autostart" = false;
        "browser.tabs.loadInBackground" = true;
        "browser.tabs.loadBookmarksInBackground" = true;
        "toolkit.tabbox.switchByScrolling" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;

        "gnomeTheme.hideSingleTab" = true;
        "gnomeTheme.bookmarksToolbarUnderTabs" = true;
        "gnomeTheme.normalWidthTabs" = false;
        "gnomeTheme.tabsAsHeaderbar" = false;
      };
      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";
      '';
      userContent = ''
        @import "firefox-gnome-theme/userContent.css";
      '';
    };
    nativeMessagingHosts = [
      pkgs.plasma-browser-integration
      pkgs.browserpass
    ];
  };
}
