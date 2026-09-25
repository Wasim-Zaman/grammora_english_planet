-- ============================================================
-- GEP Attendance Module Schema
-- Run this in your Supabase SQL Editor
-- ============================================================

-- 1. SHIFTS TABLE
-- Stores class/session shifts (e.g., Morning 9-11, Evening 6-8)

create table if not exists public.shifts (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  start_time time not null,
  end_time time not null,
  days text[] not null default '{}', -- e.g., ['Mon','Tue','Wed']
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. SHIFT_STUDENTS TABLE
-- Many-to-many: which students are enrolled in which shifts

create table if not exists public.shift_students (
  id uuid default gen_random_uuid() primary key,
  shift_id uuid not null references public.shifts(id) on delete cascade,
  student_id uuid not null references public.enrolled_students(id) on delete cascade,
  enrolled_at timestamptz default now(),
  unique(shift_id, student_id)
);

-- 3. ATTENDANCE TABLE
-- Records student attendance per shift per day

create table if not exists public.attendance (
  id uuid default gen_random_uuid() primary key,
  shift_id uuid not null references public.shifts(id) on delete cascade,
  student_id uuid not null references public.enrolled_students(id) on delete cascade,
  date date not null,
  marked_at timestamptz default now(),
  marked_by text not null default 'qr_scan', -- 'qr_scan' | 'manual'
  unique(shift_id, student_id, date)
);

-- 4. ATTENDANCE_QR_CODES TABLE
-- Stores daily QR codes for each shift (admin generates these)

create table if not exists public.attendance_qr_codes (
  id uuid default gen_random_uuid() primary key,
  shift_id uuid not null references public.shifts(id) on delete cascade,
  date date not null,
  qr_token text not null, -- unique token embedded in QR
  expires_at timestamptz not null,
  created_at timestamptz default now(),
  unique(shift_id, date)
);

-- ============================================================
-- RLS POLICIES (Anonymous access — tighten for production)
-- ============================================================

alter table public.shifts enable row level security;
alter table public.shift_students enable row level security;
alter table public.attendance enable row level security;
alter table public.attendance_qr_codes enable row level security;

-- Shifts: anon can read all

create policy "shifts_anon_all"
  on public.shifts
  for all
  to anon
  using (true)
  with check (true);

-- Shift Students: anon can read all

create policy "shift_students_anon_all"
  on public.shift_students
  for all
  to anon
  using (true)
  with check (true);

-- Attendance: anon can read all, insert (for QR scanning)

create policy "attendance_anon_all"
  on public.attendance
  for all
  to anon
  using (true)
  with check (true);

-- QR Codes: anon can read all (students need to validate), insert/update (admin)

create policy "attendance_qr_codes_anon_all"
  on public.attendance_qr_codes
  for all
  to anon
  using (true)
  with check (true);

-- ============================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================

create index if not exists idx_shift_students_shift_id on public.shift_students(shift_id);
create index if not exists idx_shift_students_student_id on public.shift_students(student_id);
create index if not exists idx_attendance_shift_id on public.attendance(shift_id);
create index if not exists idx_attendance_student_id on public.attendance(student_id);
create index if not exists idx_attendance_date on public.attendance(date);
create index if not exists idx_attendance_qr_codes_shift_date on public.attendance_qr_codes(shift_id, date);
create index if not exists idx_attendance_qr_codes_token on public.attendance_qr_codes(qr_token);

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Get attendance summary for a student (monthly)
create or replace function public.get_student_attendance_monthly(
  p_student_id uuid,
  p_year int,
  p_month int
)
returns table (
  total_days int,
  present_days int,
  percentage numeric
)
language sql
stable
as $$
  select
    count(distinct s.date)::int as total_days,
    count(distinct a.date)::int as present_days,
    case
      when count(distinct s.date) > 0 then
        round((count(distinct a.date)::numeric / count(distinct s.date)::numeric) * 100, 1)
      else 0
    end as percentage
  from generate_series(
    make_date(p_year, p_month, 1),
    (make_date(p_year, p_month, 1) + interval '1 month' - interval '1 day')::date,
    interval '1 day'
  ) as s(date)
  left join public.attendance a
    on a.student_id = p_student_id
    and a.date = s.date;
$$;

-- Get attendance for a student in a date range
create or replace function public.get_student_attendance_range(
  p_student_id uuid,
  p_start_date date,
  p_end_date date
)
returns table (
  date date,
  is_present boolean
)
language sql
stable
as $$
  select
    s.date,
    exists (
      select 1 from public.attendance a
      where a.student_id = p_student_id
      and a.date = s.date
    ) as is_present
  from generate_series(p_start_date, p_end_date, interval '1 day') as s(date)
  order by s.date desc;
$$;

-- ============================================================
-- ENROLLED_STUDENTS: ADD SHIFT_ID (run if table already exists)
-- ============================================================

alter table public.enrolled_students
  add column if not exists shift_id uuid references public.shifts(id) on delete set null;

create index if not exists idx_enrolled_students_shift_id on public.enrolled_students(shift_id);

-- ============================================================
-- Get all attendance records for admin (with student & shift info)
-- ============================================================

create or replace function public.get_attendance_records(
  p_shift_id uuid default null,
  p_date date default null,
  p_limit int default 50,
  p_offset int default 0
)
returns table (
  id uuid,
  shift_name text,
  student_name text,
  date date,
  marked_at timestamptz,
  marked_by text
)
language sql
stable
as $$
  select
    a.id,
    s.name as shift_name,
    st.name as student_name,
    a.date,
    a.marked_at,
    a.marked_by
  from public.attendance a
  join public.shifts s on s.id = a.shift_id
  join public.enrolled_students st on st.id = a.student_id
  where
    (p_shift_id is null or a.shift_id = p_shift_id)
    and (p_date is null or a.date = p_date)
  order by a.date desc, a.marked_at desc
  limit p_limit
  offset p_offset;
$$;
