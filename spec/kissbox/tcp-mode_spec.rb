require File.join(File.dirname(__FILE__), %w{.. spec_helper})

describe Kissbox::TcpMode do

  before :each do
    @sock = Object.new
    TCPSocket.stub!(:new).and_return(@sock)
  end

  describe "with a service" do
    before :each do
      @service = Object.new
      @service.stub!(:kissbox_ip).and_return("127.0.0.1")
      @service.stub!(:kissbox_port).and_return("9812")
      @tcpmode = Kissbox::TcpMode.new @service
    end

    it "should write single channel value" do
      @sock.should_receive(:write).with([0xA5, 0, 0, 1].pack "C*")
      @tcpmode.write_single_channel_value 1, 1, :on
    end
  end
end

