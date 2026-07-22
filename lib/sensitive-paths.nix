{ lib }:

let
  # Shared sensitive-path classifications. Credential paths are enforced by
  # both agents. Encrypted paths are context hygiene for Claude Code only:
  # denying tracked files in Codex's process sandbox breaks Git and jj.
  policy = {
    common = {
      # Home-relative directories holding private keys.
      homeKeyDirs = [
        ".ssh"
        ".gnupg"
      ];

      # Credential filenames matched anywhere in a project tree. Keep this list
      # limited to formats that commonly contain secrets or private keys.
      credentialPatterns = [
        ".env"
        ".env.*"
        "*.env"
        "*.key"
        "*.pem"
        "*.p8"
        "*.p12"
        "*.pfx"
        "*.ppk"
        "*.jks"
        "credentials.json"
      ];
    };

    contextOnly = {
      # Encrypted at rest, so these are context hygiene rather than protection.
      encryptedPatterns = [ "*.age" ];
      encryptedDirs = [ ".secrets" ];
    };
  };

  workspaceGlob = pattern: "**/${pattern}";
  claudeRead = path: "Read(${path})";
  denyAll = entries: lib.genAttrs entries (_: "deny");

  # Prepend the machine's key directory to the shared list as a home-relative
  # path, so both agents can anchor it under `~` alongside the other key dirs.
  keyDirsUnder =
    { keyHome, homeDirectory }:
    assert lib.assertMsg (lib.hasPrefix "${homeDirectory}/" keyHome)
      "sensitive-paths: keyHome must live under homeDirectory";
    [ (lib.removePrefix "${homeDirectory}/" keyHome) ] ++ policy.common.homeKeyDirs;

  workspaceCredentialPatterns = map workspaceGlob policy.common.credentialPatterns;

  workspaceContextPatterns = map workspaceGlob (
    policy.contextOnly.encryptedPatterns ++ policy.contextOnly.encryptedDirs
  );

  claudeContextRules =
    map (pattern: claudeRead (workspaceGlob pattern)) policy.contextOnly.encryptedPatterns
    ++ map (dir: claudeRead "${dir}/**") policy.contextOnly.encryptedDirs;
in
{
  # Claude Code deny rules as gitignore-style `Read(...)`. Home key directories
  # anchor under `~`; credential and encrypted patterns stay project-relative.
  claudeDenyRules =
    { keyHome, homeDirectory }:
    let
      rules = map claudeRead (
        map (dir: "~/${dir}/**") (keyDirsUnder {
          inherit keyHome homeDirectory;
        })
        ++ workspaceCredentialPatterns
        ++ map workspaceGlob policy.contextOnly.encryptedPatterns
        ++ map (dir: "${dir}/**") policy.contextOnly.encryptedDirs
      );
    in
    assert lib.assertMsg (lib.all (
      rule: lib.elem rule rules
    ) claudeContextRules) "Claude Code must deny encrypted context paths";
    rules;

  # Codex deny entries: global key directories are home-relative, while
  # credential filename patterns are scoped to the active workspace roots.
  # Do not deny encryptedDirs here: Codex's OS-level sandbox also applies to
  # child processes, so denying tracked encrypted files prevents jj and Git
  # from inspecting or snapshotting the working copy.
  codexDenyEntries =
    { keyHome, homeDirectory }:
    let
      workspaceEntries = denyAll workspaceCredentialPatterns;
    in
    assert lib.assertMsg (lib.all (
      pattern: !(builtins.hasAttr pattern workspaceEntries)
    ) workspaceContextPatterns) "Codex must not deny tracked encrypted context paths";
    denyAll (
      map (dir: "~/${dir}") (keyDirsUnder {
        inherit keyHome homeDirectory;
      })
    )
    // {
      ":workspace_roots" = workspaceEntries;
    };
}
