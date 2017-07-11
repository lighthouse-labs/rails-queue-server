class Content::ValidateUuids

  include Interactor

  def call
    validate_uuids(context.collection)
  end

  private

  def validate_uuids(collection, uuids = [])
    collection.each do |item|
      uuid = item['uuid']
      abort("\n\n---\nHALT! UUID required in #{item.inspect}") if uuid.blank?
      abort("\n\n---\nHALT! Dupe UUID found in #{item.inspect}. Check your data, as this is potentially disasterous!") if uuids.include?(uuid)
      uuids.push uuid
      # quiz questions also have uuids that must be universally unique and present
      validate_uuids(item['questions'], uuids) if item['questions']
    end
    true
  end

end
