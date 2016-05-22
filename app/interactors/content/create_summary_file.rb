class Content::CreateSummaryFile
  include Interactor

  before do
    @log        = context.log
    @updated    = context.updated
    @created    = context.created
    @archived   = context.archived
    @deployment = context.deployment

    @log.info "CREATING SUMMARY FILE (c: #{@created.size}, u: #{@updated.size},  r: #{@archived.size})"
  end

  def call
    # TODO: create html summary file
    @log.info "COMPARE LINK: "
    if prev_deployment = @deployment.prev
      @log.info @deployment.github_compare_link_against(prev_deployment)
    end
  end


end