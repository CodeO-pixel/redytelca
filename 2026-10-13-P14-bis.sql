USE bd_redytelca;

ALTER TABLE planes DROP COLUMN velocidad;

ALTER TABLE planes
  ADD CONSTRAINT chk_plan_velocidad_bajada CHECK (velocidad_bajada_mbps IS NULL OR velocidad_bajada_mbps > 0),
  ADD CONSTRAINT chk_plan_velocidad_subida CHECK (velocidad_subida_mbps IS NULL OR velocidad_subida_mbps > 0);

SELECT id_plan, nombre, velocidad_bajada_mbps, velocidad_subida_mbps, tecnologia, precio_mensual
FROM planes ORDER BY id_plan;