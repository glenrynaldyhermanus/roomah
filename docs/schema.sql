-- =============================================================================
-- Roomah — Supabase schema reference (`public`)
-- =============================================================================
-- Project: Roomah  |  ref: fcqehsciylskujjtqvxw  |  Postgres 17
-- Pulled: 2026-03-28 (introspection from live DB)
-- This file is documentation for developers/AI. Do not treat as a migration script.
-- UUID defaults use uuid_generate_v4() (requires extension such as uuid-ossp on search_path).
-- =============================================================================
--
-- RLS note (important):
-- Row Level Security is ENABLED on all public tables below. PostgREST access
-- requires at least one policy per operation. Example policies are listed in the
-- RLS section. For dev/testing, calendar_events, items, reminders, routine_*,
-- stores, tags, and todo_tags document permissive "testing_open_all" (USING true).
-- Hapus/ganti policy tersebut sebelum production (persempit per household_id / member).
-- Table `notes` memakai "Allow authenticated access to notes" (broad bagi authenticated).
--
-- =============================================================================

-- === TABLES ==================================================================

-- App user profile, keyed by auth user id. Keeps email, username, soft-delete audit.
-- Synced from auth.users via trigger handle_new_user (see TRIGGERS).
CREATE TABLE public.users (
  id uuid NOT NULL,
  email character varying(255) NOT NULL,
  username character varying(255),
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  full_name character varying,
  avatar_url character varying,
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_email_key UNIQUE (email),
  CONSTRAINT users_username_key UNIQUE (username),
  CONSTRAINT users_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT users_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users (id),
  CONSTRAINT users_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users (id)
);

-- Household (family/unit) container; most domain data scopes to household_id.
CREATE TABLE public.households (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  CONSTRAINT households_pkey PRIMARY KEY (id),
  CONSTRAINT households_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT households_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users (id),
  CONSTRAINT households_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users (id)
);

-- Membership of a user in a household; role distinguishes owner/admin/member.
CREATE TABLE public.household_members (
  household_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role character varying NOT NULL DEFAULT 'member'::character varying,
  joined_at timestamp with time zone DEFAULT now(),
  invited_by uuid,
  total_points integer DEFAULT 0,
  CONSTRAINT household_members_pkey PRIMARY KEY (household_id, user_id),
  CONSTRAINT household_members_role_check CHECK (
    (role)::text = ANY (
      ARRAY['owner'::character varying, 'admin'::character varying, 'member'::character varying]::text[]
    )
  ),
  CONSTRAINT household_members_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id) ON DELETE CASCADE,
  CONSTRAINT household_members_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES public.users (id),
  CONSTRAINT household_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users (id) ON DELETE CASCADE
);

-- Calendar block (title, range, optional location). Soft-delete columns present.
-- Purpose: verify with app code for overlap with public.events.
CREATE TABLE public.calendar_events (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title character varying NOT NULL,
  description text,
  start_at timestamp with time zone NOT NULL,
  end_at timestamp with time zone,
  all_day boolean DEFAULT false,
  location character varying,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  CONSTRAINT calendar_events_pkey PRIMARY KEY (id),
  CONSTRAINT calendar_events_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT calendar_events_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users (id),
  CONSTRAINT calendar_events_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users (id)
);

-- Reusable labels for todos (name unique globally in this table).
CREATE TABLE public.tags (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  color character varying,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT tags_pkey PRIMARY KEY (id),
  CONSTRAINT tags_name_key UNIQUE (name),
  CONSTRAINT tags_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id)
);

-- Recipes for a household; ingredients in recipe_ingredients.
CREATE TABLE public.recipes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title character varying NOT NULL,
  description text,
  instructions text,
  prep_time_minutes integer,
  household_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT recipes_pkey PRIMARY KEY (id),
  CONSTRAINT recipes_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id) ON DELETE CASCADE
);

CREATE TABLE public.recipe_ingredients (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  recipe_id uuid,
  item_name character varying NOT NULL,
  quantity character varying,
  is_optional boolean DEFAULT false,
  CONSTRAINT recipe_ingredients_pkey PRIMARY KEY (id),
  CONSTRAINT recipe_ingredients_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes (id) ON DELETE CASCADE
);

-- Inventory taxonomy per household.
CREATE TABLE public.inventory_categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  icon character varying,
  household_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT inventory_categories_pkey PRIMARY KEY (id),
  CONSTRAINT inventory_categories_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id) ON DELETE CASCADE
);

