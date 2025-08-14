BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- TODOS: due_date, assigned_to, priority
ALTER TABLE public.todos
	ADD COLUMN IF NOT EXISTS due_date TIMESTAMPTZ,
	ADD COLUMN IF NOT EXISTS assigned_to UUID REFERENCES public.users(id),
	ADD COLUMN IF NOT EXISTS priority SMALLINT DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_todos_due_date ON public.todos (due_date);
CREATE INDEX IF NOT EXISTS idx_todos_assigned_to ON public.todos (assigned_to);
CREATE INDEX IF NOT EXISTS idx_todos_is_completed ON public.todos (is_completed);

-- TAGS + RELASI (opsional)
CREATE TABLE IF NOT EXISTS public.tags (
	id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
	name VARCHAR NOT NULL UNIQUE,
	color VARCHAR,
	created_at TIMESTAMPTZ DEFAULT NOW(),
	created_by UUID REFERENCES public.users(id)
);
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.todo_tags (
	todo_id UUID NOT NULL REFERENCES public.todos(id) ON DELETE CASCADE,
	tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
	created_at TIMESTAMPTZ DEFAULT NOW(),
	created_by UUID REFERENCES public.users(id),
	PRIMARY KEY (todo_id, tag_id)
);
ALTER TABLE public.todo_tags ENABLE ROW LEVEL SECURITY;

-- ROUTINES: assignments, exceptions, logs
CREATE TABLE IF NOT EXISTS public.routine_assignments (
	id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
	routine_id UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
	user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
	points INTEGER DEFAULT 1,
	created_at TIMESTAMPTZ DEFAULT NOW(),
	created_by UUID REFERENCES public.users(id),
	UNIQUE (routine_id, user_id)
);
ALTER TABLE public.routine_assignments ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.routine_exceptions (
	id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
	routine_id UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
	exception_date DATE NOT NULL,
	reason TEXT,
	created_at TIMESTAMPTZ DEFAULT NOW(),
	created_by UUID REFERENCES public.users(id),
	UNIQUE (routine_id, exception_date)
);
ALTER TABLE public.routine_exceptions ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.routine_logs (
	id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
	routine_id UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
	action VARCHAR NOT NULL CHECK (action IN ('complete', 'snooze', 'skip')),
	action_at TIMESTAMPTZ DEFAULT NOW(),
	acted_by UUID REFERENCES public.users(id),
	note TEXT
);
ALTER TABLE public.routine_logs ENABLE ROW LEVEL SECURITY;
CREATE INDEX IF NOT EXISTS idx_routine_logs_routine_action_at ON public.routine_logs (routine_id, action_at DESC);

-- REMINDERS
CREATE TABLE IF NOT EXISTS public.reminders (
	id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
	todo_id UUID REFERENCES public.todos(id) ON DELETE CASCADE,
	routine_id UUID REFERENCES public.routines(id) ON DELETE CASCADE,
	schedule_at TIMESTAMPTZ NOT NULL,
	channel VARCHAR NOT NULL DEFAULT 'local' CHECK (channel IN ('local', 'push')),
	is_sent BOOLEAN DEFAULT FALSE,
	sent_at TIMESTAMPTZ,
	message TEXT,
	created_at TIMESTAMPTZ DEFAULT NOW(),
	created_by UUID REFERENCES public.users(id),
	CONSTRAINT reminders_target_chk CHECK (
		(todo_id IS NOT NULL AND routine_id IS NULL)
		OR (todo_id IS NULL AND routine_id IS NOT NULL)
	)
);
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
CREATE INDEX IF NOT EXISTS idx_reminders_schedule ON public.reminders (is_sent, schedule_at);

-- CALENDAR
CREATE TABLE IF NOT EXISTS public.calendar_events (
	id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
	title VARCHAR NOT NULL,
	description TEXT,
	start_at TIMESTAMPTZ NOT NULL,
	end_at TIMESTAMPTZ,
	all_day BOOLEAN DEFAULT FALSE,
	location VARCHAR,
	created_at TIMESTAMPTZ DEFAULT NOW(),
	created_by UUID REFERENCES public.users(id),
	updated_at TIMESTAMPTZ,
	updated_by UUID REFERENCES public.users(id),
	deleted_at TIMESTAMPTZ,
	deleted_by UUID REFERENCES public.users(id)
);
ALTER TABLE public.calendar_events ENABLE ROW LEVEL SECURITY;
CREATE INDEX IF NOT EXISTS idx_calendar_events_start_at ON public.calendar_events (start_at);

-- HOUSEHOLDS
CREATE TABLE IF NOT EXISTS public.households (
	id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
	name VARCHAR NOT NULL,
	created_at TIMESTAMPTZ DEFAULT NOW(),
	created_by UUID REFERENCES public.users(id),
	updated_at TIMESTAMPTZ,
	updated_by UUID REFERENCES public.users(id),
	deleted_at TIMESTAMPTZ,
	deleted_by UUID REFERENCES public.users(id)
);
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.household_members (
	household_id UUID NOT NULL REFERENCES public.households(id) ON DELETE CASCADE,
	user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
	role VARCHAR NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
	joined_at TIMESTAMPTZ DEFAULT NOW(),
	invited_by UUID REFERENCES public.users(id),
	PRIMARY KEY (household_id, user_id)
);
ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.todos ADD COLUMN IF NOT EXISTS household_id UUID REFERENCES public.households(id);
ALTER TABLE public.finances ADD COLUMN IF NOT EXISTS household_id UUID REFERENCES public.households(id);
ALTER TABLE public.routine_categories ADD COLUMN IF NOT EXISTS household_id UUID REFERENCES public.households(id);
ALTER TABLE public.routines ADD COLUMN IF NOT EXISTS household_id UUID REFERENCES public.households(id);

CREATE INDEX IF NOT EXISTS idx_todos_household_id ON public.todos (household_id);
CREATE INDEX IF NOT EXISTS idx_finances_household_id ON public.finances (household_id);
CREATE INDEX IF NOT EXISTS idx_routines_household_id ON public.routines (household_id);
CREATE INDEX IF NOT EXISTS idx_routine_categories_household_id ON public.routine_categories (household_id);

COMMIT;