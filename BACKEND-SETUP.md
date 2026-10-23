# Backend setup

The website remains a static GitHub Pages frontend. Supabase provides hosted authentication, Postgres, private file storage, and Edge Functions; AI provider credentials stay in Edge Function secrets.

## 1. Create and configure Supabase

1. Create a Supabase project and copy its project URL and **publishable** key.
2. In Authentication, enable email sign-in and confirm the allowed redirect URLs include the published GitHub Pages URL and your local development URL.
3. In the Supabase SQL editor (or with the CLI), apply `supabase/migrations/202610230001_backend_foundation.sql`.
4. Deploy the `study-ai` Edge Function. The function requires JWT authentication.
5. In Edge Function secrets, set `OPENAI_API_KEY`, `AI_MODEL` (for example `gpt-4o-mini`), and `APP_ORIGIN` to the exact site origin. Do not put these in GitHub Pages or frontend files.

## 2. Connect the static website

Edit `backend-config.js` and fill in only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. Those client values are designed to be public; database and storage RLS policies are the access control. The AI key and Supabase service-role key must never be placed there.

## 3. Run and deploy

Install the Supabase CLI, run `supabase login`, link the project with `supabase link --project-ref <project-ref>`, apply migrations with `supabase db push`, then deploy the function with `supabase functions deploy study-ai`. Set production secrets in the Supabase Dashboard or with `supabase secrets set`. Publish the website on GitHub Pages and set the matching auth redirect URLs and `APP_ORIGIN`.

For local testing, copy `supabase/.env.example` to `supabase/.env`, add the AI key, add `supabase/.env` to `.gitignore` (already included), run a local static server at the configured origin, then use `supabase functions serve study-ai --env-file supabase/.env`. Never add real secrets to Git.

## Data and privacy model

The initial sync stores one JSON study-state document per authenticated learner. RLS permits each signed-in user to access only their own row. The upload bucket is private, has a 10 MiB file limit and an allowlist of PDF, text, PNG, and JPEG, and scopes object paths to the authenticated user's ID. Files are not sent to the AI function. Chat history is held only in page memory for follow-up questions and sent with the current request; the app does not persist conversations. AI questions are processed by OpenAI, so review its current API data handling and include that processing in your privacy notice before launch.

The AI function accepts only chat, quiz, flashcard, and plan tasks; requires a valid user session; enforces 12 requests per minute and 120 requests per day per account; limits the request to 12 KiB; bounds context/history/tokens; and returns generic service errors without upstream details. Update `APP_ORIGIN` to the exact production origin before deployment.

## Owner setup still required

The project owner must create the Supabase project, configure email authentication and redirect URLs, provide the OpenAI API key in Supabase Edge Function secrets, and publish/deploy the backend. The repository does not contain credentials and cannot activate a hosted service until those account-side steps are completed.

## Reliability and launch checks

Before inviting learners, set a monthly spending limit and alert in the OpenAI project; per-account request limits do not cap total project spend. Configure Supabase backups/exports for the selected plan and test restoring one. Review function and database logs without recording prompts or secrets.

The first sync version saves each learner's app state as one JSON document. It is appropriate for an initial release, but simultaneous edits from two devices can overwrite one another. Until conflict-aware syncing is added, avoid editing the same learner account on multiple devices at once.

After deployment, manually verify sign-up, email confirmation, sign-in, password reset, sync on a second device, owner-only file access, file size/type rejection, AI chat follow-up, AI quiz grading, flashcard generation, plan creation, backend outage behavior, and a mobile viewport. Check the browser source and network requests to confirm no AI or service-role key is sent to the browser.
