#!/bin/bash

set -eo pipefail

VER=$(sed -nEe 's/^## \[?([^]]*)\]? - .*/\1/;T;p;q' CHANGELOG.md || true)
echo "Version from changelog is ${VER:-<unknown>}"
if [[ "$VER" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then

    ## Determine branch
    if [[ "$GITHUB_REF" =~ ^refs/heads/ ]]; then
        BRANCH=${GITHUB_REF#refs/heads/}

        if [[ "$BRANCH" = "main" ]]; then
            VER="v$VER"
        else
            VER="v$VER-$SUFFIX"
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
    git tag "v$VER"
    git push origin "v$VER"
    if [[ -e composer.json ]] && jq -e '.extra.autotagger.major?' composer.json >/dev/null; then
      git tag --force "v${VER%%.*}"
      git push --force origin "v${VER%%.*}"
    fi
fi
