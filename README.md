# Rack API template

Ruby 4, Rack, Action Controller, dry-validation, Sidekiq and Redis.
This template provides authenticated example endpoints, JSON error handling,
structured logs and an optional Sidekiq dashboard. It has no user database or
user login implementation.

## Local development

Install the Ruby version in `.ruby-version`, then:

```sh
./bin/setup
# Start Redis, API and Sidekiq in Docker:
docker compose up -d --build
```

`bin/setup` copies `.env.example` if needed, generates missing `CLIENT_API_KEY`
and `SIDEKIQ_WEB_SESSION_SECRET`, restricts `.env` permissions, and installs gems.
It preserves existing settings and secrets. Use `./bin/setup --env-only` to skip
installing gems on the host. When upgrading an existing Docker development
volume, run `docker compose run --rm --no-deps api bundle install` before starting
the services.

When upgrading a pre-existing Redis volume from the original RDB-only setup,
back up `dump.rdb` and enable AOF on the running old Redis first:
`docker compose exec redis redis-cli CONFIG SET appendonly yes`. Before recreating
Redis, use `INFO persistence` to confirm `aof_rewrite_in_progress:0`,
`aof_rewrite_scheduled:0` and `aof_last_bgrewrite_status:ok`. Check the key count
after restart. Simply enabling AOF in a new container can skip existing RDB data.

For native Ruby development instead:

```sh
docker compose up -d redis
./bin/dev
```

Native development uses `REDIS_URL=redis://127.0.0.1:6379`; Compose overrides the
hostname to `redis`. The API and Redis ports bind only to localhost. API, job,
contract, service, Rack and YAML configuration changes restart the development
processes. After changing `.env`, restart Foreman or run `docker compose up -d`
to recreate affected containers.

`bundle exec ./bin/console` loads the same application classes and Redis client
configuration as the API. `make help` lists the other commands.

## API

| Method | Path | Authentication | Behavior |
| --- | --- | --- | --- |
| GET / HEAD | `/health` or `/health/live` | Public | Process liveness; does not contact Redis. |
| GET / HEAD | `/health/ready` | Public | Checks Redis with a bounded timeout; returns 503 if unavailable. |
| GET | `/examples` | `Api-Key` | Example JSON response. |
| POST | `/examples/validate` | `Api-Key` | Validates an email/password payload; returns only email and `valid`. |
| GET / POST | `/sidekiq` | HTTP Basic | Optional dashboard, including Recurring Jobs. |

Send the raw `CLIENT_API_KEY` in the `Api-Key` header, without Base64 encoding.
API keys identify trusted clients; they are not a user login mechanism and must
not be embedded in a public frontend. The former `/sign_in` demonstration was
removed and now returns 404. The example validation endpoint does not create a
user, verify an account, store a password, or issue a token.

```sh
# Set CLIENT_API_KEY in your shell to the value generated in .env.
curl http://localhost:3000/examples/validate \
  -H "Api-Key: $CLIENT_API_KEY" \
  -H 'Content-Type: application/json' \
  --data '{"email":"user@example.com","password":"example-only"}'
```

Successful response:

```json
{"email":"user@example.com","valid":true}
```

Request bodies must be JSON objects. Unknown fields and invalid values return
422; malformed JSON returns 400, oversized bodies 413, and unsupported content
types 415. Errors include `errors` and `request_id`. Unexpected application
errors return a generic 500. Every response includes `X-Request-ID`; JSON
responses are marked `Cache-Control: no-store`.

## Configuration

Configuration is validated at startup. The HTTP application requires a
`CLIENT_API_KEY` with at least 32 characters. Workers and the console can start
without HTTP credentials.

| Variable | Default | Purpose |
| --- | --- | --- |
| `RACK_ENV` | `development` | `development`, `test`, or `production`. |
| `APP_NAME` | `rack-api` | Application name in health responses and logs. |
| `LOG_LEVEL` | `INFO` | JSON log severity. |
| `PORT` | `3000` | HTTP port. |
| `MIN_THREADS`, `MAX_THREADS` | `5`, `5` | Puma threads per process. |
| `WEB_CONCURRENCY` | `0` | Puma worker processes; 0 runs a single process. Set explicitly for available CPU/memory. |
| `SIDEKIQ_CONCURRENCY` | `5` | Job threads, independent of Puma. |
| `SIDEKIQ_TIMEOUT` | `25` | Seconds allowed for Sidekiq to finish current jobs. |
| `REDIS_URL` | `redis://127.0.0.1:6379` | Redis connection; supports `rediss://`. |
| `REDIS_DB` | `1` | Logical database; overrides any database in the URL. |
| `MAX_REQUEST_BYTES` | `1048576` | Maximum API request body size. |
| `CORS_ORIGINS` | Empty | Comma-separated browser origin allowlist; empty denies cross-origin access. Production rejects `*`. |
| `SIDEKIQ_WEB_ENABLED` | Development only | Enables `/sidekiq`; explicitly set `true` in production if needed. |
| `ENABLE_EXAMPLE_JOBS` | Development only | Enables the `hello_world` sample schedule. |

