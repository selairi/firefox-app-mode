#!/usr/bin/bash

function help() {
cat << EOF
Firefox app mode.

Opens url or file in Firefox as app mode. A new window will be opened with no navigation bar and it will show save as dialog when file would be downloaded.

$0 [--profile_path path] [--file path] [url]

--profile_path path : path to profile folder.
--file path : path to html file to open.

EOF
}

PROFILEPATH="firefox-appmode"
URL=""

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile_path)
      PROFILEPATH="$2"
      shift # past argument
      shift # past value
      ;;
    --file)
      URL=file://`realpath "$2"`
      shift # past argument
      shift # past value
      ;;
    --url)
      URL="$2"
      shift # past argument
      shift # past value
      ;;
   -*|--*)
      echo "Unknown option $1"
      help
      exit 1
      ;;
    *)
      URL="$1"
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

if [[ $URL == "" ]] ; then
  echo "Error: No url"
  help
  exit 1
fi

echo "$URL"

mkdir -p "$PROFILEPATH/chrome"

if [[ ! -e "${PROFILEPATH}/chrome/userChrome.css" ]] ; then
echo Building "${PROFILEPATH}/chrome/userChrome.css"
cat << EOF > "${PROFILEPATH}/chrome/userChrome.css"
@namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul"); /* only needed once */
#titlebar { visibility: collapse; }
#TabsToolbar { visibility: collapse !important; }
#nav-bar { visibility: collapse !important; }
#PanelUI-menu-button {display: none;}
#navigator-toolbox {visibility: collapse;}
EOF
fi

if [[ ! -e "${PROFILEPATH}/user.js" ]] ; then
echo Building "${PROFILEPATH}/user.js"
cat << EOF > "${PROFILEPATH}/user.js"
 // Enable userChrome.css
 user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
 // Enable save as dialog
 user_pref("browser.download.useDownloadDir", false);
EOF
fi

# Show system window decoration
export MOZ_GTK_TITLEBAR_DECORATION=system
exec firefox --profile "$PROFILEPATH" -no-remote "$URL"