-- Stock-like line items with optional category and pricing metadata.
CREATE TABLE public.inventory_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  category_id uuid,
  household_id uuid,
  quantity integer DEFAULT 1,
  price numeric(10, 2),
  brand character varying,
  purchase_link text,
  image_url text,
  purchase_date date,
  expire_date date,
  low_stock_threshold integer DEFAULT 3,
  status character varying DEFAULT 'in_stock'::character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone,
  CONSTRAINT inventory_items_pkey PRIMARY KEY (id),
  CONSTRAINT inventory_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.inventory_categories (id) ON DELETE SET NULL,
  CONSTRAINT inventory_items_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id) ON DELETE CASCADE
);

-- Migration (if table already exists without image_url):
-- ALTER TABLE public.inventory_items ADD COLUMN IF NOT EXISTS image_url text;
-- Migration (if table already exists without dates):
-- ALTER TABLE public.inventory_items ADD COLUMN IF NOT EXISTS purchase_date date;
-- ALTER TABLE public.inventory_items ADD COLUMN IF NOT EXISTS expire_date date;
-- Migration (if table already exists without low_stock_threshold):
-- ALTER TABLE public.inventory_items ADD COLUMN IF NOT EXISTS low_stock_threshold integer DEFAULT 3;

-- Household-scoped events; created_by points at Supabase auth.users.
CREATE TABLE public.events (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title character varying NOT NULL,
  description text,
  household_id uuid,
  frequency_type character varying,
  event_date timestamp with time zone,
  is_recurring boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT events_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users (id),
  CONSTRAINT events_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id) ON DELETE CASCADE
);

-- Grouping for routines (color/icon), scoped to household.
CREATE TABLE public.routine_categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  color character varying(7) DEFAULT '#3B82F6'::character varying,
  icon character varying(50),
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  household_id uuid,
  CONSTRAINT routine_categories_pkey PRIMARY KEY (id),
  CONSTRAINT routine_categories_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT routine_categories_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users (id),
  CONSTRAINT routine_categories_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id),
  CONSTRAINT routine_categories_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users (id)
);

-- How-to / SOP guides for household tasks; steps stored as jsonb (e.g. array of strings).
CREATE TABLE public.guides (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title character varying NOT NULL,
  description text,
  steps jsonb,
  household_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT guides_pkey PRIMARY KEY (id),
  CONSTRAINT guides_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id) ON DELETE CASCADE,
  CONSTRAINT guides_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id)
);

-- Todos with assignment, due date, priority, soft delete.
CREATE TABLE public.todos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title character varying(255) NOT NULL,
  description text,
  is_completed boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  completed_at timestamp with time zone,
  due_date timestamp with time zone,
  assigned_to uuid,
  priority smallint DEFAULT 0,
  household_id uuid,
  CONSTRAINT todos_pkey PRIMARY KEY (id),
  CONSTRAINT todos_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users (id),
  CONSTRAINT todos_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT todos_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users (id),
  CONSTRAINT todos_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id),
  CONSTRAINT todos_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users (id)
);

-- Recurring or scheduled chores with frequency metadata and next due date.
CREATE TABLE public.routines (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title character varying NOT NULL,
  description text,
  frequency_type character varying NOT NULL,
  frequency_value integer NOT NULL,
  last_completed_at timestamp with time zone,
  next_due_date date NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  category_id uuid,
  household_id uuid,
  guide_id uuid,
  CONSTRAINT routines_pkey PRIMARY KEY (id),
  CONSTRAINT routines_frequency_type_check CHECK (
    (frequency_type)::text = ANY (
      ARRAY[
        ('daily'::character varying)::text,
        ('weekly'::character varying)::text,
        ('monthly'::character varying)::text,
        ('custom'::character varying)::text
      ]
    )
  ),
  CONSTRAINT routines_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.routine_categories (id),
  CONSTRAINT routines_guide_id_fkey FOREIGN KEY (guide_id) REFERENCES public.guides (id) ON DELETE SET NULL,
  CONSTRAINT routines_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT routines_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users (id),
  CONSTRAINT routines_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id),
  CONSTRAINT routines_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users (id)
);

