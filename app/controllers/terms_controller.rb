class TermsController < ApplicationController
  before_action :authenticate_user!, only: %i(new create update)

  def index
    @terms = Term.all
  end

  def new
  end

  def create
    @term = Term.create! term_params
    @descriptions = @term.load_descriptions
  rescue => e
    @error = e.message
  end

  def update
    @term = Term.find params[:id]
    @term.description = params[:term][:description]
    @term.save!
    redirect_to terms_path
  rescue => _e
  end

  def description
    raise 'missing argument \'term\'' if params[:term].blank?
    render json: {description: Term.where(eng_title: Regexp.new(params[:term], 'i')).first.description.to_s}, status: :ok
  rescue => e
    render json: {message: e.message}, status: :internal_server_error
  end

  private

  def term_params
    params.require(:term).permit(:title, :eng_title)
  end
end
