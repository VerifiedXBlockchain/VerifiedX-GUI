This is a flutter project the powers the VFX GUI

Website: https://verifiedx.io/
Docs: https://docs.verifiedx.io/
CORE CLI Code: https://github.com/VerifiedXBlockchain/VerifiedX-Core
Web Wallet / Explorer Code: https://github.com/VerifiedXBlockchain/VerifiedX-SpyglassService

Something to point out is that this both powers the desktop GUI as well as the web wallet. The web wallet is quite a lot different since it doesn't speak to a CLI directly. Instead, it works through an API that has the data already normalized. It also manages it's own key generation.

This project uses fvm so all flutter/dart commands need to be prefixed with that.