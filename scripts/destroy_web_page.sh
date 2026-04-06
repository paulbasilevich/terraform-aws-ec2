#!/usr/bin/env bash

# This script closes the web page identified by the title of its tab
# Takes 2 optional arguments defaulted as shown below

BROWSER="${1:-Google Chrome}"
TAB_TITLE="${2:-Plaid Quickstart}"

# Check whether terraform runs "apply" or "destroy"
# Do the work only in "destroy" mode

TF_MODE="$( ps aux \
    | egrep -o "[[:space:]]terraform[[:space:]]+[[:graph:]]+" \
    | awk '{print $2}' \
    )"

case "$TF_MODE" in
    "destroy") eval "$( echo "
osascript <<'EOD'
tell application \"$BROWSER\"
  repeat with wi from 1 to count of windows
    set w to window wi
    repeat with ti from 1 to count of tabs of w
      set t to tab ti of w
      if title of t contains \"$TAB_TITLE\" then
        -- activate the tab
        set active tab index of w to ti
        set index of w to 1
        activate

        delay 0.2

        -- close all child windows opened by this tab
        execute t javascript \"
          (function () {
            if (!window.__children) {
              window.__children = [];
              const origOpen = window.open;
              window.open = function () {
                const win = origOpen.apply(this, arguments);
                if (win) window.__children.push(win);
                return win;
              };
            }
            window.__children.forEach(w => {
              try { w.close(); } catch (e) {}
            });
            window.__children = [];
          })();
        \"

        delay 0.1

        -- close the tab itself
        close t
        return
      end if
    end repeat
  end repeat
end tell
EOD
"
)"
            ;;

         *) ;;
esac