`.env` is loaded automatically only in development. Production configuration
must be supplied by the runtime. Do not use the development `.env` unchanged in
production: it explicitly enables the sample job and dashboard and has short
development dashboard credentials.

## Sidekiq dashboard and jobs

Open http://localhost:3000/sidekiq. The development example uses `dev` / `dev`.
Set `SIDEKIQ_WEB_USERNAME`, `SIDEKIQ_WEB_PASSWORD` and a shared
`SIDEKIQ_WEB_SESSION_SECRET` of at least 64 characters. Production requires a
dashboard password of at least 16 characters and uses secure session cookies.
Terminate HTTPS at your reverse proxy and configure it to overwrite forwarded
headers from untrusted clients. Session cookies last at most 24 hours.

The API and worker use the same Redis URL and database. Redis uses append-only
persistence (`everysec`) and `noeviction` in Compose; monitor disk/memory capacity
and back up Redis data for production. Append-only persistence can still lose
the most recent writes during a crash.

Jobs must be safe to retry and to execute more than once. Pass simple JSON
values or record IDs, never credentials or model objects. Use bounded network
timeouts in jobs. `HelloJob` only logs a message and has three retries; its
sample schedule is disabled by default in production. Application startup loads
all classes in production and CI to catch naming errors before serving traffic.

Allow at least `SIDEKIQ_TIMEOUT + 5` seconds before killing a worker. Compose and
the integration check allow 35 seconds for the default 25-second timeout. Increase
that grace period too if you raise `SIDEKIQ_TIMEOUT`.

## Structure and logs

- `config/boot.rb`: shared dependencies, settings, logger and Zeitwerk loader.
- `lib/rack_api/`: application assembly, dashboard, settings and HTTP middleware.
- `api/controllers/`, `api/concerns/`: HTTP responses and API-key enforcement.
- `contracts/`: input validation.
- `services/`: business operations, independent of HTTP rendering.
- `jobs/`: Sidekiq jobs.

HTTP logs contain method, path, final status, duration and request ID. They omit
request bodies, query strings and credential headers. Error events record the
exception class and source locations, not potentially sensitive exception
messages. Job logs include job ID, class and execution duration. Collect these
JSON events centrally and monitor HTTP errors and duration, Sidekiq failures,
queue latency and Redis capacity. The dashboard exposes Sidekiq statistics;
external alert delivery is configured in your monitoring platform.

## Verification

```sh
bundle exec rake                      # Eager loading, lint and request/unit tests
bundle exec bundle-audit check --update
make build
make smoke                            # Production image + isolated Redis + worker
```

`bin/smoke-image IMAGE` checks that the image runs without root, contains no
`.env`, Git history or test gems, and starts with a read-only filesystem. It
checks API authentication, validation, password-free logs, dashboard pages,
secure cookies, a CSRF-protected action, a real delayed job, graceful worker
shutdown and readiness during a Redis outage. Its containers and network are
disposable and do not use your development Redis volume.

## Production and CI

```sh
make build IMAGE=rack-api:release
# Supply a production env file containing RACK_ENV=production and your secrets.
docker run --rm --env-file .env.production -p 127.0.0.1:3000:3000 \
  rack-api:release
docker run --rm --stop-timeout 35 --env-file .env.production \
  rack-api:release bundle exec sidekiq -r ./config/sidekiq.rb -C config/sidekiq.yml
```

The production image excludes development/test gems and runs as UID/GID 10001.
It starts Puma by default. Configure a reachable Redis endpoint, HTTPS ingress
and process restarts in your deployment platform; the supplied Compose file is
for local development.

CI reads `.ruby-version`, runs tests and dependency auditing, builds the image,
and runs the production integration check. The manual publish workflow performs
the same checks before pushing. Configure `DOCKER_USERNAME` and
`DOCKER_PASSWORD` (a Docker Hub access token) as repository secrets to publish to
`popac/rack-api`. Release tags are validated and all third-party actions are
pinned to commit SHAs. Dependabot proposes weekly gem, Docker and action updates.

Older images built before the `.dockerignore` correction may contain `.env` and
Git history. Replace those images; rotate embedded secrets if an old image was
shared. Rebuilding does not remove older images from a registry or Docker cache.
