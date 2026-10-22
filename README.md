# Chill Campus.ai

Chill Campus.ai is a student-built study companion. This project is a local-first website preview: it lets you explore the learning flow without setting up accounts or sending student data to a server.

## Open the website

Open this folder in Visual Studio Code and use the free **Live Server** extension, or serve the folder with a local static web server. Open the local address the server provides. A local server is required for the service worker and PWA behavior. Opening `index.html` directly still shows the website, but PWA registration will be skipped.

## Try it

1. Open **Syllabus**, edit a sample subject, or add your own subject, unit, and topics.
2. Change a topic to **Learning** or **Confident** and see the dashboard, progress, and revision queue update.
3. Open **Study**, then choose **Resources & Notes** to add a YouTube, notes, or practice link. Topic cards also offer a YouTube search suggestion.
4. Create an exam plan, complete a plan task, and see your progress update.
5. Open **Practice** to switch between quizzes, flashcards, and your revision queue. Start a short focus session from the clock button.
6. Open **More** for community posts and progress milestones. These are private to this browser preview.

## Current project files

- `index.html`, `styles.css`, `app.js` — website pages, styling, and local interactions.
- `logo.svg`, `manifest.json`, `sw.js` — website/PWA logo, install metadata, and basic app-shell offline support.
- `ARCHITECTURE.md` — recommended production architecture and implementation stages.
- `DATA-MODEL.md` — database design for student, college, syllabus, planner, resource, and community features.
- `API.md`, `openapi.yaml` — draft API routes and request/response contract.

## What is and is not connected

**Works in this preview:** local syllabus management and topic status, YouTube search suggestions by topic, personal links, a deterministic planner, quiz explanations, flashcards, a focus timer, local community posts, progress points, and browser-local saving. The navigation groups related tools into Study, Practice, and More hubs, with a compact labeled phone menu.

**Needs a secure backend or external setup:** real sign-up/sign-in, college student verification, a verified Indian institution directory, shared college data, uploads and PDF parsing, cross-device sync, YouTube API recommendations, AI answers, and a real college/batch leaderboard. The interface labels these boundaries and does not pretend those services are active.

Do not enter passwords, student ID numbers, or sensitive personal information in this browser preview. Local storage is not a secure account system. See the architecture, data model, and API contract before adding a backend.

## Beginner learning path

Start with `index.html` (page structure), then `styles.css` (appearance), then `app.js` (interactions and browser storage). Change the sample syllabus and try each tab. Once the local version makes sense, build the backend and real authentication using the API and data-model documents as guides.
