---
name: nama-bi-dashboards
description: Build, fix or review a Nama BI dashboard (داشبورد, لوحة معلومات, KPI cards, charts, widgets, cross filters, "show me X as a dashboard"). A dashboard request means DashBoard + DashBoardWidget records inside the customer's Nama ERP, created through the Nama MCP or as an import file, never a local HTML page or artifact unless the user explicitly asks for one.
---

# Dashboards are built inside Nama, not as local pages

When a user asks for a "dashboard" — `داشبورد`, `لوحة معلومات`, "show me X as a dashboard" — they
mean a **Nama BI dashboard** (`DashBoard` + `DashBoardWidget` records) that the customer opens in
the ERP. **Do not** reach for the data, query it, and build a local HTML page, chart, or artifact.
That is not what was asked for, and it leaves the customer with nothing in their system.

Read `namaerp-docs/docs/public/skills/dashboard-designer.md` first and follow it. It lists which
BI reference page covers what — load only the pages the task needs. They are large
(`bi-module-technical-reference.md` is 106 KB, `bi-module-guide.md` 64 KB): list the headings with
`grep -n '^#' <page>` and read only the sections you need with `offset` / `limit`. Then:

- **A Nama MCP server is connected** → design and create the dashboard in that system through the
  MCP, using the dashboard tools (`AITDashboardTools`, added by the **Add Report Tools** button —
  see "Dashboard tools" in `ai-tool-definitions.md`):
  - `<prefix>PreviewDashboardWidget` — try a widget's SQL / chart configuration and read back the
    figures it would draw, without saving. Iterate here until the numbers are right.
  - `<prefix>RunDashboardWidget` — run a saved widget and see the SQL it actually executed (with
    cross filters and parameters applied); use it when a chart is empty or wrong.
  - `<prefix>RunDashboard` — run the whole dashboard (or one tab) to check every widget at once.
  - Save with `<prefix>ImportRecord` (schema from `<prefix>GetImportSchema` for `DashBoard` /
    `DashBoardWidget`) only once the preview figures are right. **Send `chartConfigJSON` as a JSON
    string** (stringified). The BI reference writes it as a nested object, but that works only in
    an import file; through ImportRecord a nested object is read as a reference and the widget
    saves without its chart configuration.

  If `AITDashboardTools` is not on the server, follow the missing-tool rule in the
  `nama-mcp-connection` skill (say so, and offer to add it via the import tools if those are
  connected) rather than saving widgets blind.
- **No Nama MCP server is connected** → produce a **ready-to-import JSON file** for the dashboard
  and its widgets, following the structure in the BI technical reference, and tell the user how to
  import it into Nama.
- **Nama is the default.** A plain "build a dashboard for X" means inside Nama — just do it. Only
  when the request genuinely points both ways (it mentions a local file, a browser page, a one-off
  look at the numbers) ask one direct question before doing any work: "Do you want this dashboard
  built inside Nama, or as a local page?"

A local HTML page or artifact is only right when the user explicitly asks for one.

When you need a table's columns, follow the entity-schema rule in CLAUDE.md: grep the fields you
need rather than reading a large entity file whole.
