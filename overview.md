# ruby-datocms-client: technical overview

This gem combines three concerns in one codebase:

1. A generic Content Management API (CMA) client for DatoCMS.
2. A local object layer that turns JSON:API payloads into Ruby-friendly objects.
3. A CLI dump engine that exports CMS content to local files for static-site workflows.

It is useful to read it as a pipeline:

`HTTP API -> schema-driven repos -> local entities/items -> dump DSL -> files on disk`

## Top-level map

- `exe/dato`: executable entrypoint. Loads `.env`, requires `dato`, starts Thor CLI.
- `lib/dato.rb`: public gem entrypoint; wires major subsystems.
- `lib/dato/site/client.rb`: Site-level CMA client.
- `lib/dato/account/client.rb`: Account-level CMA client.
- `lib/dato/api_client.rb`: shared HTTP/auth/retry behavior + schema loading.
- `lib/dato/repo.rb`: dynamic resource repository (`items`, `item_types`, etc.).
- `lib/dato/local/*`: local in-memory model of site, items, fields, relationships.
- `lib/dato/dump/*`: dump config DSL, operations, formatters, runner.
- `lib/dato/upload/*`: upload helpers (local file or URL -> upload_request -> upload id).
- `lib/dato/utils/*`: SEO tags, favicon tags, modular block payload helper.
- `spec/*`: unit + integration coverage (mostly VCR-backed API interaction tests).

## Feature breakdown by subsystem

### 1) Schema-driven API layer

Main files:
- `lib/dato/api_client.rb`
- `lib/dato/repo.rb`
- `lib/dato/json_api_serializer.rb`
- `lib/dato/json_api_deserializer.rb`
- `lib/dato/paginator.rb`

What it does:
- Loads API hyperschema from `/docs/*-hyperschema.json`.
- Builds dynamic repos via `method_missing` (for example `client.items`, `client.fields`).
- Converts Ruby hashes to JSON:API request bodies and back.
- Handles pagination (`all_pages: true`), rate-limit retry, and async-job polling.
- Exposes two concrete clients:
  - `Dato::Site::Client` (`site-api`)
  - `Dato::Account::Client` (`account-api`)

How it fits:
- This is the foundation. Everything else depends on it for raw data access.

### 2) Local object graph (content snapshot)

Main files:
- `lib/dato/local/loader.rb`
- `lib/dato/local/entities_repo.rb`
- `lib/dato/local/items_repo.rb`
- `lib/dato/local/item.rb`
- `lib/dato/local/site.rb`
- `lib/dato/local/field_type/*.rb`

What it does:
- Fetches site + items + uploads into memory (`Loader#load`).
- Stores raw JSON:API entities in `EntitiesRepo`.
- Builds typed queryable collections in `ItemsRepo`:
  - lookup by id
  - dynamic item-type methods (`articles`, singleton methods, conflict handling)
  - tree children lookup
  - sorting by position/ordering field
- Wraps each item in `Local::Item`, with lazy field decoding through field-type adapters.
- Supports locale fallback through `Dato::Utils::LocaleValue`.

How it fits:
- Used primarily by the dump system, but can also be used directly as a read-model API.

### 3) Field-type adapter layer

Main files:
- `lib/dato/local/field_type/*.rb` (notably `file.rb`, `structured_text.rb`, `seo.rb`, `theme.rb`)

What it does:
- Converts raw field payloads into richer Ruby objects.
- Resolves references (`link`, `links`, `single_block`, `rich_text`, `structured_text`) to `Local::Item` objects.
- Wraps upload/image data with imgix URL helpers (`file`, `upload_id`, `gallery`).
- Adds convenience types (`color`, `lat_lon`, `video`, `date`, `date_time`, etc.).

How it fits:
- This is the "developer experience" layer on top of raw API payloads.

### 4) Dump CLI and DSL

