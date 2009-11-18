require 'socket'

module Kissbox
  class TcpMode

    Sequences = {
      :duft2 => [
        {:wait => 0, :cage => 2, :slot => 1, :state => :on},
        {:wait => 1, :cage => 1, :slot => 1, :state => :on},
        {:wait => 1, :cage => 1, :slot => 4, :state => :on},
        {:wait => 7, :cage => 1, :slot => 4, :state => :off},
        {:wait => 1, :cage => 1, :slot => 1, :state => :off},
        {:wait => 2, :cage => 2, :slot => 1, :state => :off},
      ]
    }

    def initialize service
      @service = service
    end


    def push smell
      puts " -- pushing smell: #{smell}, target: #{@service.kissbox_ip}:#{@service.kissbox_port}"
      sock = TCPSocket.new(@service.kissbox_ip, @service.kissbox_port)

      (steps = Sequences[smell.to_sym]) or (raise "no such smell: #{smell}")
      steps.each do |step|
        sleep step[:wait]
        puts "step: #{step.inspect}"
        write_single_channel_value step[:cage], step[:slot], step[:state], sock
      end
    ensure
      sock.close rescue nil
    end

    def write_single_channel_value cage, slot, state, sock = nil
      sock ||= TCPSocket.new(@service.kissbox_ip, @service.kissbox_port)
      msg = [0xA5, cage-1, slot-1, (state == :on ? 0x01 : 0x00)].pack "C*"
      sock.write msg
      sock.write msg if(state == :off)
      #puts "written: #{msg}"
    end
  end
end
