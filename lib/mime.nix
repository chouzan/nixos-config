{ lib }:

rec {
  # A group names a kind of file and never an application, which keeps the list
  # of types independent of whichever module chooses the applications.
  #
  # Reference: https://specifications.freedesktop.org/shared-mime-info-spec/latest/
  types = {
    image = [
      "image/avif"
      "image/bmp"
      "image/gif"
      "image/heif"
      "image/jpeg"
      "image/jxl"
      "image/openraster"
      "image/png"
      "image/svg+xml"
      "image/svg+xml-compressed"
      "image/tiff"
      "image/webp"
      "image/x-eps"
      "image/x-icns"
      "image/x-ico"
      "image/x-portable-bitmap"
      "image/x-portable-graymap"
      "image/x-portable-pixmap"
      "image/x-psd"
      "image/x-tga"
      "image/x-webp"
      "image/x-xbitmap"
      "image/x-xcf"
      "image/x-xpixmap"
    ];

    video = [
      "video/mp4"
      "video/mpeg"
      "video/ogg"
      "video/quicktime"
      "video/webm"
      "video/x-matroska"
      "video/x-msvideo"
    ];

    audio = [
      "audio/flac"
      "audio/mp4"
      "audio/mpeg"
      "audio/ogg"
      "audio/x-vorbis+ogg"
      "audio/x-wav"
    ];

    document = [
      "application/epub+zip"
      "application/pdf"
    ];

    web = [
      "application/xhtml+xml"
      "text/html"
    ];

    directory = [
      "inode/directory"
    ];
  };

  # Shape a map of group to desktop entry for xdg.mime.defaultApplications.
  defaultApplications =
    applications:
    lib.concatMapAttrs (
      group: application:
      let
        groups = lib.concatStringsSep ", " (lib.attrNames types);
        unknown = throw "mime: no group named '${group}'. Groups: ${groups}.";
      in
      lib.genAttrs (types.${group} or unknown) (_type: application)
    ) applications;
}
