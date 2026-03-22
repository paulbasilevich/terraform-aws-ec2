#!/usr/bin/env bash

# This script opens the web page identified by the title of its tab

BROWSER="${1:-Google Chrome}"
TAB_TITLE="${2:-Plaid Quickstart}"

# Check whether terraform runs "apply" or "destroy"
# Do the work only in "apply" mode

TF_MODE="$( ps aux \
    | egrep -o "[[:space:]]terraform[[:space:]]+[[:graph:]]+" \
    | awk '{print $2}' \
    )"

case "$TF_MODE" in
    "apply") eval "$( echo "
osascript <<'EOA'
tell application \"$BROWSER\"
  repeat with wi from 1 to count of windows
    set w to window wi
    repeat with ti from 1 to count of tabs of w
      set t to tab ti of w
      if title of t contains \"$TAB_TITLE\" then
        set active tab index of w to ti
        set index of w to 1
        activate

        -- give the page a moment to focus
        delay 0.2

        -- click the button
        execute t javascript \"
            (function () {
              const buttons = ['Launch Link', 'Continue as guest'];
              const timeoutMs = 5000;
              const pollMs = 100;

              function waitForButton(name, timeout = timeoutMs) {
                return new Promise((resolve, reject) => {
                  const start = Date.now();
                  const timer = setInterval(() => {
                    const btn = [...document.querySelectorAll('button')]
                      .find(b => b.innerText.trim() === name);

                    if (btn) {
                      clearInterval(timer);
                      resolve(btn);
                    } else if (Date.now() - start > timeout) {
                      clearInterval(timer);
                      reject(new Error(name + ' not found (timeout)'));
                    }
                  }, pollMs);
                });
              }

              async function clickInOrder() {
                const results = [];

                for (const name of buttons) {
                  try {
                    const btn = await waitForButton(name);
                    btn.click();
                    results.push(name + ': clicked');
                  } catch (e) {
                    results.push(name + ': not found');
                  }
                }

                return results.join(' | ');
              }

              return clickInOrder();
            })();
        \"
        return
      end if
    end repeat
  end repeat
end tell
EOA
"
)"

# Reinstate the original version of this file:
reset_timestamp_from="$( dirname "$0" )/format_button_list.sh"
default_list="null"
exec bash -c "\
sed -E -i '' \
-e \"s~([[:space:]]*const[[:space:]]+buttons[[:space:]]*=[[:space:]]*)([^;]+)(;)~\1$default_list\3~\" \"$0\" \
&& touch -c -r \"$reset_timestamp_from\" \"$0\" \
"
             ;;
          *) ;;
esac

