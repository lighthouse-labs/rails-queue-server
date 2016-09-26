# Commit all the AR records (new and modified) to the database
#  Not to be confused with a git commit, this is a db transaction commit.
#  Everything takes place in one transaction so if stuff goes wrong, an exception is raised and the transaction is terminated
#  Therefore, a single DB save failure will cause the entire deployment to not commit and be considered a failure
#  - KV

class Content::Commit
  include Interactor

  before do
    @log     = context.log
    @repo    = context.repo
    @records = context.records

    @log.info "COMMITTING (recs: #{@records.size})"
  end

  def call
    updated, created, archived = [], [], []

    @records.each_with_index do |rec, i|
      if rec.new_record?
        @log.info "Creating #{rec.class} #{rec.uuid}"
        rec.save!
        created << rec
      elsif rec.changed?
        @log.info "Updating #{rec.class} #{rec.uuid}, changes:"
        @log.info rec.changes.awesome_inspect
        rec.save!
        updated << rec
      elsif rec.changed_for_autosave?
        @log.info "Updating #{rec.class} #{rec.uuid}, child changes"
        rec.save!
        updated << rec
      end
    end

    # report back results to caller
    context.updated  = updated
    context.created  = created
    context.archived = archived
  end

end
