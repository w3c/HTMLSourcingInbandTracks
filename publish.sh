#!/bin/sh -e
# Publishes inband track spec to CVS

cd "$(dirname $0)"

GITUSER="$(git config --get user.email)"
if [ $GITUSER = silviapfeiffer1@gmail.com ]; then
    CVSUSER=spfeiffe
else
    echo "Unable to map $GITUSER to a CVS user"
    exit 1
fi

export CVSROOT=$CVSUSER@dev.w3.org:/sources/public
export CVS_RSH=ssh

if [ ! -e ../../CVS/html5/html-sourcing-inband-tracks ]; then
    echo "# Checkout CVS"
    cd ../../CVS/html5/
    cvs checkout html-sourcing-inband-tracks
else
    echo "# Update CVS"
    cd ../../CVS/html5/html-sourcing-inband-tracks
    cvs update
    cd -
fi
echo

#echo "# Generate static HTML"
#phantomjs ../../respec/tools/respec2html.js index.html ../../CVS/html5/html-sourcing-inband-tracks/Overview.html

echo "# Copying Overview.html to CVS"
cp Overview.html ../../CVS/html5/html-sourcing-inband-tracks/

echo "# Commit to CVS"
if [ "$1" != "-f" ]; then
    read -p "Really commit? (y) " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
	echo "Not really."
	exit 1
    fi
fi
COMMIT="$(git rev-parse HEAD)"
cd ../../CVS/html5/html-sourcing-inband-tracks
cvs commit -m "Sync HTML sourcing inband tracks spec with Git commit $COMMIT"
