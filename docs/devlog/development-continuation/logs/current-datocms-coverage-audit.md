# Current DatoCMS coverage audit


## Goals

* Map the dynamic account and site clients against current DatoCMS API resources.
* Inventory explicitly implemented field types, transformations, dump formats, utilities and CLI behaviour.
* Separate generic hyperschema-driven support from behaviour that depends on local Ruby implementations.
* Record supported, partial and unsupported behaviour with evidence, impact, suggested tests and priority.


## Completion criteria

Complete.

* A durable report covers API resources, local content handling and CLI behaviour.
* Findings distinguish missing support, stale assumptions and weak or cassette-only coverage.
* Findings are prioritised without implementing fixes during the audit.
* One bounded general-development issue can be selected without repeating discovery.


## Baseline and method

This is a read-only comparison made on 2 September 2026. It uses the current official [Content Management API overview](https://www.datocms.com/docs/content-management-api), [API versioning policy](https://www.datocms.com/docs/content-management-api/api-versioning), [Site API hyperschema](https://site-api.datocms.com/docs/site-api-hyperschema.json), [Account API hyperschema](https://account-api.datocms.com/docs/account-api-hyperschema.json), [field reference](https://www.datocms.com/docs/content-management-api/resources/field), [record reference](https://www.datocms.com/docs/content-management-api/resources/item), [upload reference](https://www.datocms.com/docs/content-management-api/resources/upload), and [DAST reference](https://www.datocms.com/docs/structured-text/dast).

The two live hyperschemas were downloaded and counted, but no customer content was read and no remote state was changed. Existing VCR cassettes provide historical integration evidence; they do not prove that a relation remains in today's live schema.


## Executive result

The core client design remains viable. It requests API version 3 and builds resources and operations dynamically from DatoCMS's current machine-readable hyperschemas. This gives generic reach across all 47 current Site API resources and all 26 current Account API resources without requiring a handwritten Ruby class for each endpoint.

That breadth should not be confused with verified behaviour. Direct integration coverage exercises a small subset of resources, and the local dump model contains explicit transformations which can omit current data. The most immediate confirmed loss is in SEO values: `twitter_card` is parsed but omitted from `to_hash`, while current `no_index` is neither parsed nor exported. Structured Text inline blocks and asset poster times are also incomplete.

The recommended first general-development change is **F1: preserve all current SEO field properties in local values and dumps**. It is bounded, directly affects exported content, needs no live mutation, and can be locked down with unit tests on both supported Ruby runtimes.


## API surface

### Site API

The current Site API hyperschema exposes 47 resource definitions with 202 operations: 76 `GET`, 52 `POST`, 44 `PUT`, and 30 `DELETE` operations.

Resources found:

`access_token`, `audit_log_event`, `build_event`, `build_trigger`, `daily_usage`, `editing_session`, `emoji_suggestions`, `environment`, `field`, `fieldset`, `item`, `item_type`, `item_type_filter`, `item_version`, `job_result`, `maintenance_mode`, `menu_item`, `plugin`, `public_info`, `role`, `scheduled_publication`, `scheduled_unpublishing`, `schema_menu_item`, `search_index`, `search_index_event`, `search_result`, `session`, `site`, `site_invitation`, `sso_group`, `sso_settings`, `sso_user`, `subscription_feature`, `subscription_limit`, `upload`, `upload_collection`, `upload_filter`, `upload_request`, `upload_smart_tag`, `upload_tag`, `upload_track`, `user`, `usage_counter`, `webhook`, `webhook_call`, `white_label_settings`, and `workflow`.

Explicit integration specs cover menu items, item types, fields, items, build triggers, site invitations, site data and upload helpers. Bulk item actions have cassette coverage. Most current resources rely solely on the shared dynamic machinery.

### Account API

The current Account API hyperschema exposes 26 resource definitions with 95 operations: 33 `GET`, 30 `POST`, 24 `PUT`, and 8 `DELETE` operations.

Resources found:

`account`, `daily_usage`, `invoice`, `job_result`, `oauth_application`, `organization`, `organization_invitation`, `organization_mandate`, `organization_mandate_request`, `organization_membership`, `organization_role`, `payment_intent`, `per_owner_pricing_billing_profile`, `per_owner_pricing_plan`, `per_owner_pricing_subscription`, `per_site_pricing_billing_profile`, `resource_usage`, `session`, `site`, `site_invitation`, `site_plan`, `site_subscription`, `site_transfer`, `subscription_feature`, `subscription_limit`, and `tfa_deactivate_request`.

Explicit integration specs cover account find/update and site create/read/update/delete. The remaining current resources rely solely on the shared dynamic machinery.

### Generic transport status

| Capability | Status | Evidence and limits |
| --- | --- | --- |
| Current resource discovery | Supported | `ApiClient#json_schema` fetches and expands the official hyperschema at runtime; `method_missing` exposes every resource definition. |
| Current relation discovery | Supported generically | `Repo#method_missing` maps `instances` to `all`, `self` to `find`, and exposes other relation names verbatim. |
| API version and environments | Supported | Requests send `X-Api-Version: 3` and optionally `X-Environment`. |
| JSON:API payloads | Supported generically | Shared serializer and deserializer operate from the relation schemas. Only a narrow serializer case has a direct unit test; the deserializer has no dedicated unit spec. |
| Pagination | Partially verified | `all_pages: true` fetches pages of 100 using `meta.total_count`. There is no focused pagination spec or dump acceptance case above 100 records. |
| Asynchronous jobs | Supported, operationally fragile | Job responses are polled through `job_result`, but polling has no deadline and repeated 404 responses can wait forever. DatoCMS's version policy permits synchronous operations to become asynchronous within API version 3. |
| Rate and batch-validation retries | Supported, operationally fragile | 429 and validation-in-progress responses retry recursively, without a maximum attempt count or deadline. |


## Local content and dump coverage

The current field reference lists 19 field types. The repository has an explicit local parser for all 19: `boolean`, `color`, `date`, `date_time`, `file`, `float`, `gallery`, `integer`, `json`, `lat_lon`, `link`, `links`, `rich_text`, `seo`, `single_block`, `slug`, `string`, `structured_text`, and `text`. It also has internal helpers for site/global SEO, theme values and upload identifiers.

| Content area | Status | Evidence and limits |
| --- | --- | --- |
| Scalar fields | Supported | Boolean, numeric, string, text, slug, date, date-time, JSON, colour and latitude/longitude parsers exist. Date values become `Date`; date-times become UTC `Time`; JSON strings are decoded. |
| Record references | Supported with depth limits | Link, links, rich text blocks and single blocks resolve through the local item repository. `to_hash` obeys the existing maximum-depth behaviour. |
| Structured Text links and block nodes | Partially supported | `block`, `inlineItem`, and `itemLink` records are resolved. Current DAST `inlineBlock` nodes remain in the raw document but are omitted from the convenience `blocks` collection and its expanded `to_hash` output. |
| SEO fields | Partially supported with confirmed loss | Title, description, image and `twitter_card` are parsed, but `to_hash` omits `twitter_card`. Current `no_index` is not parsed or exported. |
| File and gallery fields | Partially supported | Core upload metadata, default alt/title/custom data, focal points, Imgix URLs, hashes and Mux values are handled. Current per-field/default `poster_time` is not represented; several upload-level attributes are readable only indirectly or absent from `to_hash`. |
| Site metadata | Partially supported by design | The local site projection exports a presentation-focused subset rather than every current Site API attribute. This is acceptable only if the dump contract remains content-oriented rather than a lossless site backup. |
| Dump formats | Supported | JSON, YAML, TOML and the Ruby configuration-driven directory output remain implemented. Their fidelity is limited by the local projections above. |

Direct field-type unit specs cover colour, file, latitude/longitude, SEO, upload identifiers and video. Most scalar/reference parsers and Structured Text have no focused unit spec, although some paths are exercised through integration cassettes.


## CLI and live-update coverage

| Behaviour | Status | Evidence and limits |
| --- | --- | --- |
| `dato dump` | Supported with narrow tests | The command builds the local loader and dump runner. Its only direct CLI spec asserts a dump using `--token`. |
| Token and configuration options | Partially verified | `--config`, `--token`, `--token-var`, `--environment`, `--preview`, and `--watch` are implemented but are not individually specified. |
| `dato check` | Partially supported | It checks for a token and can append one to `.env`; there are no direct tests and it does not validate the token remotely. |
| Preview versions | Supported by current evidence | The loader requests `latest` for preview and `published` otherwise. Recent live cassettes confirm `latest`; current item-list documentation still describes current/published version selection. |
| Watch mode | Legacy and unverified | The implementation uses a fixed Pusher application key plus `/pusher/authenticate` and hand-built event names. Current official real-time documentation describes GraphQL Server-Sent Events at `graphql-listen.datocms.com`. The CLI spec's “in watch mode” context does not pass `--watch`, so this path has no effective test. |

The current official [real-time updates reference](https://www.datocms.com/docs/real-time-updates-api/api-reference) and [query-listening guide](https://www.datocms.com/docs/real-time-updates-api/listening-to-queries) cover the public SSE interface. This does not by itself prove that the older private Pusher path has stopped working, so focused live verification is required before choosing removal or migration.


## Prioritised findings

### F1 — SEO dump drops current values

Priority: High. Recommended for Stage 4.

Evidence: `FieldType::Seo` accepts `twitter_card` but excludes it from `to_hash`; it has no `no_index` reader or parser input. The current record reference includes both properties in SEO values. The existing SEO spec checks only title, description and image.

User impact: JSON, YAML, TOML and directory consumers can receive incomplete SEO configuration even though the API supplied it.

Suggested tests: extend the SEO unit fixture with `twitter_card` and `no_index`; assert readers and exact `to_hash` output; include `nil` handling. Then run the complete suite on Ruby 2.7.5 and Ruby 3.3.

### F2 — Structured Text inline blocks are not expanded

Priority: High.

Evidence: current DAST defines `inlineBlock`; `StructuredText#blocks` searches only for `block`. The raw DAST value survives, but `blocks` and its expanded dump projection omit inline block records.

User impact: consumers using the convenience block collection or expanded dump data cannot discover all embedded records.

Suggested tests: add a DAST fixture containing block, inlineBlock, inlineItem and itemLink nodes; assert record resolution, uniqueness and serialised collections.

### F3 — Watch mode depends on an undocumented legacy transport

Priority: High, pending live verification.

Evidence: the implementation uses Pusher and `/pusher/authenticate`; current public documentation describes GraphQL SSE. No test invokes `--watch`.

User impact: a documented CLI option may fail, authenticate incorrectly or stop receiving changes without a regression signal.

Suggested tests: first perform a short, read-only watch against the disposable project and capture the authentication/event behaviour. Add transport-boundary tests before deciding whether compatibility can be retained or the feature must be redesigned around current public APIs.

### F4 — Legacy batch item relations are stale against the current schema

Priority: Medium–high.

Evidence: cassettes and specs cover `batch_publish` and `batch_destroy`, while the current hyperschema exposes `bulk_publish`, `bulk_unpublish`, and `bulk_destroy` and does not expose those legacy relation names. The dynamic client can only offer relations in the schema it fetched.

User impact: cassette-only green tests can imply that methods are callable when a fresh client will raise `NoMethodError`.

Suggested tests: load a current schema fixture and assert the exact supported bulk relation names. Retain old cassette tests only if an explicit compatibility implementation exists independently of the live schema.

### F5 — File values omit poster time and other exportable metadata

Priority: Medium.

Evidence: current file values and upload default metadata include `poster_time`; the local parser and `to_hash` do not. Upload resources now carry additional metadata not represented in the local projection.

User impact: video thumbnail timing and some asset metadata are lost from dumps.

Suggested tests: add per-field and localised-default poster-time cases, establish which upload attributes are part of the promised dump contract, and test that contract explicitly.

### F6 — Dynamic breadth lacks transport-level regression coverage

Priority: Medium.

Evidence: most of the 73 current resources rely entirely on shared dynamic code. `ApiClient`, `JsonApiDeserializer`, and `Paginator` have no dedicated unit specs; account integration coverage is limited to accounts and sites.

User impact: a shared schema, deserialisation or pagination regression can affect many endpoints while the suite remains green.

Suggested tests: use small local schema fixtures to cover namespace derivation, relation dispatch, identities, raw responses, deserialisation, and multi-page aggregation without multiplying live cassettes.

### F7 — Polling and retry loops have no deadline

Priority: Medium.

Evidence: job-result 404s, rate limits and batch-validation-in-progress responses repeat without maximum attempts or elapsed-time limits.

User impact: commands and automation can hang indefinitely during an API or network fault.

Suggested tests: inject deterministic response sequences and a sleeper; specify success, terminal failure and timeout behaviour without real waits.

### F8 — CLI options and token setup are weakly specified

Priority: Medium–low.

Evidence: one direct CLI example covers only `dump --token`; `check`, environment selection, preview, token-variable lookup, configuration selection and actual watch activation lack focused examples.

User impact: option parsing and setup regressions can reach users despite a passing suite.

Suggested tests: exercise each option at the command boundary with injected clients and runners, including missing-token errors and `.env` writes in a temporary directory.

### F9 — Full-dump pagination has no acceptance case

Priority: Medium–low.

Evidence: the paginator's page size of 100 is safe for standard item listing, but no focused test proves correct offsets and aggregation above 100 records.

User impact: an unnoticed pagination regression would silently make large dumps incomplete.

Suggested tests: simulate totals at 0, 100, 101 and multiple pages, preserving filters while asserting offsets and combined ordering.


## Supported, partial and outside-scope summary

Supported:

* API version 3 headers, environment selection and runtime hyperschema discovery.
* Generic resource/relation dispatch for current `GET`, `POST`, `PUT`, and `DELETE` links.
* Parsers for every currently documented field type.
* Core record linking, asset handling, pagination, async-job handling and all existing dump formats.

Partial or weakly verified:

* Per-resource API behaviour beyond the small integration subset.
* SEO, Structured Text inline blocks, file poster times and the broader asset/site dump projection.
* Async failure boundaries, CLI option behaviour and large-dataset pagination.
* Watch mode against the current service.

Outside the maintained client's current contract:

* The Content Delivery API and its GraphQL query features. This project deliberately uses the Content Management API to build local content exports.
* A lossless backup/restore representation of all project settings. The existing dump model is a content-consumption projection.


## Stage 4 selection

Select F1: preserve `twitter_card` and `no_index` in `Dato::Local::FieldType::Seo` and its serialised hash.

Keep this change limited to the current SEO value contract, its focused regression spec, the changelog and continuation hand-off. Do not combine it with Structured Text, asset projection or general transport refactoring.


## Status

Complete. The audit required no live project access and made no API or content changes.
