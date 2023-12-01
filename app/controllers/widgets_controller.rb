class WidgetsController < ApplicationController
  # regenerate this controller with
  # bin/rails generate hot_glue:scaffold Widget 

  helper :hot_glue
  include HotGlue::ControllerHelper

  before_action :authenticate_user!
  before_action :load_widget, only: [:show, :edit, :update, :destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol == :turbo_stream }
  
  
  def load_widget
    @widget = current_user.widgets.find(params[:id])
  end
  
  def load_all_widgets 
    @widgets = current_user.widgets.page(params[:page])
    
  end

  def index
    load_all_widgets
  end

  def new
    @widget = Widget.new(user: current_user)
    
  end

  def create
    modified_params = modify_date_inputs_on_params(widget_params.dup, nil, []) 
    modified_params = modified_params.merge(user: current_user) 

      
    
    @widget = Widget.new(modified_params)
    
    

    if @widget.save
      flash[:notice] = "Successfully created #{@widget.name}"
      
      load_all_widgets
      render :create
    else
      flash[:alert] = "Oops, your widget could not be created. #{@hawk_alarm}"
      @action = "new"
      render :create, status: :unprocessable_entity
    end
  end



  def show
    redirect_to edit_widget_path(@widget)
  end

  def edit
    @action = "edit"
    render :edit
  end

  def update
    flash[:notice] = +''
    flash[:alert] = nil
    

    modified_params = modify_date_inputs_on_params(update_widget_params.dup, nil, []) 
    modified_params = modified_params.merge(user: current_user) 
    

    
      
    
    if @widget.update(modified_params)
    
      
      flash[:notice] << "Saved #{@widget.name}"
      flash[:alert] = @hawk_alarm if @hawk_alarm
      render :update
    else
      flash[:alert] = "Widget could not be saved. #{@hawk_alarm}"
      @action = "edit"
      render :update, status: :unprocessable_entity
    end
  end

  def destroy
    
    begin
      @widget.destroy
      flash[:notice] = 'Widget successfully deleted'
    rescue StandardError => e
      flash[:alert] = 'Widget could not be deleted'
    end 
    load_all_widgets
  end



  def widget_params
    params.require(:widget).permit(:name)
  end

  def update_widget_params
    params.require(:widget).permit(:name)
  end

  def namespace
    
  end
end


