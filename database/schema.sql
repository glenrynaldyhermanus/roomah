-- Public Schema DDL
-- Schema extracted from Supabase project

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    email VARCHAR NOT NULL UNIQUE,
    username VARCHAR UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID REFERENCES public.users(id),
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID REFERENCES public.users(id)
);
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Todos Table
CREATE TABLE public.todos (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title VARCHAR NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID REFERENCES public.users(id),
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID REFERENCES public.users(id),
    completed_at TIMESTAMP WITH TIME ZONE
);
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

-- Finances Table
CREATE TABLE public.finances (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name VARCHAR NOT NULL,
    amount NUMERIC NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID REFERENCES public.users(id),
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID REFERENCES public.users(id)
);
ALTER TABLE public.finances ENABLE ROW LEVEL SECURITY;

-- Routine Categories Table
CREATE TABLE public.routine_categories (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name VARCHAR NOT NULL,
    color VARCHAR DEFAULT '#3B82F6',
    icon VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID REFERENCES public.users(id),
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID REFERENCES public.users(id)
);
ALTER TABLE public.routine_categories ENABLE ROW LEVEL SECURITY;

-- Routines Table
CREATE TABLE public.routines (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title VARCHAR NOT NULL,
    description TEXT,
    frequency_type VARCHAR NOT NULL CHECK (frequency_type::text = ANY (ARRAY['daily'::character varying::text, 'weekly'::character varying::text, 'monthly'::character varying::text, 'custom'::character varying::text])),
    frequency_value INTEGER NOT NULL,
    last_completed_at TIMESTAMP WITH TIME ZONE,
    next_due_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID REFERENCES public.users(id),
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID REFERENCES public.users(id),
    category_id UUID REFERENCES public.routine_categories(id)
);
ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;

-- Foreign Key Constraints
-- These constraints are already defined inline above, but here they are explicitly listed for reference:

-- Users table self-references
-- users.created_by -> users.id
-- users.updated_by -> users.id  
-- users.deleted_by -> users.id

-- Todos table references
-- todos.created_by -> users.id
-- todos.updated_by -> users.id
-- todos.deleted_by -> users.id

-- Finances table references  
-- finances.created_by -> users.id
-- finances.updated_by -> users.id
-- finances.deleted_by -> users.id

-- Routine Categories table references
-- routine_categories.created_by -> users.id
-- routine_categories.updated_by -> users.id
-- routine_categories.deleted_by -> users.id

-- Routines table references
-- routines.created_by -> users.id
-- routines.updated_by -> users.id
-- routines.deleted_by -> users.id
-- routines.category_id -> routine_categories.id
