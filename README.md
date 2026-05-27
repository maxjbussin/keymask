# keymask

[![tests](https://github.com/maxjbussin/keymask/actions/workflows/test.yml/badge.svg)](https://github.com/maxjbussin/keymask/actions/workflows/test.yml)

Tool for vibe-coders so you're not spilling your API keys every time you copy a giant chunk of code over. I aint reading allat.

```bash
$ tail -100 server.log | keymask
2026-05-27 14:05 INFO  request received from 192.168.1.42
2026-05-27 14:05 DEBUG OPENROUTER_API_KEY=[REDACTED:EnvVar]
2026-05-27 14:05 INFO  Authorization: Bearer [REDACTED:JWT]
2026-05-27 14:05 WARN  rate limit hit for user_3DdQ
[keymask] redacted 2: EnvVar=1, JWT=1
```

Catches the key, leaves the log readable. Tells you what it caught on stderr so you can sanity-check before pasting.

## install

One-liner (macOS or Linux, needs Python 3):

```bash
curl -fsSL https://raw.githubusercontent.com/maxjbussin/keymask/main/install.sh | bash
```

Or clone and run the installer:

```bash
git clone https://github.com/maxjbussin/keymask.git
cd keymask && ./install.sh
```

Either way drops `keymask` into `~/.local/bin` and adds it to your PATH. On macOS it also installs a `pbredact` shell function that sanitizes whatever's on your clipboard in place.

## use

```bash
# Sanitize a clipboard before pasting (macOS)
pbredact

# Filter any command output
tail -100 ~/.app/logs/error.log | keymask

# Watch a live stream
tail -f /var/log/app.log | keymask -f

# Dry run — count without modifying
cat config.env | keymask -n
```

Common use cases:

- Any API key hanging out in a code output, before you paste it to Claude/ChatGPT/Cursor
- Any sensitive info in a log you're about to drop in a Slack thread
- `.env` files you want to share the structure of without sharing the values
- Telegram/Discord bot tokens that snuck into your terminal scrollback

## what it catches

| Pattern | Example shape |
|---|---|
| Anthropic | `sk-ant-api03-...` |
| OpenAI | `sk-proj-...`, `sk-svcacct-...`, `sk-...` |
| OpenRouter | `sk-or-v1-...` |
| xAI | `xai-...` |
| Stripe | `sk_live_...`, `sk_test_...`, `pk_live_...` |
| GitHub | `ghp_...`, `gho_...`, `ghs_...` |
| GitLab | `glpat-...` |
| Google OAuth | `ya29....` |
| AWS | `AKIA...`, `ASIA...` |
| Twilio | `AC...` (account SID), `SK...` (API key) |
| Telegram bot | `123456789:AAH-...` |
| ngrok | `2{base64}_{base64}` |
| ElevenLabs | `sk_...` (40+ hex) |
| Slack | `xoxb-...`, `xoxp-...` |
| JWTs | `eyJ...{base64}.{base64}.{base64}` |
| Bearer headers | `Authorization: Bearer ...` |
| PEM blocks | `-----BEGIN ... PRIVATE KEY-----` |
| Generic env vars | `*_TOKEN=`, `*_KEY=`, `*_SECRET=`, `*_PASSWORD=` |

## what it doesn't do

This isn't a vault. It doesn't encrypt anything. It catches keys at paste-time so you don't fat-finger them into the wrong window — that's it.

Specifically:

- **It only catches keys it knows about.** If you have a custom internal token that doesn't match any of the patterns above, the generic `*_TOKEN=` rule probably catches it — but if your secret lives bare in a line of code with no recognizable prefix, keymask won't see it. Always glance at the output before you paste.
- **It won't save you from malware.** If something already has read access to your machine, your keys are already gone. This is paste-time hygiene, not a vault.
- **It can have false positives.** A 40-character hex string that's actually a git commit SHA could trip a pattern. Rare, but it happens. The stderr summary tells you what got caught — sanity check.
- **It's local.** Nothing leaves your machine. Don't replace this with a SaaS redactor.

## contributing a pattern

If you find a key shape that doesn't get caught, open an issue or PR. The pattern list lives in `keymask` (the script itself, top of file) and the tests live in `tests/test_patterns.sh`. A good PR:

1. Adds a new pattern to `PATTERNS` in `keymask`
2. Adds an `assert_redacts` test case in `tests/test_patterns.sh` using a **synthetic / obviously fake** key of that shape
3. Runs `./tests/test_patterns.sh` locally and confirms all tests pass

Never put a real key in a test case. Ever.

## license

MIT — see [LICENSE](LICENSE).

---

*Made by [Max Bowen](https://github.com/maxjbussin). Hope people will know my name. Looking to help everyone and get everyone dancing.*
