_final: prev: {
  mcp-proxy = prev.rustPlatform.buildRustPackage rec {
    pname = "mcp-proxy";
    version = "0.2.3";

    src = prev.fetchFromGitHub {
      owner = "tidewave-ai";
      repo = "mcp_proxy_rust";
      rev = "v${version}";
      hash = "sha256-pU4a9cpMltu8dRkYtq/ge84RHLCqEDtbhItN7rarSOc=";
    };

    cargoHash = "sha256-yTWBv5Y4U69yslIYOqQmJ4JN0t24STvyv+0gOYKtnpU=";

    nativeBuildInputs = with prev; [
      pkg-config
      perl
    ];

    buildInputs = with prev; [
      openssl
    ];

    doCheck = false;

    meta = {
      description = "A proxy to use HTTP/SSE MCPs from STDIO clients";
      homepage = "https://github.com/tidewave-ai/mcp_proxy_rust";
      license = prev.lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "mcp-proxy";
    };
  };
}
