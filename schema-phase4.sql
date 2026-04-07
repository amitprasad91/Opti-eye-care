-- ─────────────────────────────────────────────────────────────
-- OptiReg — Phase 4 Schema
-- Run in Supabase SQL Editor AFTER schema.sql and schema-phase3.sql
-- ─────────────────────────────────────────────────────────────

-- ── Table: brand_preferences ─────────────────────────────────
create table if not exists brand_preferences (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references profiles(id) on delete cascade,
  brand_name  text not null,
  created_at  timestamptz not null default now(),
  unique(profile_id, brand_name)
);

create index if not exists idx_brand_prefs_profile on brand_preferences(profile_id);

alter table brand_preferences enable row level security;

create policy "brand_prefs: own read"
  on brand_preferences for select using (auth.uid() = profile_id);
create policy "brand_prefs: own insert"
  on brand_preferences for insert with check (auth.uid() = profile_id);
create policy "brand_prefs: own delete"
  on brand_preferences for delete using (auth.uid() = profile_id);

-- ── Table: rx_templates ──────────────────────────────────────
create table if not exists rx_templates (
  id            uuid primary key default gen_random_uuid(),
  profile_id    uuid not null references profiles(id) on delete cascade,
  template_name text not null,
  od_sphere     numeric(5,2),
  od_cylinder   numeric(5,2),
  od_axis       integer,
  od_add        numeric(4,2),
  os_sphere     numeric(5,2),
  os_cylinder   numeric(5,2),
  os_axis       integer,
  os_add        numeric(4,2),
  rx_type       text,
  notes         text,
  created_at    timestamptz not null default now(),
  unique(profile_id, template_name)
);

create index if not exists idx_rx_templates_profile on rx_templates(profile_id);

alter table rx_templates enable row level security;

create policy "rx_templates: own read"
  on rx_templates for select using (auth.uid() = profile_id);
create policy "rx_templates: own insert"
  on rx_templates for insert with check (auth.uid() = profile_id);
create policy "rx_templates: own delete"
  on rx_templates for delete using (auth.uid() = profile_id);
