-- Proposed Schema for Roomah App

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table (Existing)
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    email VARCHAR NOT NULL UNIQUE,
    username VARCHAR UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Households (Family) Table [NEW]
CREATE TABLE public.households (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name VARCHAR NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id)
);

-- Household Members Table [NEW]
CREATE TABLE public.household_members (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    role VARCHAR DEFAULT 'member', -- 'admin', 'member'
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(household_id, user_id)
);

-- Inventory Categories Table [NEW]
CREATE TABLE public.inventory_categories (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name VARCHAR NOT NULL,
    icon VARCHAR, -- store icon name/code
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inventory Items Table [NEW]
CREATE TABLE public.inventory_items (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name VARCHAR NOT NULL,
    category_id UUID REFERENCES public.inventory_categories(id) ON DELETE SET NULL,
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    price DECIMAL(10, 2),
    brand VARCHAR,
    purchase_link TEXT,
    status VARCHAR DEFAULT 'in_stock', -- 'in_stock', 'low_stock', 'out_of_stock'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Events (Routines) Table [Refined from 'routines']
CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title VARCHAR NOT NULL,
    description TEXT,
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    frequency_type VARCHAR, -- 'daily', 'weekly', 'monthly', 'once'
    event_date TIMESTAMP WITH TIME ZONE, -- For one-time events
    is_recurring BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id)
);

-- Recipes Table [NEW]
CREATE TABLE public.recipes (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title VARCHAR NOT NULL,
    description TEXT,
    instructions TEXT,
    prep_time_minutes INTEGER,
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recipe Ingredients Table [NEW]
CREATE TABLE public.recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    recipe_id UUID REFERENCES public.recipes(id) ON DELETE CASCADE,
    item_name VARCHAR NOT NULL, -- Can link to inventory_items if strict, or just text
    quantity VARCHAR,
    is_optional BOOLEAN DEFAULT FALSE
);

-- Shopping List Table [NEW]
CREATE TABLE public.shopping_list_items (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name VARCHAR NOT NULL,
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    is_checked BOOLEAN DEFAULT FALSE,
    inventory_item_id UUID REFERENCES public.inventory_items(id) ON DELETE SET NULL, -- Optional link to inventory
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id)
);

-- Enable RLS (Row Level Security) - Placeholder policies would be needed
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shopping_list_items ENABLE ROW LEVEL SECURITY;
