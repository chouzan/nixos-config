{ ... }:

# Wrap claude-code-bun to provide /bin/claude for home-manager module
final: prev: {
  claude-code-bun = final.symlinkJoin {
    name = "claude-code-bun-wrapped";
    paths = [ prev.claude-code-bun ];

    postBuild = ''
      ln -s $out/bin/claude-bun $out/bin/claude
    '';
  };
}
