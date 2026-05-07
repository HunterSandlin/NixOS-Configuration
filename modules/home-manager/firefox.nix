# Declarative Firefox configuration via home-manager.
# Structure:
#   policies  → system-level locks (extensions, hard privacy settings)
#   profiles  → per-profile settings (about:config prefs, search engines)

{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    # --- POLICIES ---
    # These are written to Firefox's policies.json and cannot be
    # overridden by the browser at runtime.
    policies = {

      # Disable all telemetry and data collection
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxScreenshots = true;
      DisableFeedbackCommands = true;
      DisableFirefoxAccounts = false; # keep accounts enabled

      # Autofill — disable Firefox's built-in, defer to Bitwarden
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      PasswordManagerEnabled = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;

      # Behavior
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;

      # Extensions
      # switch installation_mode "force_installed" to "normal_installed" 
      # to make them not removable by the user
      ExtensionSettings = {

        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "normal_installed";
        };

        # Privacy Badger
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "normal_installed";
        };

        # Ghostery
        "firefox@ghostery.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ghostery/latest.xpi";
          installation_mode = "normal_installed";
        };

        # Bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "normal_installed";
        };
        
      };
    };

    # --- PROFILE ---
    profiles.default = {
      id = 0;
      isDefault = true;
      name = "default";

      # about:config preferences
      # These are written to user.js and applied every time Firefox starts.
      settings = {
        # --- Privacy & Tracking ---
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        # Covered by extentions to no break pages:
        "privacy.resistFingerprinting" = false; 
        "privacy.firstparty.isolate" = false;

        # Disable telemetry at the pref level too (belt and suspenders with policies)
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;

        # Disable sponsored content / suggestions
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

        # Disable Firefox's built-in password manager UI prompts
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.generation.enabled" = false;

        # Disable autofill
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        
      };

      # --- Search engines ---
      # `force = true` means this config always wins, even if the user
      # changes it in the UI — it resets on rebuild. Remove force if you
      # want the user to be able to change it between rebuilds.
      search = {
        #force = true; # Uncomment to prevent it from being changed
        default = "Startpage";
        privateDefault = "Startpage";

        engines = {
          # Define Startpage manually
          "Startpage" = {
            urls = [{
              template = "https://www.startpage.com/search";
              params = [
                { name = "q"; value = "{searchTerms}"; }
                { name = "language"; value = "auto"; }
              ];
            }];
            iconUpdateURL = "https://www.startpage.com/sp/cdn/favicons/mobile/android-icon-192x192.png";
            updateInterval = 24 * 60 * 60 * 1000;
            definedAliases = [ "@s" ];
          };

          # Disable the built-in engines you don't want cluttering the list
          "google".metaData.hidden = true;
          "bing".metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          "ebay".metaData.hidden = true;
        };
      };
    };
  };
}
