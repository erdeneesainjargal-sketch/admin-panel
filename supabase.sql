-- =========================================================
-- Admin panel: хүснэгтүүд ба эхний өгөгдөл (Supabase / PostgreSQL)
-- =========================================================

-- Нууц үг шифрлэхэд хэрэгтэй өргөтгөл (Supabase-д extensions schema-д байрладаг)
create extension if not exists pgcrypto with schema extensions;


-- ---------------------------------------------------------
-- 1. content_drafts — ноорог постууд
-- ---------------------------------------------------------
create table if not exists public.content_drafts (
  id           bigint generated always as identity primary key,
  title        text        not null,
  body         text        not null default '',
  platform     text        not null default 'facebook'
                 check (platform in ('facebook', 'instagram', 'tiktok', 'website')),
  status       text        not null default 'draft'
                 check (status in ('draft', 'scheduled', 'published', 'rejected')),
  scheduled_at timestamptz,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

alter table public.content_drafts enable row level security;

insert into public.content_drafts (title, body, platform, status, scheduled_at) values
  ('Шинэ улирлын хямдрал',
   'Энэ долоо хоногт бүх арьс арчилгааны бүтээгдэхүүн 20% хямдарлаа!',
   'facebook', 'draft', null),
  ('Өглөөний йогийн хичээл',
   'Даваа, Лхагва, Баасан гарагт 07:30-д йогийн хичээлдээ урьж байна.',
   'instagram', 'scheduled', '2026-11-05 09:00:00+08'),
  ('Эрүүл амьдралын 5 зөвлөгөө',
   'Ус их уух, хангалттай унтах, өдөр бүр алхах, зөв хооллох, стрессээ удирдах.',
   'website', 'published', null);


-- ---------------------------------------------------------
-- 2. bookings — захиалгууд
-- ---------------------------------------------------------
create table if not exists public.bookings (
  id             bigint generated always as identity primary key,
  customer_name  text        not null,
  phone          text        not null,
  email          text,
  service        text        not null,
  booking_time   timestamptz not null,
  status         text        not null default 'pending'
                   check (status in ('pending', 'confirmed', 'completed', 'cancelled')),
  note           text,
  created_at     timestamptz not null default now()
);

alter table public.bookings enable row level security;

insert into public.bookings (customer_name, phone, email, service, booking_time, status, note) values
  ('Бат-Эрдэнэ', '99112233', 'bat@example.com',  'Массаж (60 мин)',      '2026-11-03 14:00:00+08', 'confirmed', null),
  ('Оюунчимэг',  '88445566', null,               'Нүүрний арчилгаа',      '2026-11-04 11:30:00+08', 'pending',   'Анх удаа ирж байгаа'),
  ('Тэмүүлэн',   '95778899', 'temuulen@example.com', 'Йогийн хувийн хичээл', '2026-11-02 08:00:00+08', 'cancelled', 'Хуваарь өөрчлөгдсөн');


-- ---------------------------------------------------------
-- 3. users — admin panel-д нэвтрэх хэрэглэгчид
-- ---------------------------------------------------------
create table if not exists public.users (
  id             uuid        primary key default gen_random_uuid(),
  email          text        not null unique,
  password_hash  text        not null,
  role           text        not null default 'admin'
                   check (role in ('admin', 'editor')),
  created_at     timestamptz not null default now()
);

alter table public.users enable row level security;

-- Нууц үгийг bcrypt-ээр шифрлэж хадгална (цэвэр текстээр хадгалагдахгүй)
-- Ажиллуулахаасаа өмнө 'ЭНД_НУУЦ_ҮГЭЭ_БИЧ'-ийг жинхэнэ нууц үгээр солино. Жинхэнэ нууц үгийг энд хадгалж болохгүй.
insert into public.users (email, password_hash, role) values
  ('erdeneesainjargal@gmail.com',
   extensions.crypt('ЭНД_НУУЦ_ҮГЭЭ_БИЧ', extensions.gen_salt('bf')),
   'admin')
on conflict (email) do nothing;


-- ---------------------------------------------------------
-- 4. staff — ажилтнууд
-- ---------------------------------------------------------
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
