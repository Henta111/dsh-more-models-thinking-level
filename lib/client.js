window.__ModuleLoader__.load({
  id: "dsh-more-models-thinking-level",
  factory: (require) => {
    const module = { exports: {} };
    const exports = module.exports;
    const { jsx } = require("react/jsx-runtime");
    function ReasoningAdapterSection({ t }) {
      return jsx("section", {
        style: { display: "flex", flexDirection: "column", gap: "10px", maxWidth: "720px" },
        children: [
          jsx("h2", { children: t("title") }),
          jsx("p", { children: t("body") }),
          jsx("pre", { style: { whiteSpace: "pre-wrap", padding: "12px", border: "1px solid var(--dsw-alias-border-l2)", borderRadius: "8px" }, children: t("example") })
        ]
      });
    }
    const inject = ["locale", "slots"];
    function apply(ctx) {
      ctx.effect(() => ctx.locale.register("reasoning-adapter", {
        zh: { nav: "推理适配", title: "跨模型推理等级", body: "推理等级由每个模型自己的 reasoningEfforts 声明决定。模型设置页支持编辑该字段，插件卸载后不会影响已有模型配置。", example: "low=low,medium=medium,high=high" },
        en: { nav: "Reasoning adapter", title: "Cross-model reasoning efforts", body: "Reasoning levels are declared per model through reasoningEfforts.", example: "low=low,medium=medium,high=high" }
      }));
      const t = ctx.locale.bind("reasoning-adapter");
      ctx.slots.inject("settings.section", () => ctx.slots.register({ name: "settings.section", id: "reasoning-adapter", order: 35, label: () => t("nav"), inject: () => ({ t }) }, ReasoningAdapterSection));
    }
    exports.apply = apply;
    exports.inject = inject;
    return module.exports;
  }
});
