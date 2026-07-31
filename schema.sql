-- Enable RLS
alter table profiles enable row level security;
alter table goals enable row level security;
alter table events enable row level security;
alter table friendships enable row level security;
alter table user_badges enable row level security;

-- Profiles table (extends auth.users)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  name text not null,
  email text not null,
  instagram text,
  parent_phone text,
  parent_pin text,
  parent_data jsonb default '{}',
  initials text,
  avatar_preset int default 0,
  bio text default '',
  accountability_mode text,
  theme text default 'blackberry',
  streak int default 0,
  xp int default 0,
  level int default 1,
  chroma int default 0,
  goals_completed int default 0,
  joined_at timestamptz default now()
);

-- Goals table
create table goals (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  title text not null,
  category text default 'other',
  time int default 30,
  created_at timestamptz default now(),
  lock_at timestamptz,
  locked boolean default false,
  completed boolean default false,
  completed_at timestamptz,
  failed boolean default false,
  date text not null
);

-- Events table
create table events (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  text text not null,
  type text not null,
  created_at timestamptz default now()
);

-- Friendships table
create table friendships (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  friend_id uuid references auth.users on delete cascade not null,
  status text default 'pending', -- pending, accepted, declined
  created_at timestamptz default now(),
  unique(user_id, friend_id)
);

-- User badges table
create table user_badges (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  badge_id text not null,
  earned_at timestamptz default now(),
  unique(user_id, badge_id)
);

-- RLS Policies
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view own goals" ON goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own goals" ON goals FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own goals" ON goals FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own goals" ON goals FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own events" ON events FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own events" ON events FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own friendships" ON friendships FOR SELECT USING (auth.uid() = user_id OR auth.uid() = friend_id);
CREATE POLICY "Users can insert friendships" ON friendships FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update friendships" ON friendships FOR UPDATE USING (auth.uid() = friend_id);
CREATE POLICY "Users can delete friendships" ON friendships FOR DELETE USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can view own badges" ON user_badges FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own badges" ON user_badges FOR INSERT WITH CHECK (auth.uid() = user_id);