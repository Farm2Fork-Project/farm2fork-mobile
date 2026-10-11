# Farmer listing lifecycle

The mobile farmer portal now uses the authenticated backend in normal builds.
`USE_MOCKS=true` explicitly selects the in-memory repository. A listing created
on mobile is persisted in the same products collection used by the web portal.

## Repeatable cross-client verification

From `farm2fork-backend`:

```sh
pnpm exec ts-node --compiler-options '{"rootDir":"."}' scripts/test/mobile-listings-e2e.ts
```

Requires installed backend/web dependencies, the Flutter SDK on PATH, and mobile
dependencies already resolved. Set `FLUTTER_BIN` to an absolute Flutter executable
if needed. The first run may download a MongoDB test binary.

The harness starts disposable MongoDB and the real Nest marketplace HTTP module
on a random localhost port. It creates two test farmers and one buyer and signs
short-lived JWTs with a random test secret. The production JWT strategy checks
these users in MongoDB; production role/ownership checks and DTO validation run.
No configured Atlas database, Firebase accounts, payment credentials, or Fabric
ledger are used. The test server and database are closed after the run.

The mobile repository test verifies:

1. Create a listing; the backend assigns the product ID, authenticated farmer
   ownership, and QR URL.
2. Reload through a fresh repository and find the persisted listing.
3. Find the same product through the buyer marketplace.
4. Another farmer cannot see it in their own list, update it, or delete it.
5. A buyer cannot create a farmer listing.
6. Deactivate, reactivate, and soft-delete it; buyer browsing follows its status.

The web buyer test then reads that **same mobile-created record** and verifies
deactivation, reactivation, and soft-delete visibility using the real API client
and buyer repository.

The regular mobile/web suites skip these live tests when the harness environment
is absent. The harness explicitly supplies it and runs both tests.

## Form and adapter regression checks

From `farm2fork-mobile`:

```sh
flutter test test/listings --no-pub
```

Includes English and Urdu phone-sized form tests: a failed save retains input,
reports a localized inline error, permits retry, and navigates back only after a
successful save. Adapter/controller tests cover pagination, writable request
fields, server IDs/QR URLs, typed errors, and preserving inventory during retry.

Deletion follows the existing API's soft-delete semantics: the product remains
in the farmer's own list as inactive and disappears from buyer browsing. The QR
URL is backend-generated; this does not establish a working blockchain timeline.

## Device smoke check

For the existing Docker backend mapping (`3002:3000`), an Android emulator needs:

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3002/api
```

Use the actual host port if running Nest directly. Use a reachable host address
for a physical device. Keep `USE_MOCKS` false.

Sign in with an existing verified Firebase farmer, create a listing, restart the
app, and verify it remains. Sign in as a buyer on web/mobile and verify active
visibility. Deactivate/reactivate/delete from the farmer portal and refresh the
buyer marketplace. Test offline submission followed by retry in both languages.

The automated harness starts after identity acquisition; it does not verify
Firebase sign-in, browser session cookies, native device appearance, AI grading,
or ledger writes. Those remain separate integration checks.
