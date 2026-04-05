-- ─────────────────────────────────────────────────────────────
-- OptiReg — Phase 3 Schema
-- Run this in Supabase SQL Editor AFTER schema.sql (Phase 2)
-- ─────────────────────────────────────────────────────────────

-- ── Table: prescriptions ─────────────────────────────────────
create table if not exists prescriptions (
  id            uuid primary key default gen_random_uuid(),
  profile_id    uuid not null references profiles(id) on delete cascade,
  patient_name  text,
  patient_age   integer check (patient_age > 0 and patient_age < 120),
  patient_gender text check (patient_gender in ('male','female','other')),
  -- Right eye (OD)
  od_sphere     numeric(5,2),
  od_cylinder   numeric(5,2),
  od_axis       integer check (od_axis >= 0 and od_axis <= 180),
  od_add        numeric(4,2),
  -- Left eye (OS)
  os_sphere     numeric(5,2),
  os_cylinder   numeric(5,2),
  os_axis       integer check (os_axis >= 0 and os_axis <= 180),
  os_add        numeric(4,2),
  -- Detected type
  rx_type       text check (rx_type in ('myopia','hyperopia','astigmatism','presbyopia','compound','plano')),
  notes         text,
  created_at    timestamptz not null default now()
);

create index if not exists idx_prescriptions_profile_id on prescriptions(profile_id);
create index if not exists idx_prescriptions_created_at on prescriptions(profile_id, created_at desc);

alter table prescriptions enable row level security;

create policy "prescriptions: own read"
  on prescriptions for select using (auth.uid() = profile_id);
create policy "prescriptions: own insert"
  on prescriptions for insert with check (auth.uid() = profile_id);
create policy "prescriptions: own update"
  on prescriptions for update using (auth.uid() = profile_id);
create policy "prescriptions: own delete"
  on prescriptions for delete using (auth.uid() = profile_id);

-- ── Table: products ──────────────────────────────────────────
create table if not exists products (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  brand         text not null,
  lens_index    numeric(4,2) not null,
  lens_type     text not null check (lens_type in ('sv','bifocal','progressive')),
  coating       text not null,
  sphere_min    numeric(5,2) not null,
  sphere_max    numeric(5,2) not null,
  cylinder_max  numeric(4,2) not null default 0,
  add_min       numeric(4,2),
  add_max       numeric(4,2),
  price_min     integer not null,
  price_max     integer not null,
  tier          text not null check (tier in ('premium','mid','basic')),
  in_stock      boolean not null default true,
  description   text,
  created_at    timestamptz not null default now()
);

-- Products are readable by all authenticated users
alter table products enable row level security;
create policy "products: authenticated read"
  on products for select using (auth.role() = 'authenticated');

-- ── Seed: 30 product SKUs ────────────────────────────────────
insert into products (name, brand, lens_index, lens_type, coating, sphere_min, sphere_max, cylinder_max, add_min, add_max, price_min, price_max, tier, in_stock, description) values

-- ── BASIC TIER — Single Vision ──────────────────────────────
('ClearView 1.50 SV','Rodenstock',1.50,'sv','ar',-6.00,4.00,2.00,null,null,800,1200,'basic',true,'Standard single vision with basic AR coating'),
('EasyLens 1.50 SV','Hoya',1.50,'sv','uv',-6.00,4.00,2.00,null,null,700,1000,'basic',true,'Entry level UV protection single vision'),
('BasicPlus 1.56 SV','Shamir',1.56,'sv','ar',-8.00,5.00,2.50,null,null,900,1400,'basic',true,'Thinner than 1.50, good value'),
('IndoLens 1.56 SV','Indo',1.56,'sv','ar',-8.00,5.00,2.50,null,null,850,1300,'basic',true,'Single vision for moderate prescriptions'),
('SafeBlue 1.56 SV','Rodenstock',1.56,'sv','blue-cut',-8.00,5.00,2.50,null,null,1100,1600,'basic',true,'Blue light protection for screen users'),

-- ── BASIC TIER — Bifocal ────────────────────────────────────
('ReadEasy Bifocal','Hoya',1.50,'bifocal','ar',-6.00,4.00,2.00,1.00,3.00,1200,1800,'basic',true,'Traditional bifocal for early presbyopia'),
('ComfortBi 1.56','Indo',1.56,'bifocal','ar',-8.00,5.00,2.00,1.00,3.00,1400,2000,'basic',true,'Thinner bifocal option'),

