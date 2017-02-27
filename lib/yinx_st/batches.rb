require 'yinx'
require 'yinx_sql/json_batch'

module YinxSt
  class Batches
    attr_reader :all_notes

    def initialize n
      batches = Yinx::SQL::JsonBatch.last(n)
      @all_notes = batches.map do |b|
        b.batch.map do |h|
          n = Yinx::NoteMeta.from_h h
          n.dump_id = b.id
          n.dump_at = (b.fixed_dump_date or b.created_at)
          n.batches = self
          n
        end
      end.flatten
    end

    def of_guid guid
      batches_of_each_note[guid]
    end

    def batches_of_each_note
      @batches_of_each_note ||= Hash[
        all_notes.
          group_by(&:guid).
          map{|guid, versions| [guid, versions.sort{|v1, v2| v2.dump_id <=> v1.dump_id}]}
      ]
    end

    def latest_id
      @latest_id ||= @all_notes.max{|n1, n2| n1.dump_id <=> n2.dump_id}.dump_id
    end

    def unwind_tags
      @unwind_tags ||= all_notes.map{|note| note.unwind_tags}.flatten
    end

    def time_line
      @time_line ||= all_notes.map(&:dump_day).uniq.sort
    end

  end
end
