_final: prev:

{
  # Nushell resolves a relative `use` against the file that holds it, so the
  # layout has to survive into the store. The writers build one file each, so
  # the package is assembled here and every file is checked.
  nixosadm =
    prev.runCommandLocal "nixosadm"
      {
        nativeBuildInputs = [ prev.makeBinaryWrapper ];
        meta.mainProgram = "nixosadm";
      }
      ''
        install -Dm644 -t $out/libexec/nixosadm ${../scripts/nixosadm}/*.nu
        install -Dm644 -t $out/libexec/lib ${../scripts/lib}/*.nu

        # Nushell names a script's commands after its file; that name prints
        # in the help.
        mv $out/libexec/nixosadm/nixosadm.nu $out/libexec/nixosadm/nixosadm
        chmod 755 $out/libexec/nixosadm/nixosadm

        for script in $out/libexec/lib/*.nu $out/libexec/nixosadm/*; do
          ${prev.nu-ide-check} "$script"
        done

        makeWrapper ${prev.nushell}/bin/nu $out/bin/nixosadm \
          --add-flags --no-config-file \
          --add-flags $out/libexec/nixosadm/nixosadm \
          --prefix PATH : ${
            prev.lib.makeBinPath [
              prev.efibootmgr
              prev.util-linux
            ]
          }
      '';
}
