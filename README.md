# DSH Cross-model Reasoning Adapter

Installable and removable DSH bundle. Provider-native parameter conversion remains owned by the host's `dsh-llm-pi-ai`.

The plugin exposes per-model reasoning levels (`off` / `minimal` / `low` / `medium` / `high` / `xhigh`) for GPT, Codex, Gemini and OpenAI-compatible models in DeepSeek Harness, so your custom gateway can select a reasoning intensity that matches the model.

## Install (plugin market)

Once published to npm:

```
dsh plugin add dsh-more-models-thinking-level
```

Or from this repository directly:

```
dsh plugin add https://github.com/Henta111/dsh-more-models-thinking-level
```

## Remove

```
dsh plugin remove dsh-more-models-thinking-level
```

## How it works

- The bundle layer registers the plugin into the profile's `dsh.profile.bundles`.
- The web client adds a settings section (`推理适配 / Reasoning adapter`).
- Provider-native wire values are declared per model via `reasoningEfforts`; the host (`dsh-llm-pi-ai`) performs the actual conversion.

## License

MIT
