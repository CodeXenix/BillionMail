# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Xenix Mail is an open-source mail server and email marketing platform (bulk sending, campaigns, contacts, warmup, analytics). The Go backend + Vue admin UI live in `core/`; the mail stack (Postfix, Dovecot, Rspamd, Roundcube, Postgres, Redis) runs as separate containers configured from `conf/`.

**Naming:** the project is a rebrand of BillionMail. Everything users see and every code name (Go module `xenixmail-core`) says Xenix Mail. Runtime names stay `billionmail` on purpose, so existing installs and the upstream Docker Hub images keep working: image names (`billionmail/*`), compose services and containers (`*-billionmail`), `billionmail-network`, `/opt/billionmail` paths, `BILLIONMAIL_*` env vars, the database name and user, the Postfix `master.cf` markers, and the session cookie and server names (`billion_mail` in config.yaml, `consts.DEFAULT_SERVER_NAME`), which key stored sessions. Do not rename them in passing. Name new user-facing text "Xenix Mail".

## Stack

- **Backend:** Go 1.24 (`core/go.mod`), GoFrame v2, PostgreSQL, Redis
- **Frontend:** Vue 3, TypeScript, Pinia, Naive UI, UnoCSS, Rsbuild, Vitest, pnpm
- **Mail:** Postfix, Dovecot, Rspamd, Roundcube
- **Deploy:** Docker Compose (`docker-compose.yml` at repo root)

## Commands

```bash
# Go — vet/test the api, internal and utility trees, NOT ./... (see "Two main() functions" below)
cd core && go vet ./api/... ./internal/... ./utility/... && gofmt -l .
cd core && go test -count=1 -short ./internal/service/...
cd core && go test -count=1 -run TestName ./internal/service/domains/   # single test

# Frontend
cd core/frontend && pnpm run lint          # lint:fix to autofix
cd core/frontend && pnpm test              # vitest run, src/**/*.test.ts
cd core/frontend && pnpm vitest run src/api/modules/domain.test.ts   # single file
cd core/frontend && pnpm build:git         # build + copy into core/public/dist

# GoFrame codegen (installs the gf CLI if missing)
cd core && make ctrl                       # gf gen ctrl: api/<domain>/v1 → controller stubs

# Stack
cp env_init .env   # then set secrets; install.sh generates random ones
docker compose up -d

# E2E (pytest + httpx; needs BM on http://localhost:8880 or BM_URL, plus FrostByte and Mailpit)
docker compose -f docker-compose.yml -f docker-compose.test.yml up -d
cd e2e && pytest tests/test_05_contact_mgmt.py
```

After editing any file, run the matching vet/gofmt or lint command above and fix all errors before continuing.

## Architecture

**Server bootstrap** is `core/internal/cmd/cmd.go`. It initialises DB and Redis, starts timers (`service/timers`), then registers, in order: a `HookBeforeServe` safe-path gate, the `/api` group (middleware chain: CORS → docker client → JWT → RBAC → `HandleApiResponse`), `/roundcube/*` (PHP-FPM over a unix socket), `/rspamd/*` (reverse proxy), `/pmta/*` (open/click tracking), `/.well-known/acme-challenge/*`, and an SPA fallback that serves `public/dist/index.html`.

**Runtime config comes from the repo-root `.env`**, not `manifest/config/config.yaml`. `public.DockerEnv("KEY")` reads it, e.g. `DBPASS`, `SafePath`, `WEB_BASE_PATH`. In the container it is mounted at `/opt/billionmail/.env`. Postgres is reached through the `postgresql-socket/` unix socket.

**Adding an API endpoint (GoFrame convention):**
1. Define `XxxReq`/`XxxRes` structs with `g.Meta \`path:"..." method:"..."\`` in `core/api/<domain>/v1/`.
2. Run `make ctrl`. It regenerates `core/api/<domain>/<domain>.go` (the interface; do not edit) and creates stubs at `core/internal/controller/<domain>/<domain>_v1_<op>.go`.
3. For a new domain, bind `<domain>.NewV1()` in the `/api` group in `cmd.go` **and** add the module name to the RBAC `modules` list in `core/internal/service/middlewares/rbac.go`.
4. Put business logic in `core/internal/service/<domain>/`.

**API responses** have the shape `{success, code, msg, data}`, with `code == 0` meaning success. The frontend axios interceptor in `core/frontend/src/api/index.ts` depends on this.

**Data access:** there is no DAO layer, and `internal/dao` and `internal/logic` are empty. Services query tables directly with `g.DB().Model("table_name")`. Entities in `internal/model/entity` are maintained by hand; `hack/config.yaml`'s `gen dao` config is a leftover template.

**Schema** is created at every core startup. Each file in `core/internal/service/database_initialization/` uses `init()` → `registerHandler(...)` to run `CREATE TABLE/INDEX IF NOT EXISTS` statements. There is no migration tool, so schema changes must be idempotent and additive.

**i18n has two halves:**
- Backend messages use `public.LangCtx(ctx, "...")` with `core/languages/<lang>/server.json`.
- Frontend strings live in `core/frontend/src/i18n/lang/{en,zh,ja}.json`.

**Frontend wiring:**
- Route files in `src/router/modules/*.ts` are auto-loaded through `import.meta.webpackContext`.
- `src/components/**` and Naive UI components are auto-imported (unplugin; types in `types/components.d.ts`).
- `vue`, `vue-router` and `vue-i18n` APIs are auto-imported as well.
- API modules call paths such as `/batch_mail/api/list` under the `/api` base URL.
- The dev server's `/api` proxy target comes from a hard-coded IP map in `frontend/build/config.ts`, keyed by the `SERVER_NAME` env var. Add an entry to point it at your own instance.

**Built frontend is committed:** `core/public/dist` is checked in and served by core. Rebuild it with `pnpm build:git` when a frontend change has to ship.

**Local dev loop:**
- The `core-billionmail` container runs the Docker Hub image `billionmail/core:<ver>`, so local source changes do not reach it automatically.
- `core/run_dev.sh` builds the binary inside a `p-g-alpine` helper container (set it up as shown in the header of `core/go-build.sh`), copies the binary plus `public/`, `manifest/` and `template/` into the core container, and restarts it.
- `go run run_dev.go` watches the tree and re-runs that script on changes.

## Gotchas

- **Two `main()` functions:** `core/main.go` and `core/run_dev.go` both live in the root `package main`. `go build ./...` and `go vet ./...` therefore fail on the root package. Build with `go build main.go`, as `go-build.sh` does.
- **Safe path:** when `SafePath` is set in `.env`, every request except `/`, static files and the excluded URIs in `cmd.go` gets a bare 404 ("Not Found"), and `/api/*` gets `access denied`, until the browser session has visited `/<SafePath>`. Sessions are in memory, so restarting core invalidates them and you must visit `/<SafePath>` again.

## Rules

- NEVER use the bare domain for mail infrastructure (DNS, certs, DKIM, dedicated IPs). Always call `public.FormatMX(domain)` to get the mail hostname (e.g., `mail.example.com`).
- One directory per domain under `core/api/`, `core/internal/controller/`, `core/internal/service/`, and `core/frontend/src/views/`.
- Tests sit next to their source (`*_test.go`, `*.test.ts`). Go test fixtures/builders are in `core/internal/service/testutil`.
