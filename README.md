# DSH Cross-model Reasoning Adapter

An installable and removable DSH (DeepSeek Harness) bundle that exposes **per-model reasoning (thinking) levels** for GPT, Codex, Gemini and OpenAI-compatible models, so that models served through a custom gateway or relay can select a reasoning intensity that matches what the model actually supports.

The plugin does **not** patch Harness core files. Provider-native parameter conversion stays owned by the host's `dsh-llm-pi-ai`; this bundle only declares the model capabilities that let the host surface the reasoning-level picker in the first place.

## Why you need it

DSH only shows a reasoning-level control for a model if that model carries a `reasoning` / `reasoningEfforts` capability declaration. Models in the bundled catalog — official OpenAI GPT models, Gemini, and the like — already declare it, so you can pick a level out of the box when you use an official provider.

The problem is **custom gateways and relays**. A relay (pptoken, one-api, new-api, LiteLLM, a self-hosted proxy, …) exposes whatever model IDs its backend offers. Many of those IDs — vendor-specific versions, `-openai-compact` style aliases, date-stamped snapshots, `codex-*` tool models, and so on — are **missing from DSH's bundled catalog**. For any model the catalog does not describe, DSH defaults to "no reasoning capability", so the picker offers no reasoning level at all.

This plugin fills exactly that gap: it writes the missing `reasoningEfforts` declaration into your model settings, so those custom-gateway models become selectable too.

> Note: if you only use official providers with standard catalog IDs (e.g. `gpt-5.4`, `o3`) via DSH's built-in provider route, the reasoning levels already exist and this plugin is **unnecessary**. Its value is confined to models that fall outside the bundled catalog — which is what most relays expose.

## What it does

- Declares per-model reasoning levels: `off` / `minimal` / `low` / `medium` / `high` / `xhigh`.
- Writes a `reasoningEfforts` map into `~/.dsh/settings.yaml`, e.g.:
  ```yaml
  reasoningEfforts:
    off: null
    minimal: minimal
    low: low
    medium: medium
    high: high
    xhigh: xhigh
  ```
  Each entry maps a **logical level** (left) to the **provider-native wire value** (right) the host should send. `null` for `off` means "omit the parameter entirely"; `false` marks a model as non-reasoning.
- The host (`dsh-llm-pi-ai`) turns that declaration into the model picker's options and performs the actual wire-value conversion per request.
- Marks image models (`gpt-image-*`) as non-reasoning (`reasoningEfforts: false`).
- Adds a small "Reasoning adapter" settings section that explains the mapping. (This section is currently informational only — see Limitations.)

## Install

From npm once published:

```
dsh plugin add dsh-more-models-thinking-level
```

Or directly from this repository:

```
dsh plugin add https://github.com/Henta111/dsh-more-models-thinking-level
```

