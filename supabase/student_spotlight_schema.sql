-- ============================================================================
-- Student Spotlight / Student of the Month & Year Schema
-- Run this in your Supabase SQL Editor
-- ============================================================================

create table if not exists public.student_spotlights (
  id uuid primary key default gen_random_uuid(),
  student_name text not null,
  award_title text not null default 'Student of the Month', -- 'Student of the Month', 'Student of the Year', 'Star Performer', etc.
  period text not null,                                    -- e.g. 'October 2026', 'Academic Year 2025-2026'
  course_or_batch text not null default '',                -- e.g. 'Advanced Spoken English - Morning'
  image_url text not null,
  quote_or_message text not null default '',               -- Motivational quote or teacher's encouraging feedback
  achievement_highlights text not null default '',         -- e.g. '100% Attendance • Top in Speaking Presentation'
  is_featured boolean not null default true,               -- Display prominently in home spotlight
  created_at timestamptz not null default now()
);

-- Indexes for efficient queries
create index if not exists idx_student_spotlights_created_at
  on public.student_spotlights (created_at desc);

create index if not exists idx_student_spotlights_is_featured
  on public.student_spotlights (is_featured);

create index if not exists idx_student_spotlights_award_title
  on public.student_spotlights (award_title);

-- Row Level Security (RLS)
alter table public.student_spotlights enable row level security;

-- Permissive policy for app read/write (matches GEP app anon pattern)
create policy "student_spotlights_anon_all"
  on public.student_spotlights
  for all
  using (true)
  with check (true);

-- Enable Realtime
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'student_spotlights'
  ) then
    execute 'alter publication supabase_realtime add table public.student_spotlights;';
  end if;
end $$;
