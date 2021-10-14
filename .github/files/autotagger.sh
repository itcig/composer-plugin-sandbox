#!/bin/bash

set -eo pipefail

VER=$(jq -r '.version' "package.json")
echo "Version from package.json is ${VER:-<unknown>}"
if [[ "$VER" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then

    ## Determine branch
    if [[ "$GITHUB_REF" =~ ^refs/heads/ ]]; then
        BRANCH=${GITHUB_REF#refs/heads/}

        if [[ "$BRANCH" = "main" ]]; then
            VER="v$VER"
        else
            VER="v$VER-$BRANCH"
        fi

        echo "Creating tag for $VER"
    else
        echo "Could not determine branch name for tagging from $GITHUB_REF"
        exit 1
    fi

    export GIT_AUTHOR_NAME=cig-bot
    export GIT_AUTHOR_EMAIL=cig-bot@users.noreply.github.com
    export GIT_COMMITTER_NAME=cig-bot
    export GIT_COMMITTER_EMAIL=cig-bot@users.noreply.github.com
    git tag "$VER"
    git push origin "$VER"
    if [[ -e package.json ]] && jq -e '.extra.autotagger.major?' package.json >/dev/null; then
      git tag --force "${VER%%.*}"
      git push --force origin "${VER%%.*}"
    fi
fi
