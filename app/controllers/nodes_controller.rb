class NodesController < ApplicationController
  before_action :set_node, only: [:show, :edit, :update, :destroy]
  before_filter :auth, :only => [:create, :update,:delete]

  # GET /nodes
  # GET /nodes.json
  def index
    @nodes = Node.all
    @rtt = {}
    @loss = {}
    conf = Collectd::Collectd.new
    @nodes.each do |node|
      collectd_node = Collectd::CollectdNode.new(node.id.to_s(16),node.link_local_address)
      #begin
        @rtt[node] = conf.stat(collectd_node,"ping",nil,nil).rtt_5_min
        @loss[node] = conf.stat(collectd_node,"ping",nil,nil).loss_5_min
      #rescue Exception => e #Ignore errors in single hosts (-> missing rrd-Files for newly created ...)
      #  logger.error "Unable to calculate stats: #{e}"
      #end
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json do 
        data = {}
        @nodes.each do |n| 
          data[n.id] = {id_hex: n.id_hex, 
            loss_5_min: (@loss[n].nil? || @loss[n].nan?) ? nil : @loss[n], 
            rtt_5_min: (@loss[n].nil? || @rtt[n].nan?) ? nil : @rtt[n]}
        end
        render json: data
      end
    end
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
  end

  # GET /nodes/new
  def new
    @node = Node.new
  end

  # GET /nodes/1/edit
  def edit
  end

  # POST /nodes
  # POST /nodes.json
  def create
    @node = Node.new(node_params)

    respond_to do |format|
      if @node.save
        format.html { redirect_to @node, notice: 'Node was successfully created.' }
        format.json { render :show, status: :created, location: @node }
      else
        format.html { render :new }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nodes/1
  # PATCH/PUT /nodes/1.json
  def update
    respond_to do |format|
      if @node.update(node_params)
        format.html { redirect_to @node, notice: 'Node was successfully updated.' }
        format.json { render :show, status: :ok, location: @node }
      else
        format.html { render :edit }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.json
  def destroy
    @node.destroy
    respond_to do |format|
      format.html { redirect_to nodes_url, notice: 'Node was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_node
      @node = Node.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def node_params
      params.require(:node).permit(:ip_address)
    end
end
