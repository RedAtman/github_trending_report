# GitHub Trending Report

Fetch GitHub trending repos, generate daily/weekly/custom reports via AI (optional) or jq fallback, persist to disk, and email them.

POSIX `sh` compatible — runs on Alpine, macOS, Linux. Zero Python dependency.

## Quick Start

```bash
# Install
sudo ln -sf "$PWD/github_trending_report" /usr/local/bin/github_trending_report

# Or use the built-in install command
./github_trending_report install

# Configure
cp .env.example .env   # edit SMTP credentials
github_trending_report # run with defaults
```

## Dependencies

| Tool | Required | Notes |
|------|----------|-------|
| `curl` | yes | SMTP email sending |
| `jq` | yes | JSON / fallback reports |
| `pi` | no | AI reports (default agent, v0.79+) |
| `omp` | no | Alternative AI agent (Oh My Pi) |
| `opencode` | no | Alternative AI agent |

Install on Alpine:

```bash
apk add curl jq
```

## Usage

```
github_trending_report [options]
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `-r, --range <type>` | Time range: daily / weekly / monthly / yearly | daily |
| `-d, --days <N>` | Look back N days (overrides --range) | — |
| `-l, --limit <N>` | Number of repos to fetch | 20 |
| `--agent <name>` | AI agent: pi / omp / opencode | pi |
| `--no-email` | Skip sending email | — |
| `--no-ai` | Skip AI, use jq fallback report | — |
| `-o, --output <FILE>` | Save report to FILE | — |
| `-q, --quiet` | Suppress progress output | — |
| `--help` | Show help | — |

### Examples

```bash
# Default: daily, 20 repos, AI + email
github_trending_report

# Weekly, 30 repos, no email
github_trending_report -r weekly -l 30 --no-email

# Past 3 days
github_trending_report -d 3

# Past 14 days, 50 repos, jq fallback, quiet
github_trending_report -d 14 -l 50 --no-ai -q

# Use omp as AI agent
github_trending_report --agent omp

# Use opencode as AI agent
github_trending_report --agent opencode

# Monthly, AI only, save to custom path
github_trending_report -r monthly --no-email -o ./monthly-report.md
```

## Configuration

Priority: **CLI arg > env var > .env file**

| Env Var | Default | Description |
|---------|---------|-------------|
| `TRENDING_RANGE` | daily | daily / weekly / monthly / yearly |
| `TRENDING_DAYS` | — | Override range with N-day window |
| `TRENDING_LIMIT` | 20 | Number of repos per report |
| `AI_AGENT` | pi | AI agent: pi / omp / opencode |
| `AI_AGENT_TIMEOUT` | 180 | AI agent timeout in seconds |
| `SMTP_USER` | — | Email account (e.g. `user@qq.com`) |
| `SMTP_PASS` | — | SMTP password / authorization code |
| `AI_MODEL_NAME` | auto (pi config) | Override LLM model name in report footer |
| `MAIL_TO` | — | Recipient email address |
| `SMTP_SERVER` | smtp.qq.com | SMTP server hostname |
| `SMTP_PORT` | 465 | SMTP server port |
| `REPORT_DIR` | `$SCRIPT_DIR/.reports` | Report output directory |

Copy `.env.example` to `.env` and edit:

```bash
cp .env.example .env
```

### QQ 邮箱 SMTP

1. Log in to QQ 邮箱 → Settings → Account
2. Enable SMTP service → Generate **授权码** (16 chars)
3. Put the 授权码 as `SMTP_PASS` in `.env`

## Report Output

Reports are saved to `.reports/` by default:

```
.reports/
├── github-trending-daily-2026-06-21.md
├── github-trending-weekly-2026-06-21.md
└── github-trending-d3-2026-06-21.md
```

### AI Reports (configurable agent)

When an AI agent (`pi`, `omp`, or `opencode`) is available, generates structured reports with:
- Highlights (3-5 featured repos with reasoning)
- Full ranked table
- Categorized trend analysis (by domain, language, ecosystem)
- Tech direction observations

### Fallback Reports (pure jq)

When no AI agent is available, or `--no-ai` is set, generates a minimal jq-powered report:
- Summary table (rank, repo, stars, language, description)
- Language distribution

## Project Files

```
github_trending_report/
├── github_trending_report   Main CLI (executable, POSIX sh)
├── fallback_report.sh       jq fallback report generator
├── .env                     SMTP & runtime config
├── .reports/                Generated reports (gitignored)
├── old_version/             Original Python reference (inert)
└── README.md
```

## Notes

- GitHub Search API has a rate limit (60 req/hr unauthenticated). For heavier use, set `GITHUB_TOKEN`.
- The `install` command creates a symlink to `/usr/local/bin/`.
- Alpine / BusyBox: `timeout` is available from BusyBox coreutils (`apk add coreutils` if missing).
