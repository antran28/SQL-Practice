SELECT parts_assembly.part, parts_assembly.assembly_step
  FROM parts_assembly
  WHERE parts_assembly.finish_date IS NULL;
