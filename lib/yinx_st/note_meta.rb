require 'yinx'

class Yinx::NoteMeta
  attr_accessor :dump_id, :dump_at, :batches

  def dump_day
    dump_at.strftime '%y/%m/%d %a'
  end

  def updated_today?
    updated_at.between? (dump_at - 1.day), dump_at
  end

  def created_today?
    created_at.between? (dump_at - 1.day), dump_at
  end

  def status
    return :created if created_today?
    return :updated if updated_today?
    :remained
  end

  def prev_version
    @prev_version ||= batches.of_guid(guid).bsearch{|version| version.dump_id < self.dump_id}
  end

  def moved_book?
    prev_version and prev_version.book != self.book and prev_version.stack != self.stack
  end

  def changed_tags?
    prev_version and prev_version.tags.sort != self.tags.sort
  end

end
