-- ─────────────────────────────────────────────
-- OptiReg — Phase 2 Database Schema
-- Run this once in your Supabase SQL editor
-- ─────────────────────────────────────────────

-- Enable UUID generation
create extension if not exists "pgcrypto";

-- ── Table 1: profiles ──────────────────────────
create table if not exists profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  first_name    text not null,
  last_name     text not null,
  email         text not null unique,
  mobile        text not null unique,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ── Table 2: professional_details ──────────────
create table if not exists professional_details (
  id                uuid primary key default gen_random_uuid(),
  profile_id        uuid not null references profiles(id) on delete cascade,
  role_type         text not null check (role_type in ('student', 'professional')),
  specialisation    text,
  qualification     text,
  experience_years  integer check (experience_years >= 0 and experience_years <= 60),
  created_at        timestamptz not null default now()
);

-- ── Table 3: practice_info ─────────────────────
create table if not exists practice_info (
  id                  uuid primary key default gen_random_uuid(),
  profile_id          uuid not null references profiles(id) on delete cascade,
  practice_type       text check (practice_type in ('hospital', 'clinic', 'optical', 'academic', 'other')),
  daily_patient_load  text check (daily_patient_load in ('lt10', '10-30', '30-50', 'gt50')),
  organisation_name   text,
  city                text,
  state               text,
  pin_code            text check (pin_code ~ '^\d{6}$'),
  created_at          timestamptz not null default now()
);

-- ── Indexes ────────────────────────────────────
create index if not exists idx_professional_details_profile_id on professional_details(profile_id);
create index if not exists idx_practice_info_profile_id on practice_info(profile_id);
create index if not exists idx_profiles_email on profiles(email);

-- ── Updated_at trigger ─────────────────────────
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_profiles_updated_at on profiles;
create trigger trg_profiles_updated_at
  before update on profiles
  for each row execute function update_updated_at();

-- ── Row Level Security ─────────────────────────
alter table profiles             enable row level security;
alter table professional_details enable row level security;
alter table practice_info        enable row level security;

-- profiles: users can only read and write their own row
create policy "profiles: own read"
  on profiles for select
  using (auth.uid() = id);

create policy "profiles: own insert"
  on profiles for insert
  with check (auth.uid() = id);

create policy "profiles: own update"
  on profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- professional_details: own rows only
create policy "prof_details: own read"
  on professional_details for select
  using (auth.uid() = profile_id);

create policy "prof_details: own insert"
  on professional_details for insert
  with check (auth.uid() = profile_id);

create policy "prof_details: own update"
  on professional_details for update
  using (auth.uid() = profile_id);

-- practice_info: own rows only
create policy "practice_info: own read"
  on practice_info for select
  using (auth.uid() = profile_id);

create policy "practice_info: own insert"
  on practice_info for insert
  with check (auth.uid() = profile_id);

create policy "practice_info: own update"
  on practice_info for update
  using (auth.uid() = profile_id);