-- Many-to-many todos ↔ tags.
CREATE TABLE public.todo_tags (
  todo_id uuid NOT NULL,
  tag_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT todo_tags_pkey PRIMARY KEY (todo_id, tag_id),
  CONSTRAINT todo_tags_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT todo_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags (id) ON DELETE CASCADE,
  CONSTRAINT todo_tags_todo_id_fkey FOREIGN KEY (todo_id) REFERENCES public.todos (id) ON DELETE CASCADE
);

-- Points / assignment of a routine to a user (gamification weight via points).
CREATE TABLE public.routine_assignments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  routine_id uuid NOT NULL,
  user_id uuid NOT NULL,
  points integer DEFAULT 1,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT routine_assignments_pkey PRIMARY KEY (id),
  CONSTRAINT routine_assignments_routine_id_user_id_key UNIQUE (routine_id, user_id),
  CONSTRAINT routine_assignments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT routine_assignments_routine_id_fkey FOREIGN KEY (routine_id) REFERENCES public.routines (id) ON DELETE CASCADE,
  CONSTRAINT routine_assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users (id) ON DELETE CASCADE
);

-- Skip/override a routine on a specific calendar date.
CREATE TABLE public.routine_exceptions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  routine_id uuid NOT NULL,
  exception_date date NOT NULL,
  reason text,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT routine_exceptions_pkey PRIMARY KEY (id),
  CONSTRAINT routine_exceptions_routine_id_exception_date_key UNIQUE (routine_id, exception_date),
  CONSTRAINT routine_exceptions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT routine_exceptions_routine_id_fkey FOREIGN KEY (routine_id) REFERENCES public.routines (id) ON DELETE CASCADE
);

-- Audit trail for routine completion / snooze / skip.
CREATE TABLE public.routine_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  routine_id uuid NOT NULL,
  action character varying NOT NULL,
  action_at timestamp with time zone DEFAULT now(),
  acted_by uuid,
  note text,
  CONSTRAINT routine_logs_pkey PRIMARY KEY (id),
  CONSTRAINT routine_logs_action_check CHECK (
    (action)::text = ANY (
      ARRAY['complete'::character varying, 'snooze'::character varying, 'skip'::character varying]::text[]
    )
  ),
  CONSTRAINT routine_logs_acted_by_fkey FOREIGN KEY (acted_by) REFERENCES public.users (id),
  CONSTRAINT routine_logs_routine_id_fkey FOREIGN KEY (routine_id) REFERENCES public.routines (id) ON DELETE CASCADE
);

-- Scheduled notification for exactly one of todo or routine (enforced by CHECK).
CREATE TABLE public.reminders (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  todo_id uuid,
  routine_id uuid,
  schedule_at timestamp with time zone NOT NULL,
  channel character varying NOT NULL DEFAULT 'local'::character varying,
  is_sent boolean DEFAULT false,
  sent_at timestamp with time zone,
  message text,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT reminders_pkey PRIMARY KEY (id),
  CONSTRAINT reminders_channel_check CHECK (
    (channel)::text = ANY (ARRAY['local'::character varying, 'push'::character varying]::text[])
  ),
  CONSTRAINT reminders_target_chk CHECK (
    (todo_id IS NOT NULL AND routine_id IS NULL)
    OR (todo_id IS NULL AND routine_id IS NOT NULL)
  ),
  CONSTRAINT reminders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT reminders_routine_id_fkey FOREIGN KEY (routine_id) REFERENCES public.routines (id) ON DELETE CASCADE,
  CONSTRAINT reminders_todo_id_fkey FOREIGN KEY (todo_id) REFERENCES public.todos (id) ON DELETE CASCADE
);

-- Named stores (e.g. supermarkets) for a household.
CREATE TABLE public.stores (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  household_id uuid,
  whatsapp_number character varying(20),
  contact_url text,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT stores_pkey PRIMARY KEY (id),
  CONSTRAINT stores_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT stores_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id) ON DELETE CASCADE
);

-- Household sticky notes (e.g. fridge notes); separate from todos/routines.
CREATE TABLE public.notes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title character varying(255),
  content text NOT NULL,
  color character varying(7) DEFAULT '#E23661'::character varying,
  is_pinned boolean DEFAULT false,
  household_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  updated_at timestamp with time zone,
  CONSTRAINT notes_pkey PRIMARY KEY (id),
  CONSTRAINT notes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT notes_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id) ON DELETE CASCADE
);

