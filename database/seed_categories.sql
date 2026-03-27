-- Replace 'YOUR_HOUSEHOLD_ID' with your actual household ID
-- You can find this in the 'households' table in Supabase Dashboard

INSERT INTO public.inventory_categories (name, icon, household_id)
VALUES 
    ('Kitchen', 'kitchen', 'YOUR_HOUSEHOLD_ID'),
    ('Toilet', 'toilet', 'YOUR_HOUSEHOLD_ID'),
    ('Bedroom', 'bedroom', 'YOUR_HOUSEHOLD_ID'),
    ('Living Room', 'living_room', 'YOUR_HOUSEHOLD_ID'),
    ('Cleaning', 'cleaning', 'YOUR_HOUSEHOLD_ID'),
    ('Others', 'others', 'YOUR_HOUSEHOLD_ID');
