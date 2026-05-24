# Backend configuration

## Supabase (primary storage)

Set environment variables in Xcode → Scheme → Run → Arguments → Environment Variables:

| Variable | Example |
|----------|---------|
| `SUPABASE_URL` | `https://YOUR_PROJECT.supabase.co` |
| `SUPABASE_ANON_KEY` | your anon key |

Without these keys, the app uses a local Supabase-compatible folder under Application Support.

## Cloudflare R2 (backup)

| Variable | Example |
|----------|---------|
| `CLOUDFLARE_UPLOAD_URL` | `https://your-worker.example.com/upload` |

## CloudKit / iCloud

Enable **iCloud** capability in Xcode (CloudKit + iCloud Documents). The app writes backup copies automatically after each upload.

## Apple In-App Purchases

Create these product IDs in App Store Connect:

- `com.wcs.psychosocial.pro.monthly`
- `com.wcs.psychosocial.pro.yearly`
- `com.wcs.psychosocial.enterprise.monthly`

Use a StoreKit Configuration file for local testing in Xcode.

## Administrator access

In Settings, use **Grant me administrator (debug)** during development, or assign role `Administrator` via the access control panel.
