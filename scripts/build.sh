#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/vprofile-src"
WORK="$ROOT/build-work"

[[ "$ROOT" != "/" ]] || fail "Could not determine the repository folder safely."
[[ -f "$SRC/pom.xml" ]] || fail "VProfile source POM not found: $SRC/pom.xml"

rm -rf -- "$WORK"
mkdir -- "$WORK"
cp -a -- "$SRC/." "$WORK/"
rm -rf -- "$WORK/.git"
cd -- "$WORK"

opening_tags="$(grep -c '<dependencies>' pom.xml || true)"
closing_tags="$(grep -c '</dependencies>' pom.xml || true)"

[[ "$opening_tags" -eq 1 ]] || fail "Expected exactly one <dependencies> tag."
[[ "$closing_tags" -eq 1 ]] || fail "Expected exactly one </dependencies> tag."

if grep -Fq '<artifactId>junit-vintage-engine</artifactId>' pom.xml; then
  fail "The JUnit Vintage dependency is already present."
fi

sed -i 's#</dependencies>#<dependency><groupId>org.junit.vintage</groupId><artifactId>junit-vintage-engine</artifactId><version>5.10.0</version><scope>test</scope></dependency></dependencies>#' pom.xml

mvn -B clean package 2>&1 | tee mvn.log

grep -Eq 'Tests run: [1-9][0-9]*,' mvn.log || fail "Maven did not report any tests as run."
[[ -f target/vprofile-v2.war ]] || fail "Expected WAR file was not created: target/vprofile-v2.war"

echo "OK: tests ran and the WAR was created."
