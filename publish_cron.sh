#!/bin/sh -e
# Publishes inband track spec to CVS

cd "$(dirname $0)"

echo "# Check GitHub for updates"
LOCAL=$(git rev-parse @{0})
REMOTE=$(git rev-parse @{u})
if [ $LOCAL = $REMOTE ]; then
    echo "Up-to-date"
    exit 0
else
  git pull
fi

# Check CVS
GITUSER="$(git config --get user.email)"
if [ $GITUSER = silviapfeiffer1@gmail.com ]; then
    CVSUSER=spfeiffe
else
    echo "Unable to map $GITUSER to a CVS user"
    exit 1
fi
export CVSROOT=$CVSUSER@dev.w3.org:/sources/public
export CVS_RSH=ssh

if [ ! -e html5 ]; then
    echo "# Checkout CVS"
    cvs checkout html5/html-sourcing-inband-tracks
else
    echo "# Update CVS"
    cd html5/html-sourcing-inband-tracks
    cvs update -C
    cd -
fi
echo

echo "# Generate static HTML"
phantomjs --ssl-protocol=any respec/tools/respec2html.js index.html html5/html-sourcing-inband-tracks/Overview.html

echo "# Commit to CVS"
if [ "$1" != "-f" ]; then
    read -p "Really commit? (y) " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        echo "Not really."
        exit 1
    fi
fi
COMMIT="$(git rev-parse HEAD)"
cd html5/html-sourcing-inband-tracks
cvs commit -m "Sync HTML sourcing inband tracks spec with Git commit $COMMIT"
