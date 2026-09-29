-- ════════════════════════════════════════════════════════════
-- 오늘의 한 쪽 — 일기장 데이터베이스
--
-- Supabase 프로젝트를 새로 만든 뒤, 대시보드의 SQL Editor 에
-- 이 파일을 통째로 붙여 넣고 한 번 실행하면 됩니다.
-- 여러 번 실행해도 안전하게 쓰여 있습니다.
-- ════════════════════════════════════════════════════════════


-- ── 1. 일기 표 ──────────────────────────────────────────────
-- 하루에 한 편이므로 (사람, 날짜) 짝이 겹치지 않게 묶어 둔다.

create table if not exists public.entries (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references auth.users (id) on delete cascade,
  date        date        not null,
  title       text        not null default '',
  body        text        not null default '',
  mood        text,
  photo_path  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (user_id, date)
);

create index if not exists entries_user_date_idx
  on public.entries (user_id, date desc);


-- 고칠 때마다 updated_at 을 데이터베이스가 직접 찍는다.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists entries_touch_updated_at on public.entries;
create trigger entries_touch_updated_at
  before update on public.entries
  for each row execute function public.touch_updated_at();


-- ── 2. 행 수준 보안 ─────────────────────────────────────────
-- 이 부분이 잠금의 핵심이다. 저장소가 공개라 접속 키가 남에게 보여도,
-- 로그인한 본인의 행 말고는 읽기·쓰기·삭제가 데이터베이스에서 막힌다.

alter table public.entries enable row level security;

drop policy if exists "본인 일기만 읽기"   on public.entries;
drop policy if exists "본인 일기만 쓰기"   on public.entries;
drop policy if exists "본인 일기만 고치기" on public.entries;
drop policy if exists "본인 일기만 지우기" on public.entries;

create policy "본인 일기만 읽기" on public.entries
  for select using (auth.uid() = user_id);

create policy "본인 일기만 쓰기" on public.entries
  for insert with check (auth.uid() = user_id);

create policy "본인 일기만 고치기" on public.entries
  for update using (auth.uid() = user_id)
          with check (auth.uid() = user_id);

create policy "본인 일기만 지우기" on public.entries
  for delete using (auth.uid() = user_id);


-- ── 3. 사진 보관함 ──────────────────────────────────────────
-- public 을 false 로 두어 주소만 알면 열리는 일이 없게 한다.
-- 화면에 띄울 때는 잠깐만 쓰는 임시 주소를 그때그때 발급받는다.

insert into storage.buckets (id, name, public)
values ('diary-photos', 'diary-photos', false)
on conflict (id) do nothing;

-- 사진은 <본인 아이디>/<파일명> 으로 올라간다.
-- 아래 규칙은 폴더 이름이 본인 아이디일 때만 손댈 수 있게 한다.

drop policy if exists "본인 사진만 보기"   on storage.objects;
drop policy if exists "본인 사진만 올리기" on storage.objects;
drop policy if exists "본인 사진만 지우기" on storage.objects;

create policy "본인 사진만 보기" on storage.objects
  for select using (
    bucket_id = 'diary-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "본인 사진만 올리기" on storage.objects
  for insert with check (
    bucket_id = 'diary-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "본인 사진만 지우기" on storage.objects
  for delete using (
    bucket_id = 'diary-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