-- ── MID TIER — Single Vision ────────────────────────────────
('Nikon SeeMax 1.60','Nikon',1.60,'sv','ar',-10.00,6.00,3.00,null,null,2000,3000,'mid',true,'High clarity single vision, 1.60 index'),
('Hoya Hilux 1.60','Hoya',1.60,'sv','ar',-10.00,6.00,3.00,null,null,2200,3200,'mid',true,'Premium clarity with Hilux hard coat'),
('Zeiss Single Vision 1.60','Zeiss',1.60,'sv','ar',-10.00,6.00,3.00,null,null,2500,3500,'mid',true,'Zeiss quality at mid price point'),
('Essilor Orma 1.60','Essilor',1.60,'sv','ar',-10.00,6.00,3.00,null,null,2300,3300,'mid',true,'Reliable Essilor single vision'),
('BlueGuard 1.60 SV','Hoya',1.60,'sv','blue-cut',-10.00,6.00,3.00,null,null,2600,3600,'mid',true,'Blue light filtering, ideal for digital workers'),
('PhotoFlex 1.60','Rodenstock',1.60,'sv','photochromic',-10.00,6.00,3.00,null,null,3000,4200,'mid',true,'Photochromic transitions, darkens in sunlight'),

-- ── MID TIER — High Cylinder ────────────────────────────────
('AstigmaPlus 1.60','Nikon',1.60,'sv','ar',-8.00,5.00,4.00,null,null,2400,3400,'mid',true,'Optimised for high astigmatism up to cyl -4.00'),
('CylControl 1.60','Hoya',1.60,'sv','ar',-8.00,5.00,4.00,null,null,2600,3600,'mid',true,'Superior edge clarity for high cylinder'),

-- ── MID TIER — Progressive ──────────────────────────────────
('Nikon Progressive 1.60','Nikon',1.60,'progressive','ar',-8.00,5.00,2.00,1.00,3.50,4500,6500,'mid',true,'Wide corridor progressive for presbyopia'),
('Hoya Amplitude 1.60','Hoya',1.60,'progressive','ar',-8.00,5.00,2.00,1.00,3.50,5000,7000,'mid',true,'Natural vision zones for reading and distance'),
('Essilor Varilux Liberty','Essilor',1.60,'progressive','ar',-8.00,5.00,2.00,1.00,3.50,5500,7500,'mid',true,'Varilux comfort with wide near zone'),
('Rodenstock Progressive 1.60','Rodenstock',1.60,'progressive','ar',-8.00,5.00,2.00,1.00,3.50,4800,6800,'mid',true,'Individual fitting progressive'),

-- ── PREMIUM TIER — Single Vision ────────────────────────────
('Zeiss Single Vision 1.67','Zeiss',1.67,'sv','ar',-12.00,8.00,4.00,null,null,4500,6000,'premium',true,'Ultra-thin 1.67 for strong prescriptions'),
('Essilor Airwear 1.67','Essilor',1.67,'sv','ar',-12.00,8.00,4.00,null,null,4200,5800,'premium',true,'Polycarbonate 1.67, impact resistant'),
('Hoya Nulux 1.67','Hoya',1.67,'sv','ar',-12.00,8.00,4.00,null,null,4000,5500,'premium',true,'Aspheric design for reduced distortion'),
('Rodenstock Perfalit 1.67','Rodenstock',1.67,'sv','ar',-12.00,8.00,4.00,null,null,4800,6500,'premium',true,'Individual freeform single vision'),

-- ── PREMIUM TIER — Ultra High Index ─────────────────────────
('Zeiss Ultra 1.74','Zeiss',1.74,'sv','ar',-20.00,10.00,4.00,null,null,8000,12000,'premium',true,'Thinnest possible — for very high myopia'),
('Hoya Eynoa 1.74','Hoya',1.74,'sv','ar',-20.00,10.00,4.00,null,null,7500,11000,'premium',true,'1.74 index for extreme prescriptions'),
('Essilor Stylis 1.74','Essilor',1.74,'sv','ar',-20.00,10.00,4.00,null,null,7000,10500,'premium',true,'Ultra-thin Essilor for strong myopia'),

-- ── PREMIUM TIER — Progressive ──────────────────────────────
('Zeiss Precision Progressive 1.67','Zeiss',1.67,'progressive','ar',-10.00,6.00,3.00,1.00,3.50,9000,13000,'premium',true,'Freeform progressive — widest vision zones'),
('Essilor Varilux X Series 1.67','Essilor',1.67,'progressive','ar',-10.00,6.00,3.00,1.00,3.50,10000,14000,'premium',true,'Varilux X — instant focus at any distance'),
('Hoya ID LifeStyle 1.67','Hoya',1.67,'progressive','ar',-10.00,6.00,3.00,1.00,3.50,8500,12500,'premium',true,'Customised to individual visual habits'),

-- ── PREMIUM TIER — Photochromic Progressive ─────────────────
('Zeiss PhotoFusion Progressive','Zeiss',1.60,'progressive','photochromic',-8.00,5.00,2.00,1.00,3.50,12000,16000,'premium',true,'Best-in-class photochromic progressive'),
('Essilor Varilux Transitions','Essilor',1.60,'progressive','photochromic',-8.00,5.00,2.00,1.00,3.50,11000,15000,'premium',true,'Varilux comfort with Transitions lens')

on conflict do nothing;
