-- ─────────────────────────────────────────────────────────────
-- OptiReg — Phase 5 Schema
-- Run in Supabase SQL Editor AFTER all previous schemas
-- ─────────────────────────────────────────────────────────────

-- ── Admin users table ────────────────────────────────────────
create table if not exists admin_users (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references profiles(id) on delete cascade,
  created_at  timestamptz not null default now(),
  unique(profile_id)
);

-- Only admins can read admin_users (service role only for write)
alter table admin_users enable row level security;
create policy "admin_users: authenticated read"
  on admin_users for select using (auth.role() = 'authenticated');

-- ── Insert yourself as admin (replace with your profile_id) ──
-- Run this separately after finding your profile_id:
-- INSERT INTO admin_users (profile_id) VALUES ('your-profile-id-here');

-- ── Product interactions (ML personalisation data) ────────────
create table if not exists product_interactions (
  id              uuid primary key default gen_random_uuid(),
  profile_id      uuid not null references profiles(id) on delete cascade,
  product_id      uuid not null references products(id) on delete cascade,
  interaction_type text not null check (interaction_type in ('viewed','compared','saved')),
  created_at      timestamptz not null default now()
);

create index if not exists idx_interactions_profile on product_interactions(profile_id);
create index if not exists idx_interactions_product on product_interactions(product_id);

alter table product_interactions enable row level security;
create policy "interactions: own read"
  on product_interactions for select using (auth.uid() = profile_id);
create policy "interactions: own insert"
  on product_interactions for insert with check (auth.uid() = profile_id);

-- ── Peer posts ────────────────────────────────────────────────
create table if not exists peer_posts (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references profiles(id) on delete cascade,
  title       text not null,
  content     text not null,
  category    text check (category in ('case_note','question','tip','discussion')),
  is_public   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_peer_posts_profile on peer_posts(profile_id);
create index if not exists idx_peer_posts_created on peer_posts(created_at desc);

alter table peer_posts enable row level security;
create policy "peer_posts: public read"
  on peer_posts for select using (is_public = true);
create policy "peer_posts: own write"
  on peer_posts for insert with check (auth.uid() = profile_id);
create policy "peer_posts: own update"
  on peer_posts for update using (auth.uid() = profile_id);
create policy "peer_posts: own delete"
  on peer_posts for delete using (auth.uid() = profile_id);

-- ── Peer follows ──────────────────────────────────────────────
create table if not exists peer_follows (
  id            uuid primary key default gen_random_uuid(),
  follower_id   uuid not null references profiles(id) on delete cascade,
  following_id  uuid not null references profiles(id) on delete cascade,
  created_at    timestamptz not null default now(),
  unique(follower_id, following_id),
  check (follower_id != following_id)
);

create index if not exists idx_follows_follower on peer_follows(follower_id);
create index if not exists idx_follows_following on peer_follows(following_id);

alter table peer_follows enable row level security;
create policy "follows: authenticated read"
  on peer_follows for select using (auth.role() = 'authenticated');
create policy "follows: own insert"
  on peer_follows for insert with check (auth.uid() = follower_id);
create policy "follows: own delete"
  on peer_follows for delete using (auth.uid() = follower_id);

-- ── Add regional_availability to products ────────────────────
alter table products
  add column if not exists regional_availability text[] default null,
  add column if not exists updated_at timestamptz default now();

-- Update products RLS to allow admin write
create policy "products: admin write"
  on products for all
  using (
    exists (select 1 from admin_users where profile_id = auth.uid())
  );
