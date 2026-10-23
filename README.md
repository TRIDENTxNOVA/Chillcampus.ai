# Chill Campus.ai

Chill Campus.ai is a student-built study companion. The website remains in browser-only preview mode until the owner configures the optional Supabase backend. Once configured, it supports accounts, private learner sync, private file storage, and server-side Study AI.

## Open the website

Use Visual Studio Code with Live Server, or another local static web server. Opening `index.html` directly still shows the preview, but service worker and backend features require a local server.

## Try the preview

1. Add or edit syllabus topics and update topic confidence.
2. Create a planner schedule and mark tasks complete.
3. Try quiz, flashcard, revision, focus session, appearance modes, and resource tools.
4. Open Profile & Settings to export local study data.

## Project files

- `index.html`, `styles.css`, `app.js` — interface, styling, and browser interactions.
- `logo.svg`, `manifest.json`, `sw.js` — brand mark and PWA support.
- `BACKEND-SETUP.md` — Supabase setup, secrets, deployment, privacy, and owner actions.
- `supabase/migrations/` and `supabase/functions/` — access policies and secure Study AI endpoint.
- `backend-config.js` — public Supabase project settings template.

## Backend status

Browser preview features continue to work locally. Real accounts, cross-device data sync, private uploads, and AI-generated chat, quizzes, flashcards, and plans activate only after the owner creates a Supabase project, applies the migration, sets the public project URL/key in `backend-config.js`, adds the OpenAI key as a server-side Edge Function secret, configures email redirects and the site origin, and deploys the function. Until then, Study AI explains that it is not connected and does not return fake answers.

The app does not persist chat history. Relevant syllabus progress and exam-plan details are sent to the AI function for personalized requests. The function sends the study request to OpenAI; publish a privacy notice that explains this processing before launch. Do not use student IDs, Aadhaar, phone numbers, passwords, or payment details in study content.
