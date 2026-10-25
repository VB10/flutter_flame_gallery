#!/usr/bin/env bash
# Release helper for the pub workspace. Every package has its own version and
# its own tag (<package>-v<version>); pub.dev publishes from that tag via OIDC.
#
#   tool/release.sh plan [package]     packages whose pubspec version is not on
#                                      pub.dev yet, in publish order
#   tool/release.sh release [package]  tag each of them and run publish.yml on
#                                      the tag, waiting for one before the next
#                                      (CI: needs GH_TOKEN with actions:write)
#   tool/release.sh check-tag <tag>    print the tag's package; fail when the
#                                      tag version differs from its pubspec
set -euo pipefail
# Let a pub.dev failure inside $(plan) stop the release (bash 4.4+; macOS
# bash 3.2 only runs `plan`, which does not need it).
shopt -s inherit_errexit 2>/dev/null || true
cd "$(dirname "$0")/.."

# Dependencies first: core, then the games, then the facade.
readonly ORDER=(
  flame_gallery_core
  flame_gallery_slice
  flame_gallery_runner
  flame_gallery_match
  flame_gallery_rhythm
  flame_gallery
)
readonly RUN_START_ATTEMPTS=30
readonly RUN_START_POLL_SECONDS=5

# GitHub annotation in CI, plain text locally.
warn() {
  if [[ -n ${GITHUB_ACTIONS:-} ]]; then echo "::warning::$1" >&2; else echo "warning: $1" >&2; fi
}

version_of() {
  sed -n 's/^version:[[:space:]]*//p' "packages/$1/pubspec.yaml"
}

# Prints `published`, `unpublished`, or `new` when pub.dev has no such package.
pub_status() {
  local package=$1 version=$2 body code
  body=$(mktemp)
  code=$(curl -sS -o "$body" -w '%{http_code}' "https://pub.dev/api/packages/$package")
  case $code in
    404) echo new ;;
    200)
      if jq -e --arg v "$version" '.versions[] | select(.version == $v)' "$body" >/dev/null; then
        echo published
      else
        echo unpublished
      fi
      ;;
    *)
      echo "pub.dev answered HTTP $code for $package" >&2
      return 1
      ;;
  esac
}

require_package() {
  local package
  for package in "${ORDER[@]}"; do
    if [[ $package == "$1" ]]; then return 0; fi
  done
  echo "Unknown package '$1'. Expected one of: ${ORDER[*]}" >&2
  exit 1
}

plan() {
  local only=${1:-} package version status
  if [[ -n $only ]]; then require_package "$only"; fi
  for package in "${ORDER[@]}"; do
    if [[ -n $only && $package != "$only" ]]; then continue; fi
    version=$(version_of "$package")
    status=$(pub_status "$package" "$version")
    case $status in
      unpublished) echo "$package $version" ;;
      new)
        warn "$package is not on pub.dev yet. Publish its first version by hand (flutter pub publish), then enable automated publishing."
        ;;
    esac
  done
}

publish_one() {
  local package=$1 version=$2
  local tag="$package-v$version" started run_id=""
  if git ls-remote --exit-code --tags origin "refs/tags/$tag" >/dev/null; then
    echo "Tag $tag already exists; publishing it again."
  else
    git tag "$tag"
    git push origin "refs/tags/$tag"
  fi

  started=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  gh workflow run publish.yml --ref "$tag"
  for ((attempt = 0; attempt < RUN_START_ATTEMPTS; attempt++)); do
    run_id=$(gh run list --workflow publish.yml --branch "$tag" \
      --event workflow_dispatch --limit 1 --json databaseId,createdAt \
      --jq ".[] | select(.createdAt >= \"$started\") | .databaseId")
    if [[ -n $run_id ]]; then break; fi
    sleep "$RUN_START_POLL_SECONDS"
  done
  if [[ -z $run_id ]]; then
    echo "::error::publish.yml did not start for $tag" >&2
    exit 1
  fi
  echo "Publishing $tag (run $run_id)"
  gh run watch "$run_id" --exit-status
}

release() {
  local entries entry
  entries=$(plan "${1:-}")
  if [[ -z $entries ]]; then
    echo "Nothing to release: every package version is already on pub.dev."
    return 0
  fi
  echo "Releasing:"
  echo "$entries"
  # A failed publish stops the loop, so nothing ships on top of it.
  local -a lines
  mapfile -t lines <<<"$entries"
  for entry in "${lines[@]}"; do
    # shellcheck disable=SC2086 # "package version" splits on purpose
    publish_one $entry
  done
}

check_tag() {
  local tag=$1
  local package=${tag%-v*} version=${tag##*-v} actual
  if [[ $package == "$tag" || ! -f packages/$package/pubspec.yaml ]]; then
    echo "::error::$tag is not a <package>-v<version> tag of this workspace" >&2
    exit 1
  fi
  actual=$(version_of "$package")
  if [[ $actual != "$version" ]]; then
    echo "::error::$tag does not match packages/$package/pubspec.yaml ($actual)" >&2
    exit 1
  fi
  echo "$package"
}

case ${1:-} in
  plan) plan "${2:-}" ;;
  release) release "${2:-}" ;;
  check-tag) check_tag "${2:?usage: tool/release.sh check-tag <tag>}" ;;
  *)
    sed -n '2,12p' "$0"
    exit 1
    ;;
esac
