# Backend setup

The website remains a static GitHub Pages frontend. Supabase provides hosted authentication, Postgres, private file storage, and Edge Functions; AI provider credentials stay in Edge Function secrets.

## 1. Create and configure Supabase

1. Create a Supabase project and copy its project URL and **publishable** key.
2. In Authentication, enable email sign-in and confirm the allowed redirect URLs include the published GitHub Pages URL and your local development URL.
3. In the Supabase SQL editor (or with the CLI), apply `supabase/migrations/202610230001_backend_foundation.sql`.
4. Deploy the `study-ai` Edge Function. The function requires JWT authentication.
5. In Edge Function secrets, set `OPENAI_API_KEY`, `AI_MODEL` (for example `gpt-4o-mini`), and `APP_ORIGIN` to the exact site origin. Do not put these in GitHub Pages or frontend files.

## 2. Connect the static website

Copy `backend-config.example.js` to `backend-config.js` and fill in only `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. Those client values are designed to be public; database and storage RLS policies are the access control. The AI key and Supabase service-role key must never be placed there.

## 3. Run and deploy

Install the Supabase CLI, run `supabase login`, link the project with `supabase link --project-ref <project-ref>`, apply migrations with `supabase db push`, then deploy the function with `supabase functions deploy study-ai`. Set production secrets in the Supabase Dashboard or with `supabase secrets set`. Publish the website on GitHub Pages and set the matching auth redirect URLs and `APP_ORIGIN`.

For local testing, run a local static server at the configured origin and use `supabase functions serve study-ai --env-file supabase/.env`. Never add real secrets to Git.

## Data and privacy model

The initial sync stores one JSON study-state document per authenticated learner. RLS permits each signed-in user to access only their own row. The upload bucket is private, has a 10 MiB file limit and an allowlist of PDF, text, PNG, and JPEG, and scopes object paths to the authenticated user's ID. Files are not sent to the AI function. Conversations are sent only with the current request and are not persisted by this backend.

The AI function accepts only chat, quiz, flashcard, and plan tasks; requires a valid user session; enforces a 12-request-per-minute account limit; limits the request to 12 KiB; bounds context/history/tokens; and returns generic service errors without upstream details. Update `APP_ORIGIN` to the exact production origin before deployment.

## Owner setup still required

The project owner must create the Supabase project, configure email authentication and redirect URLs, provide the OpenAI API key in Supabase Edge Function secrets, and publish/deploy the backend. The repository does not contain credentials and cannot activate a hosted service until those account-side steps are completed.
