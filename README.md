# Find LucidLink File

Fixes a specific annoyance: [LucidLink Classic](https://www.lucidlink.com/classic) direct links (`lucid://...`) don't work when pasted into Notion. Notion only recognizes `http`/`https` links, so `lucid://` links show up as plain text instead of clickable ones.

This script takes a LucidLink Classic direct link, finds the matching file, and reveals it in Finder (macOS) or File Explorer (Windows). No need for the link to be clickable at all.

## How it works

1. Copy a file's LucidLink direct link (right-click the file in LucidLink → **Copy link**).
2. Run the script.
3. It reads the link (typed in, or automatically from your clipboard if left blank), extracts the filename, walks the mounted LucidLink volume to find it, and reveals it in Finder or File Explorer.

LucidLink filespaces aren't indexed by Spotlight or Windows Search, so this searches the filesystem directly rather than relying on an index. On a large archive this can take a moment.

Two ways to run it, pick whichever fits how you work.

---

## Method 1: Raycast Script Command (recommended)

Runs on a hotkey or alias from anywhere, no window to babysit. Works on both macOS and Windows (Raycast beta) — PowerShell (`.ps1`) is a supported script runtime there, same as bash on Mac.

### macOS:
1. Download [`find-lucidlink-file.sh`](./find-lucidlink-file.sh) into a folder (e.g. `~/Scripts/`).
2. Make it executable: `chmod +x find-lucidlink-file.sh`
3. Raycast → Settings → Extensions tab → Script Commands → Add Script Directory → select the folder.
4. Edit `MOUNT_ROOT` near the top of the script to match your actual LucidLink mount point under `/Volumes/`.
5. Click Reload Script Commands.

### Windows:
1. Download [`Find-LucidLinkFile.ps1`](./Find-LucidLinkFile.ps1) into a folder.
2. Raycast → Settings → Extensions tab → Script Commands → Add Script Directory → select the folder.
3. Edit `$MountRoot` near the top of the script to match your actual LucidLink mount drive/folder.
4. Click Reload Script Commands.

### Both platforms:
- (Optional) Set a hotkey or alias on the command from the same settings row, for instant access.
- **Usage:** copy a `lucid://` link, then run the command — search for it (`Cmd/Ctrl+Space` → "Find LucidLink File") or trigger it with your hotkey. It runs silently and shows a brief notification confirming the result; Finder/File Explorer popping open with the file selected is the main confirmation.

---

## Method 2: Run the script directly (no Raycast)

For anyone who doesn't use Raycast, or just wants to test it first.

### PowerShell (Windows):
1. Download [`Find-LucidLinkFile.ps1`](./Find-LucidLinkFile.ps1).
2. Edit `$MountRoot` near the top to match your actual LucidLink mount drive/folder.
3. Right-click the file → **Run with PowerShell**. Or run it from a terminal:
   ```powershell
   .\Find-LucidLinkFile.ps1 "lucid://your-filespace/file/6:80/Example%2Emp4?reveal=true"
   # or with no argument, to read the link from your clipboard
   .\Find-LucidLinkFile.ps1
   ```
4. If you hit an execution policy error on first run, allow local scripts once with:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

### Apple Shortcuts (macOS):
1. Open the **Shortcuts** app → **+** → name it e.g. `Find LucidLink File`.
2. Add a **Get Clipboard** action.
3. Add a **Run Shell Script** action after it — Shell: `/bin/bash`, Pass Input: **as arguments**.
4. Paste in the contents of [`find-lucidlink-file.sh`](./find-lucidlink-file.sh) (strip the `# @raycast.*` header lines — they're only needed for Method 1).
5. Edit `MOUNT_ROOT` to match your actual LucidLink mount point.
6. Save. Run it via Cmd+Space → shortcut name → Enter, or assign it a keyboard shortcut from the shortcut's details pane.

---

## Known limitations

- **Filename-only matching.** If two files share a name in different folders, it opens whichever one it finds first.
- **No index.** Since Spotlight/Windows Search can't index LucidLink, every run walks the file tree directly. This is fine for now but it will get slower as the archive grows.
- **No auto-reconnect.** If the filespace isn't mounted, you'll get a notification saying so. You'll need to reconnect it in LucidLink and re-run.

---

[Email me](mailto:krabfx@gmail.com?subject=Find%20LucidLink%20File) if you have questions or run into any issues.
