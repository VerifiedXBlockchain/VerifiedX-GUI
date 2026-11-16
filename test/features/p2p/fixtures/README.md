# P2P API fixtures

Bodies of Spyglass `/api/p2p/` (contract: `docs/p2p.md` in VerifiedX-SpyglassService, `origin/testnet` at `05e0c48`).

Captured from https://data-testnet.verifiedx.io/api/p2p/ on 2026-11-16 (the dry-run test shop `dryrun-demo`): `shops_page.json`, `shop_detail.json`, `listings_page.json`, `listing_buy_now.json`, `listing_auction_live.json`, `url_taken.json`, `error_shop_not_found.json`, `error_not_authenticated.json`.

Written by hand to the shapes in `p2p/serializers.py`, `p2p/views.py` (`MeView`) and `p2p/services.py` (`place_bid`), for states the test shop was not in yet: `listing_auction.json`, `bid_result.json`, `listing_sale_pending.json`, `me.json`, `sign_token.json` and the other `error_*.json`. Their addresses, keys, token and signature are made up.
