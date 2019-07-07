# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :passbook_passes, :tsv, 'TSVector'
    add_index :passbook_passes, :tsv, type: 'GIN'
    create_trigger :passbook_passes, :tsv, :tsvector_update_trigger,
                   args: %i[tsv pg_catalog.english pass_type_identifier serial_number],
                   events: %i[insert update],
                   each_row: true
  end

  down do
    drop_column :passbook_passes, :tsv
    drop_index :passbook_passes, :tsv
    drop_trigger :passbook_passes, :tsv
  end
end
