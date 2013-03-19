Sequel.migration do
  up do
    add_column :passbook_passes, :tsv, 'TSVector'

    run %{
      CREATE INDEX tsv_GIN ON passbook_passes \
        USING GIN(tsv);
    }

    run %{
      CREATE TRIGGER TS_tsv \
        BEFORE INSERT OR UPDATE ON passbook_passes \
      FOR EACH ROW EXECUTE PROCEDURE \
        tsvector_update_trigger(tsv, 'pg_catalog.english', pass_type_identifier, serial_number);
    }
  end

  down do
    drop_column :passbook_passes, :tsv
    drop_index :passbook_passes, :tsv_GIN
    drop_trigger :passbook_passes, :TS_tsv
  end
end
