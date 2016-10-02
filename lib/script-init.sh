
set -e

if ! which aws > /dev/null; then
    echo "Install awscli first: brew install awscli"
    exit 1
fi

if ! which jq > /dev/null; then
    echo "Install jq first: brew install jq"
    exit 1
fi

cd $(dirname $0)

if [ "$PROFILE" = "" ]; then
    echo "PROFILE env variable must be set"
    exit 1
fi

export PDIR="./state/$PROFILE"

if [ ! -f "$PROFILE.profile" ]; then
    echo "Configuration file $PROFILE.profile not found"
    exit 1
fi

source "$PROFILE.profile"

if [ ! -d "$PDIR" ]; then
    mkdir -p "$PDIR"
fi

