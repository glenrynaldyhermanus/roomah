-- Public Schema DDL

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
    deleted_by UUID REFERENCES public.users(id)
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
    color VARCHAR(7) DEFAULT '#3B82F6',
    icon VARCHAR(50),
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
    category_id UUID REFERENCES public.routine_categories(id),
    frequency_type VARCHAR NOT NULL CHECK (frequency_type IN ('daily', 'weekly', 'monthly', 'custom')),
    frequency_value INTEGER NOT NULL,
    last_completed_at TIMESTAMP WITH TIME ZONE,
    next_due_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id),
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID REFERENCES public.users(id),
    deleted_at TIMESTAMP WITH TIME ZONE,
    deleted_by UUID REFERENCES public.users(id)
);
ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;

-- Migration: Add category_id column to existing routines table (if table already exists)
-- ALTER TABLE public.routines ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES public.routine_categories(id);