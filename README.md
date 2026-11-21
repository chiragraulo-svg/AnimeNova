[README.md](https://github.com/user-attachments/files/35203966/README.md)
# AnimeNova

AnimeNova is a dark-purple anime catalogue prototype with a Supabase-connected admin dashboard.

## Quick start

1. Run `supabase/schema.sql` in your Supabase project's SQL Editor.
2. Deploy this folder or open `index.html`.
3. Create your account using the website's Sign in dialog.
4. Promote your account to admin using the UUID-based SQL instructions in `SETUP.md`.
5. Sign out and back in, then open Admin.

See `SETUP.md` for the full setup and security notes.


## Custom AnimeNova video player

The viewing page includes a responsive purple-neon player interface with:

- Play/pause, seek, volume and mute controls
- Playback speed selection (0.75×–2×)
- WebVTT subtitle toggle when a subtitle track is supplied
- Fullscreen, previous/next episode navigation and an episode rail
- Local resume position saved in the current browser
- Keyboard shortcuts while the player page is open: Space (play/pause), ←/→ (seek 10 seconds), M (mute)

The player does not include video content. Add only video URLs that you own or are authorized to distribute. Browser playback depends on the source format (commonly MP4/H.264) and the video host's CORS configuration. WebVTT subtitle files must also be reachable by the browser.
