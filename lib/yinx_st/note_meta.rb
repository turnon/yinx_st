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

  def deleted_today?
    batches.of_guid(guid).first == self and dump_id != batches.latest_id
  end

  def status
    return :created if created_today?
    return :updated if updated_today?
    return :deleted if deleted_today?
    :remained
  end

  def prev_version
    @prev_version ||= batches.of_guid(guid).bsearch{|version| version.dump_id < self.dump_id}
  end

  def moved_book?
    prev_version and (prev_version.book != self.book or prev_version.stack != self.stack)
  end

  def changed_tags?
    prev_version and prev_version.tags.sort != self.tags.sort
  end

  def stack_book
    st = stack.nil? ? '' : "#{stack}/"
    "#{st}#{book}"
  end

  def stack_name
    stack ? stack : 'No Stack'
  end

  def tags_count
    tags.count
  end
end
