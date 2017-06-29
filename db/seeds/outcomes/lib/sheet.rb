require "csv"
require_relative "line"

class Sheet

  SKIP_LINES = 2

  def initialize(csv_path)
    @path = csv_path
    reload
    nil
  end

  def reload
    @rows = CSV.read(@path).drop(SKIP_LINES)
  end

  def valid?
    @rows.all? do |csv_row|
      Line.new(csv_row).valid?
    end
  end

  def log_invalid
    Rails.logger.debug "invalid entries in spreadsheet:"
    @rows.each_with_index do |csv_row, index|
      unless Line.new(csv_row).valid?
        Rails.logger.debug "line: #{index + SKIP_LINES + 1}"
        Rails.logger.info csv_row
      end
    end
    nil
  end

  def sync(opts)
    print = opts[:print]
    force = opts[:force]

    if force && valid?
      log_invalid
      return
    else
      lookup = {}
      depth_to_category_id = {}
      skill_id = nil

      @rows.each do |csv_row|
        line = Line.new(csv_row)
        lookup[line.uuid] = line

        if line.category?
          depth_to_category_id[line.depth] = line.uuid
          (1..6).each { |x| depth_to_category_id[line.depth + x] = nil }
          Rails.logger.info line.name if print
          line.upsert!
        elsif line.skill?
          skill_id = line.uuid
          category_id = (1..6).map { |x| depth_to_category_id[line.depth - x] }.detect { |v| v }
          Rails.logger.info lookup[category_id].name + " / " + line.name if print
          line.upsert!(category_id)
        elsif line.outcome?
          line.upsert!(skill_id)
        end
      end
    end
    nil
  end

end
