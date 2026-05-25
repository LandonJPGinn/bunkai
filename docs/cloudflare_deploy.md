# Cloudflare Deploy

This app deploys to Cloudflare Pages as a Flutter Web static build. Quiz content
is served from Pages Functions under `/api/*` and stored in Cloudflare D1.

## First-Time Setup

1. Install Wrangler or use `npx wrangler@latest`.
2. Log in:

   ```bash
   npx wrangler@latest login
   ```

3. Create the D1 database:

   ```bash
   npx wrangler@latest d1 create jpquizapp-quiz-content
   ```

4. Copy the returned `database_id` into `wrangler.jsonc`, replacing the
   placeholder `00000000-0000-0000-0000-000000000000`.
5. Apply and seed the local database:

   ```bash
   make d1-migrate-local
   make d1-seed-local
   ```

6. Apply and seed the remote database:

   ```bash
   make d1-migrate-remote
   make d1-seed-remote
   ```

7. Create the Cloudflare Pages project:

   ```bash
   npx wrangler@latest pages project create jpquizapp --production-branch main
   ```

   Or create it in the Cloudflare Dashboard with:

   - Production branch: `main`
   - Build command: `make cloudflare-build`
   - Build output directory: `build/web`

8. Add the D1 binding to the Pages project if it is not picked up from
   `wrangler.jsonc`:

   - Variable name: `DB`
   - Database: `jpquizapp-quiz-content`

9. Add your purchased domain to Cloudflare DNS, then attach it in the Pages
   project under Custom domains.
10. For push-to-deploy through GitHub Actions, add repository secrets:

   - `CLOUDFLARE_ACCOUNT_ID`
   - `CLOUDFLARE_API_TOKEN`

   The [`deploy-cloudflare-pages`](../.github/workflows/deploy-cloudflare-pages.yml)
   workflow builds Flutter, applies D1 migrations, seeds quiz content, and
   deploys `build/web` to the `jpquizapp` Pages project on pushes to `main`.

## Local Preview

```bash
make d1-migrate-local
make d1-seed-local
make cloudflare-preview
```

Release web builds try `/api/quiz-catalog` and `/api/quizzes/:id` first. Debug
Flutter runs use bundled asset JSON by default so `flutter run -d chrome` does
not log expected `/api/*` 404s from the Flutter dev server.

To force API loading in a debug Flutter run:

```bash
flutter run -d chrome --dart-define=JPQUIZAPP_REMOTE_API=true
```
