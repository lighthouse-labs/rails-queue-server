class Content::CreateSummaryFile
  include Interactor

  before do
    @log      = context.log
    @updated  = context.updated
    @created  = context.created
    @archived = context.archived

    @log.info "CREATING SUMMARY FILE (c: #{@created.size}, u: #{@updated.size},  r: #{@archived.size})"
  end

  def call
    # TODO: create html summary file
  end


end