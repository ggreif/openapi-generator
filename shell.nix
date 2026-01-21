{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.11.tar.gz") {} }:

pkgs.mkShell {
  name = "openapi-generator-motoko-dev";

  buildInputs = with pkgs; [
    # Required for OpenAPI Generator
    openjdk17      # Free/libre OpenJDK
    maven
    git

    # Helpful development tools
    which
    curl

    # Optional: for examining/testing outputs
    bat          # Better cat for viewing generated files
    ripgrep      # Fast grep
    tree         # Directory visualization
  ];

  shellHook = ''
    echo "════════════════════════════════════════════"
    echo "  OpenAPI Generator - Motoko Development"
    echo "════════════════════════════════════════════"
    echo ""
    echo "Java:  $(java -version 2>&1 | head -n 1)"
    echo "Maven: $(mvn -version 2>&1 | head -n 1)"
    echo ""

    export JAVA_HOME="${pkgs.openjdk17.home}"
    export PATH="$JAVA_HOME/bin:$PATH"

    # Helpful aliases
    alias build-motoko='mvn clean install -pl modules/openapi-generator,modules/openapi-generator-cli -am -DskipTests -Dmaven.javadoc.skip=true'
    alias gen-motoko='java -jar modules/openapi-generator-cli/target/openapi-generator-cli.jar generate -g motoko -i modules/openapi-generator/src/test/resources/3_0/petstore.yaml -o /tmp/motoko-test -t modules/openapi-generator/src/main/resources/motoko-client'

    echo "Quick commands:"
    echo "  build-motoko  - Build only the generator module"
    echo "  gen-motoko    - Generate Motoko sample code"
    echo ""
    echo "Ready! Run './new.sh -n motoko -c -t' to start"
    echo "════════════════════════════════════════════"
  '';
}