Main files:
- `lib/dato/cli.rb`
- `lib/dato/dump/runner.rb`
- `lib/dato/dump/dsl/*`
- `lib/dato/dump/operation/*`
- `lib/dato/dump/format/*`
- `spec/fixtures/config.rb` (example DSL usage)

What it does:
- `dato dump` loads all content, evaluates a Ruby config file, and writes files.
- DSL primitives:
  - `directory`
  - `create_data_file`
  - `create_post`
  - `add_to_data_file`
- Operations are collected then executed against filesystem output.
- Supports `--watch` mode via Pusher events + `listen` file watching.

How it fits:
- This is the main CLI use-case: generate static-site data from DatoCMS.

### 5) Upload workflow

Main files:
- `lib/dato/upload/create_upload_path.rb`
- `lib/dato/upload/file.rb`
- `lib/dato/site/client.rb` (`upload_file`, `upload_image`)

What it does:
- Accepts local file paths or HTTP URLs.
- Creates an upload request via API.
- Streams file bytes to returned signed URL.
- Creates Dato upload resource and returns field payload (`upload_id`, alt/title/custom_data).

How it fits:
- Supports item creation/update workflows in API usage and tests.

### 6) SEO/meta/favicons helpers

Main files:
- `lib/dato/utils/seo_tags_builder.rb`
- `lib/dato/utils/meta_tags/*.rb`
- `lib/dato/utils/favicon_tags_builder.rb`

What it does:
- Builds structured tag hashes for SEO and favicon metadata.
- Merges item SEO fields with global SEO fallback.

How it fits:
- Presentation convenience layer for SSR/static templates.

## Runtime flows

### API usage flow

1. Construct `Dato::Site::Client` or `Dato::Account::Client`.
2. First repo call triggers schema load.
3. Repo method maps to schema link relation (create/update/find/all/etc.).
4. Serializer/deserializer handles JSON:API transformation.
5. Caller receives indifferent-access hashes.

### Dump flow

1. `exe/dato` -> `Dato::Cli.dump`.
2. CLI creates `Site::Client` and `Local::Loader`.
3. Loader fetches site/items/uploads, builds `ItemsRepo`.
4. `Dump::Runner` evals dump config Ruby with `dato` bound to `ItemsRepo`.
5. DSL creates operation tree.
6. Operations write YAML/TOML/JSON/frontmatter/content files.

### Watch mode flow

1. `Loader#watch` subscribes to Pusher channels/events.
2. On event, fetches changed entities and mutates `EntitiesRepo`.
3. Rebuilds `ItemsRepo`.
4. Re-runs dump pipeline under mutex.

## Where complexity is concentrated

Your hunch is reasonable. The code works, but it stacks several dynamic layers:

- Heavy `method_missing` usage in both API repos and local item collections.
- `eval`/`instance_eval` based DSL execution for dump config.
- Multiple mutable caches (`EntitiesRepo` + `ItemsRepo`) rebuilt/updated live.
- Cross-cutting global state (`I18n.locale`, monkey patches in dump formatters).
- One gem mixing transport, domain model, CLI orchestration, and template helpers.

None of these are necessarily wrong alone, but together they raise cognitive load.

## If using this as a base for a new CMA manager

Most reusable pieces:
- `ApiClient` + `Repo` pattern (schema-driven endpoint surface).
- JSON:API serialization/deserialization helpers.
- Upload helper workflow.

Most likely to replace/simplify:
- `method_missing` interfaces (consider explicit typed clients).
- `eval` dump DSL (consider plain Ruby objects or declarative config).
- Global monkey patches and global locale dependence.
- Real-time watch/update behavior unless strictly needed.

## Test strategy snapshot

- `spec/dato/site/client_spec.rb`: broad CMA behavior (CRUD, bulk/batch ops, triggers, invitations).
- `spec/dato/local/*`: entity/item repo behavior and field-type parsing.
- `spec/dato/dump/*`: dump output behavior and SSG detection.
- VCR fixtures under `spec/fixtures/vcr_cassettes/*` keep network tests reproducible.