-- Catalog of purchasable products / pantry templates for shopping lists.
CREATE TABLE public.items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  category character varying,
  perishable boolean DEFAULT false,
  shelf_life_days integer,
  household_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT items_pkey PRIMARY KEY (id),
  CONSTRAINT items_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT items_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id) ON DELETE CASCADE
);

-- Materials/tools for a guide; references household catalog items.
CREATE TABLE public.guide_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  guide_id uuid NOT NULL,
  item_id uuid NOT NULL,
  notes character varying,
  is_optional boolean DEFAULT false,
  CONSTRAINT guide_items_pkey PRIMARY KEY (id),
  CONSTRAINT guide_items_guide_id_fkey FOREIGN KEY (guide_id) REFERENCES public.guides (id) ON DELETE CASCADE,
  CONSTRAINT guide_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items (id) ON DELETE CASCADE
);

-- Lines on a shopping list linking optional store + item.
CREATE TABLE public.shopping_list_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  store_id uuid,
  item_id uuid,
  quantity numeric DEFAULT 1,
  unit character varying,
  priority smallint DEFAULT 0,
  is_checked boolean DEFAULT false,
  needed_by date,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT shopping_list_items_pkey PRIMARY KEY (id),
  CONSTRAINT shopping_list_items_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT shopping_list_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items (id) ON DELETE CASCADE,
  CONSTRAINT shopping_list_items_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.stores (id) ON DELETE SET NULL
);

-- Budget or finance line: amount over a date range (table historically named finances; PK index name budgets_pkey in DB).
CREATE TABLE public.finances (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying(255) NOT NULL,
  amount numeric(10, 2) NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  household_id uuid,
  CONSTRAINT budgets_pkey PRIMARY KEY (id),
  CONSTRAINT budgets_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users (id),
  CONSTRAINT budgets_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users (id),
  CONSTRAINT budgets_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users (id),
  CONSTRAINT finances_household_id_fkey FOREIGN KEY (household_id) REFERENCES public.households (id)
);


-- === INDEXES (secondary / non-PK; PK and UNIQUE constraints are on tables above) ==

CREATE INDEX idx_calendar_events_start_at ON public.calendar_events USING btree (start_at);
CREATE INDEX idx_finances_household_id ON public.finances USING btree (household_id);
CREATE INDEX idx_reminders_schedule ON public.reminders USING btree (is_sent, schedule_at);
CREATE INDEX idx_routine_categories_household_id ON public.routine_categories USING btree (household_id);
CREATE INDEX idx_routine_logs_routine_action_at ON public.routine_logs USING btree (routine_id, action_at DESC);
CREATE INDEX idx_routines_household_id ON public.routines USING btree (household_id);
CREATE INDEX idx_routines_guide_id ON public.routines USING btree (guide_id);
CREATE INDEX idx_routines_next_due ON public.routines USING btree (household_id, next_due_date);
CREATE INDEX idx_guides_household_id ON public.guides USING btree (household_id);
CREATE INDEX idx_guide_items_guide_id ON public.guide_items USING btree (guide_id);
CREATE INDEX idx_guide_items_item_id ON public.guide_items USING btree (item_id);
CREATE INDEX idx_shopping_list_needed_by ON public.shopping_list_items USING btree (needed_by);
CREATE INDEX idx_shopping_list_store_id ON public.shopping_list_items USING btree (store_id);
CREATE INDEX idx_todos_assigned_to ON public.todos USING btree (assigned_to);
CREATE INDEX idx_todos_due_date ON public.todos USING btree (due_date);
CREATE INDEX idx_todos_household_id ON public.todos USING btree (household_id);
CREATE INDEX idx_todos_is_completed ON public.todos USING btree (is_completed);
CREATE INDEX idx_notes_household_id ON public.notes USING btree (household_id);
CREATE INDEX idx_notes_household_pinned_updated ON public.notes USING btree (household_id, is_pinned DESC, updated_at DESC);


-- === ROW LEVEL SECURITY ======================================================
-- RLS is enabled on all public tables listed above. Example policy definitions
-- (from pg_policies at export time). Re-run in Supabase only when authoring migrations.

ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_exceptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shopping_list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.todo_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- events: any authenticated role can read/write all rows (broad; tighten per product rules if needed).
CREATE POLICY "Allow authenticated access to events"
  ON public.events
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

