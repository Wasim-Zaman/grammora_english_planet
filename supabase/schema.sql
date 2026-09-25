-- ============================================================================
-- GEP App - Supabase schema
-- Tables required by lib/services/**, matching the row shapes each service
-- reads/writes. Run this once against a fresh project (SQL Editor or
-- `supabase db execute -f supabase/schema.sql`).
-- ============================================================================

create extension if not exists pgcrypto;

-- ----------------------------------------------------------------------------
-- about_me  (singleton row, id = 'admin')
-- used by: services/about_me/about_me_service.dart
-- ----------------------------------------------------------------------------
create table if not exists public.about_me (
  id text primary key default 'admin',
  profile_image_url text,
  latitude double precision not null default 0,
  longitude double precision not null default 0,
  youtube_channel_link text not null default '',
  resume_url text
);

-- ----------------------------------------------------------------------------
-- admins  (singleton row, id = 'admin')
-- used by: services/auth/auth_admin_service.dart
-- NOTE: credentials are stored/compared in plaintext by the app. This is
-- insecure (OWASP A02/A07) -- consider hashing the password and/or moving
-- admin auth to Supabase Auth instead of a custom table check.
-- ----------------------------------------------------------------------------
create table if not exists public.admins (
  id text primary key default 'admin',
  phone_number text not null,
  password text not null
);

-- ----------------------------------------------------------------------------
-- admission_announcements
-- used by: services/admissions/admissions_services.dart
-- ----------------------------------------------------------------------------
create table if not exists public.admission_announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  start_date timestamptz not null,
  end_date timestamptz not null,
  details text not null default ''
);

create index if not exists idx_admission_announcements_start_date
  on public.admission_announcements (start_date);

-- ----------------------------------------------------------------------------
-- banners
-- used by: services/banner/banner_service.dart
-- ----------------------------------------------------------------------------
create table if not exists public.banners (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  image_url text not null
);

-- ----------------------------------------------------------------------------
-- courses_outlines
-- used by: services/courses_outline/courses_outline_service.dart
-- weeks: [{ "title": string, "topics": string[] }]
-- ----------------------------------------------------------------------------
create table if not exists public.courses_outlines (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  weeks jsonb not null default '[]'::jsonb
);

-- ----------------------------------------------------------------------------
-- enrolled_students
-- used by: services/enrolled_students/enrolled_students_services.dart
-- ----------------------------------------------------------------------------
create table if not exists public.enrolled_students (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  father_name text not null,
  level text not null,
  contact_number text not null,
  father_contact_number text not null,
  address text not null,
  date_of_birth timestamptz not null,
  gender text not null,
  enrollment_date timestamptz not null default now()
);

create index if not exists idx_enrolled_students_level
  on public.enrolled_students (level);
create index if not exists idx_enrolled_students_enrollment_date
  on public.enrolled_students (enrollment_date);

-- ----------------------------------------------------------------------------
-- note_categories / notes
-- used by: services/notes/notes_service.dart
-- category id is the human-readable category name chosen by the admin.
-- ----------------------------------------------------------------------------
create table if not exists public.note_categories (
  id text primary key,
  created_at timestamptz not null default now()
);

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  category_id text not null references public.note_categories (id)
    on update cascade on delete cascade,
  title text not null,
  url text not null,
  timestamp timestamptz not null default now(),
  access_granted boolean not null default false
);

create index if not exists idx_notes_category_id
  on public.notes (category_id);

-- ----------------------------------------------------------------------------
-- updates
-- used by: services/updates/updates_services.dart
-- type mirrors the UpdateType enum (models/updates.dart)
-- ----------------------------------------------------------------------------
create table if not exists public.updates (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  date timestamptz not null,
  type text not null check (type in ('newCourse', 'event', 'resourceUpdate')),
  timestamp timestamptz not null default now()
);

create index if not exists idx_updates_date
  on public.updates (date);

-- ----------------------------------------------------------------------------
-- student_spotlights
-- used by: services/student_spotlight/student_spotlight_service.dart
-- ----------------------------------------------------------------------------
create table if not exists public.student_spotlights (
  id uuid primary key default gen_random_uuid(),
  student_name text not null,
  award_title text not null default 'Student of the Month',
  period text not null,
  course_or_batch text not null default '',
  image_url text not null,
  quote_or_message text not null default '',
  achievement_highlights text not null default '',
  is_featured boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_student_spotlights_created_at
  on public.student_spotlights (created_at desc);

create index if not exists idx_student_spotlights_is_featured
  on public.student_spotlights (is_featured);

create index if not exists idx_student_spotlights_award_title
  on public.student_spotlights (award_title);


-- ============================================================================
-- Row Level Security
-- The app talks to Supabase with the anon key only (there is no
-- supabase.auth session), so policies are permissive to preserve current
-- app behavior. Tighten these (e.g. require a real authenticated admin role)
-- before shipping to production, especially for admins/enrolled_students.
-- ============================================================================

alter table public.about_me enable row level security;
alter table public.admins enable row level security;
alter table public.admission_announcements enable row level security;
alter table public.banners enable row level security;
alter table public.courses_outlines enable row level security;
alter table public.enrolled_students enable row level security;
alter table public.note_categories enable row level security;
alter table public.notes enable row level security;
alter table public.student_spotlights enable row level security;
alter table public.updates enable row level security;

do $$
declare
  t text;
begin
  foreach t in array array[
    'about_me',
    'admins',
    'admission_announcements',
    'banners',
    'courses_outlines',
    'enrolled_students',
    'note_categories',
    'notes',
    'student_spotlights',
    'updates'
  ]
  loop
    execute format(
      'create policy "%1$s_anon_all" on public.%1$s for all using (true) with check (true);',
      t
    );
  end loop;
end $$;

-- ============================================================================
-- Realtime
-- Every service above calls .stream(...), which requires the table to be
-- added to the supabase_realtime publication (fixes RealtimeSubscribeException
-- / channelError on the client).
-- ============================================================================

do $$
declare
  t text;
begin
  foreach t in array array[
    'about_me',
    'admission_announcements',
    'banners',
    'courses_outlines',
    'enrolled_students',
    'note_categories',
    'notes',
    'student_spotlights',
    'updates'
  ]
  loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime'
        and schemaname = 'public'
        and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I;', t);
    end if;
  end loop;
end $$;
