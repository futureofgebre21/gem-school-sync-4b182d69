-- 1. Rename existing 'casher' rows in user_assignments to 'cashier'
UPDATE public.user_assignments SET role_name = 'cashier' WHERE role_name = 'casher';
UPDATE public.user_assignments SET role = 'cashier' WHERE role = 'casher';

-- 2. Drop & recreate RLS policies that referenced 'casher'
DROP POLICY IF EXISTS " Casher full access to fee_payments " ON public.fee_payments;
CREATE POLICY "Cashier full access to fee_payments"
ON public.fee_payments FOR ALL TO public
USING (EXISTS (SELECT 1 FROM user_assignments
  WHERE user_assignments.user_id = auth.uid() AND user_assignments.role_name = 'cashier'));

DROP POLICY IF EXISTS " casher can manage fee_structures " ON public.fee_structures;
CREATE POLICY "Cashier can manage fee_structures"
ON public.fee_structures FOR ALL TO public
USING (EXISTS (SELECT 1 FROM user_assignments
  WHERE user_assignments.user_id = auth.uid() AND user_assignments.role_name = 'cashier'));

DROP POLICY IF EXISTS "Casher can full access  to payment structure " ON public.fee_structures;
CREATE POLICY "Cashier can full access to fee_structures"
ON public.fee_structures FOR ALL TO authenticated
USING (true) WITH CHECK (true);

-- 3. Fix Vice Admin role_codes policy
DROP POLICY IF EXISTS "Vice Admin can create specific codes" ON public.role_codes;
CREATE POLICY "Vice Admin can create specific codes"
ON public.role_codes FOR INSERT TO public
WITH CHECK (
  (EXISTS (SELECT 1 FROM user_assignments
    WHERE user_assignments.user_id = auth.uid() AND user_assignments.role_name = 'vice_admin'))
  AND role_name = ANY(ARRAY['human_resource'::text, 'cashier'::text])
);

-- 4. Seed role lookup with admin_position NULL (flat model)
INSERT INTO public.user_roles (role_name, admin_position) VALUES
  ('director', NULL),
  ('vice_academic', NULL),
  ('vice_admin', NULL),
  ('record_office', NULL),
  ('human_resource', NULL),
  ('cashier', NULL),
  ('teacher', NULL),
  ('student', NULL),
  ('parent', NULL)
ON CONFLICT DO NOTHING;