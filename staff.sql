-- =========================================================
-- staff — ажилтнууд
-- Supabase → SQL Editor дээр нэг удаа ажиллуулна.
-- =========================================================

create table if not exists public.staff (
  id          bigint generated always as identity primary key,
  full_name   text        not null,
  position    text        not null,
  phone       text        not null,
  email       text        unique,
  hired_on    date        not null default current_date,
  created_at  timestamptz not null default now()
);

alter table public.staff enable row level security;

insert into public.staff (full_name, position, phone, email, hired_on) values
  ('Ганбаатар Номин',  'Массажист',                    '99001122', 'nomin@example.com',  '2024-03-15'),
  ('Дорж Сарангэрэл', 'Йогийн багш',                   '88112233', 'saraa@example.com',  '2025-01-06'),
  ('Цэнд Анужин',     'Арьс арчилгааны мэргэжилтэн',   '95223344', 'anujin@example.com', '2025-09-01')
on conflict (email) do nothing;
