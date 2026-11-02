{ inputs, ... }:

_final: prev: {
  mcp-proxy = prev.rustPlatform.buildRustPackage {
    pname = "mcp-proxy";
    version = inputs.mcp-proxy.shortRev or "unstable";

    src = inputs.mcp-proxy;
    cargoHash = "sha256-yTWBv5Y4U69yslIYOqQmJ4JN0t24STvyv+0gOYKtnpU=";

    # The crate asks for a vendored OpenSSL, but the Rust build hook forbids
    # building it, so the system one is linked.
    nativeBuildInputs = with prev; [ pkg-config ];
    buildInputs = with prev; [ openssl ];

    # Integration tests require binaries in specific paths not available in sandbox
    doCheck = false;

    meta = {
      description = "A proxy to use HTTP/SSE MCPs from STDIO clients";
      homepage = "https://github.com/tidewave-ai/mcp_proxy_rust";
      license = prev.lib.licenses.mit;
      mainProgram = "mcp-proxy";
    };
  };
}