-- finances: permissive open policy (all roles in policy = public).
CREATE POLICY "Enable all access for all users"
  ON public.finances
  FOR ALL
  TO public
  USING (true);

CREATE POLICY "Allow authenticated access to household_members"
  ON public.household_members
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

CREATE POLICY "Allow authenticated access to households"
  ON public.households
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

CREATE POLICY "Allow authenticated access to inventory_categories"
  ON public.inventory_categories
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

CREATE POLICY "Allow authenticated access to inventory_items"
  ON public.inventory_items
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

CREATE POLICY "Allow authenticated access to guides"
  ON public.guides
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

CREATE POLICY "Allow authenticated access to guide_items"
  ON public.guide_items
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

CREATE POLICY "Allow authenticated access to recipe_ingredients"
  ON public.recipe_ingredients
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

CREATE POLICY "Allow authenticated access to recipes"
  ON public.recipes
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

-- TESTING / DEV — full access via PostgREST (anon + authenticated). Ganti untuk production.
CREATE POLICY "testing_open_all"
  ON public.calendar_events
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "testing_open_all"
  ON public.items
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "testing_open_all"
  ON public.reminders
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "testing_open_all"
  ON public.routine_assignments
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "testing_open_all"
  ON public.routine_categories
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "testing_open_all"
  ON public.routine_exceptions
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "testing_open_all"
  ON public.routine_logs
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "testing_open_all"
  ON public.stores
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "testing_open_all"
  ON public.tags
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "testing_open_all"
  ON public.todo_tags
  FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable all access for all users"
  ON public.routines
  FOR ALL
  TO public
  USING (true);

CREATE POLICY "Allow authenticated access to shopping_list_items"
  ON public.shopping_list_items
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

CREATE POLICY "Allow authenticated access to notes"
  ON public.notes
  FOR ALL
  TO public
  USING ((auth.role() = 'authenticated'::text));

CREATE POLICY "Enable all access for all users"
  ON public.todos
  FOR ALL
  TO public
  USING (true);

-- users: combined effect — broad SELECT plus insert/update own row only.
CREATE POLICY "Enable all access for all users"
  ON public.users
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Public profiles are viewable by everyone"
  ON public.users
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON public.users
  FOR INSERT
  TO public
  WITH CHECK ((auth.uid() = id));

CREATE POLICY "Users can update own profile"
  ON public.users
  FOR UPDATE
  TO public
  USING ((auth.uid() = id));


-- === FUNCTIONS (schema public) ===============================================

-- After signup, mirrors auth.users into public.users (upsert on conflict).
-- SECURITY DEFINER: runs with function owner privileges; keep locked down in production.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.users (id, email, full_name, created_at)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    updated_at = NOW();
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$function$;

-- Increments household_members.total_points when a routine is completed (routine_logs insert).
-- Reads points from routine_assignments for (routine_id, acted_by).
CREATE OR REPLACE FUNCTION public.add_points_on_completion()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  points_to_add integer;
BEGIN
  IF NEW.action = 'complete' THEN
    SELECT points INTO points_to_add
    FROM public.routine_assignments
    WHERE routine_id = NEW.routine_id AND user_id = NEW.acted_by;

    IF points_to_add IS NOT NULL AND points_to_add > 0 THEN
      UPDATE public.household_members
      SET total_points = total_points + points_to_add
      WHERE user_id = NEW.acted_by
        AND household_id = (SELECT household_id FROM public.routines WHERE id = NEW.routine_id);
    END IF;
  END IF;
  RETURN NEW;
END;
$function$;


-- === TRIGGERS ================================================================
-- Defined on auth.users (not public). Listed here because it maintains public.users.

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER on_routine_completed
  AFTER INSERT ON public.routine_logs
  FOR EACH ROW
  EXECUTE FUNCTION public.add_points_on_completion();

-- === STORAGE (inventory item images) =========================================
-- App uploads to bucket id/name: inventory-items (see AppConstants.inventoryItemsStorageBucket).
-- Object path pattern: {household_id}/{auth_user_id}_{timestamp}.{ext}
-- Create bucket in Dashboard → Storage → New bucket → name inventory-items, enable Public if using public URLs.
-- Policies (example; tighten by household path prefix for production):
--   INSERT/UPDATE/DELETE: authenticated users (or restrict with storage.foldername()).
--   SELECT: public for public bucket, or signed URLs for private buckets.
