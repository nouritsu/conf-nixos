# fastmcp-slim is marked broken against mcp 2, so mcp-nixos gets mcp 1.29.0
final: prev: {
  mcp-nixos = prev.mcp-nixos.override {
    python3Packages =
      (prev.python3.override {
        packageOverrides = pyFinal: pyPrev: {
          mcp = pyPrev.mcp.overridePythonAttrs (old: {
            version =
              final.lib.warnIf (!prev.python3Packages.fastmcp-slim.meta.broken)
              "fastmcp-slim works with mcp ${old.version} again, drop the mcp-nixos overlay"
              "1.29.0";

            src = final.fetchFromGitHub {
              owner = "modelcontextprotocol";
              repo = "python-sdk";
              tag = "v1.29.0";
              hash = "sha256-lRlj5RT/R5zrYL5XpdQR2l9t99G94WTsubN0gSQekMc=";
            };

            pythonRelaxDeps = ["pydantic-settings"];

            dependencies = with pyFinal; [
              anyio
              httpx
              httpx-sse
              jsonschema
              pydantic
              pydantic-settings
              pyjwt
              python-multipart
              sse-starlette
              starlette
              uvicorn
            ];

            doCheck = false;
          });
        };
      }).pkgs;
  };
}
