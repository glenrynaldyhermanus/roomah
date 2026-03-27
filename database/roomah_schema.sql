-- Roomah App Schema DDL
-- Run this in your Supabase SQL Editor

-- 1. Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create Tables

-- Households (Family)
CREATE TABLE IF NOT EXISTS public.households (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name VARCHAR NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id) -- Linking to Supabase Auth Users
);

-- Household Members
CREATE TABLE IF NOT EXISTS public.household_members (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR DEFAULT 'member', -- 'admin', 'member'
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(household_id, user_id)
);

-- Inventory Categories
CREATE TABLE IF NOT EXISTS public.inventory_categories (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name VARCHAR NOT NULL,
    icon VARCHAR,
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inventory Items
CREATE TABLE IF NOT EXISTS public.inventory_items (
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

-- Events (Routines/Reminders)
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title VARCHAR NOT NULL,
    description TEXT,
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    frequency_type VARCHAR, -- 'daily', 'weekly', 'monthly', 'once'
    event_date TIMESTAMP WITH TIME ZONE,
    is_recurring BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- Recipes
CREATE TABLE IF NOT EXISTS public.recipes (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title VARCHAR NOT NULL,
    description TEXT,
    instructions TEXT,
    prep_time_minutes INTEGER,
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recipe Ingredients
CREATE TABLE IF NOT EXISTS public.recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    recipe_id UUID REFERENCES public.recipes(id) ON DELETE CASCADE,
    item_name VARCHAR NOT NULL,
    quantity VARCHAR,
    is_optional BOOLEAN DEFAULT FALSE
);

-- Shopping List Items
CREATE TABLE IF NOT EXISTS public.shopping_list_items (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    name VARCHAR NOT NULL,
    household_id UUID REFERENCES public.households(id) ON DELETE CASCADE,
    is_checked BOOLEAN DEFAULT FALSE,
    inventory_item_id UUID REFERENCES public.inventory_items(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.households ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.household_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shopping_list_items ENABLE ROW LEVEL SECURITY;

-- 4. Create Basic Policies (Allow all authenticated users for now - REFINE THIS FOR PRODUCTION)
-- Note: In a real app, you should restrict access based on household_members table.

-- Households: Allow read/write if authenticated (Simplification)
CREATE POLICY "Allow authenticated access to households" ON public.households
    FOR ALL USING (auth.role() = 'authenticated');

-- Household Members
CREATE POLICY "Allow authenticated access to household_members" ON public.household_members
    FOR ALL USING (auth.role() = 'authenticated');

-- Inventory
CREATE POLICY "Allow authenticated access to inventory_categories" ON public.inventory_categories
    FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated access to inventory_items" ON public.inventory_items
    FOR ALL USING (auth.role() = 'authenticated');

-- Events
CREATE POLICY "Allow authenticated access to events" ON public.events
    FOR ALL USING (auth.role() = 'authenticated');

-- Recipes
CREATE POLICY "Allow authenticated access to recipes" ON public.recipes
    FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated access to recipe_ingredients" ON public.recipe_ingredients
    FOR ALL USING (auth.role() = 'authenticated');

-- Shopping List
CREATE POLICY "Allow authenticated access to shopping_list_items" ON public.shopping_list_items
    FOR ALL USING (auth.role() = 'authenticated');