Installing from npm registers the bundle but does **not** automatically edit your model settings. Run the included helper once for the target profile, then restart DSH:

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.dsh\profiles\desktop\node_modules\dsh-more-models-thinking-level\enable-capabilities.ps1"
```

The helper does the following (it creates a timestamped backup first):

- `gpt-image-*` → `reasoningEfforts: false` (non-reasoning).
- `gemini-*` → `reasoningEfforts: { off: null, minimal, low, medium, high }`.
- **every other non-image model ID** — including `gpt-*`, `codex-*`, `claude-*`, `qwen-*`, `deepseek-*`, `moonshot-*` and arbitrary custom gateway IDs — → the full `off…xhigh` map.
- Existing `reasoningEfforts` declarations are left untouched (the helper only fills in models that have none).

## Remove

```
dsh plugin remove dsh-more-models-thinking-level
```

Then clean up the declarations the helper added (a `disable-capabilities.ps1` helper is included) if you want your settings file restored. See Limitations for why this cleanup is manual.

## Limitations

Please read these before installing — some materially affect whether you get the result you expect.

- **Not listed in the plugin marketplace.** The marketplace registry is generated from `awesome-dsh-plugin`; because the corresponding PR has not been merged/reviewed yet, this plugin is *not discoverable via `dsh plugin search`*. Install it by name (npm) or by repository URL, and confirm it is registered in your profile before use.

- **The helper is not invoked automatically.** Installing/enabling the plugin does not run `enable-capabilities.ps1`. You must run it manually once per profile, then restart DSH. Until you do, the plugin only adds the settings section and logs — your models will not gain reasoning levels.

- **The host entry is mostly a no-op.** `lib/index.js`'s `apply` only logs `reasoning-adapter: enabled`. All real capability comes from the declaration the helper writes into `settings.yaml`, not from plugin runtime code. Treat the "plugin" as an installer + documenter around a settings edit, not as a runtime adapter.

- **It persists edits to `settings.yaml`.** The helper rewrites your settings file in place (after a backup), so it is *not* a stateless runtime override. If you later change providers, switch protocols, or remove the plugin, the injected `reasoningEfforts` and the default `reasoning: medium` remain until you clean them up. Ownership of these fields is a manual concern.

- **Model capability is guessed from the ID.** The helper identifies models with a regex (exclude image models and Gemini, treat everything else as GPT-style). It cannot know whether a given model *actually* supports a level. If a relay exposes non-reasoning models (e.g. embeddings, vision-only, or plain chat models) under arbitrary IDs, they will receive a reasoning declaration too, and a strict gateway may reject the extra reasoning parameter.

- **Support ultimately depends on the gateway.** A declaration only makes the level *selectable*. Whether the relay actually accepts the `reasoning` / `reasoning_effort` parameter — and the specific wire value — is decided by the gateway. Some strict gateways validate requests against a fixed schema and reject fields they do not recognize. The plugin cannot guarantee a chosen level actually takes effect on a given relay.

- **Windows PowerShell + `desktop` profile only.** The helpers use Windows PowerShell syntax and path conventions, and default to the `desktop` profile. Non-Windows hosts or other profile names require manual adaptation.

- **The settings section is informational, not an editor.** The client section explains the mapping and points at the model settings page; it has no provider/model visual editor. Fine-grained per-provider or per-model control is done by editing `settings.yaml` yourself.

- **Unfinished marketplace-readiness work.** Configurable profile names, migrating capability config to the DSH Settings API, automated tests for GPT/Gemini/generic models, explicit error text when a gateway refuses a parameter, and removing the dependency on an early core-runtime patch are all still open.


## Gateway compatibility

This plugin only declares model capability; the actual request is sent by the host (`dsh-llm-pi-ai`) using the route's `api`. When a route uses `openai-responses`, DSH replays prior assistant messages as different `input` items, and the message items it builds carry a `status` field (e.g. `status: "completed"`), and reasoning items can carry `status` too.

Some relays validate the Responses API request against a fixed schema and reject such fields as unknown parameters. A typical error looks like:

```
invalid_request_error: [ObjectParam] [input[148].status] [unknown_parameter] Unknown parameter: 'input[148].status'
```

If you hit this, it is a host/route-vs-gateway compatibility issue, not the plugin's fault. Options, in order of usefulness:

- Switch the route's `api` to `openai-completions` (chat/completions) if the relay supports `/v1/chat/completions`; that request shape does not carry these item-level fields. Note the reasoning wire format changes, so re-confirm the levels still map correctly.
- Upgrade or relax the gateway (a stale relay build that rejects `status` on Responses input items has been fixed upstream, e.g. in LiteLLM).
- As a workaround, start a fresh session / keep history short so the offending item is not replayed.

## FAQ / Troubleshooting

- **Installed from npm but my models still show no reasoning level.** The npm install only registers the bundle. Run `enable-capabilities.ps1` for the target profile, then restart DSH.
- **I picked a level and now get `invalid_request_error ... input[N].status`.** See Gateway compatibility above — it is a route/gateway field-compatibility issue, not the level mapping.
- **Why do my relay GPT models have no reasoning level at all?** Models whose IDs are not in DSH's bundled catalog default to "no reasoning"; the helper adds the missing `reasoningEfforts` declaration. See "Why you need it".
- **The default reasoning level is `medium`; how do I change it?** Edit the provider's `reasoning:` field in `~/.dsh/settings.yaml` (the helper sets it to `medium`, and it persists even after uninstall).
- **I uninstalled but `reasoningEfforts` / `reasoning: medium` are still there.** The helper edits `settings.yaml` in place. Run `disable-capabilities.ps1` to remove the declarations the helper added.
- **When is this plugin unnecessary?** When you use an official provider with standard catalog IDs (e.g. `gpt-5.4`, `o3`); those already declare reasoning.

## Advanced: hand-tuning reasoningEfforts

The level picker is driven entirely by the model's `reasoningEfforts`. You can edit `~/.dsh/settings.yaml` directly, e.g.:

```yaml
reasoningEfforts:
  off: null
  low: "low"
  medium: "medium"
  high: "high"
```

Each key is the logical level the picker shows; each value is the wire value the host sends for that level. `null` for `off` means "omit the reasoning parameter", `false` disables reasoning for that model. A model with an empty/absent `reasoningEfforts` keeps the host's default (which for a custom-gateway model is "no reasoning"), so if you add a new relay model by hand, give it a `reasoningEfforts` map as above or it will not be selectable.
## License

MIT