require 'socket'

module Kissbox
  class TcpMode

    Sequences = {
      :one_one_on  => [ {:wait => 0, :cage => 1, :slot => 1, :state => :on} ],
      :one_one_off => [ {:wait => 0, :cage => 1, :slot => 1, :state => :off} ],
      :two_one_on =>  [ {:wait => 0, :cage => 2, :slot => 1, :state => :on} ],
      :two_one_off => [ {:wait => 0, :cage => 2, :slot => 1, :state => :off} ],
      :two_one_off => [ {:wait => 0, :cage => 2, :slot => 1, :state => :off} ],

      :on => [
        {:wait =>  0.0, :cage => 1, :slot => 1, :state => :on},
        {:wait =>  0.2, :cage => 1, :slot => 2, :state => :on},
        {:wait =>  0.2, :cage => 1, :slot => 3, :state => :on},
        {:wait =>  0.2, :cage => 1, :slot => 4, :state => :on},
        {:wait =>  0.2, :cage => 2, :slot => 1, :state => :on},
    ],

    :off => [
      {:wait =>  0.0, :cage => 1, :slot => 1, :state => :off},
      {:wait =>  0.2, :cage => 1, :slot => 2, :state => :off},
      {:wait =>  0.2, :cage => 1, :slot => 3, :state => :off},
      {:wait =>  0.2, :cage => 1, :slot => 4, :state => :off},
      {:wait =>  0.2, :cage => 2, :slot => 1, :state => :off},
    ],

    :duft1 => [
      {:wait =>  0.0, :cage => 2, :slot => 1, :state => :on},
      {:wait =>  1.0, :cage => 1, :slot => 1, :state => :on},
      {:wait =>  1.0, :cage => 1, :slot => 4, :state => :on},
      {:wait => 15.0, :cage => 1, :slot => 4, :state => :off},
      {:wait =>  1.0, :cage => 1, :slot => 1, :state => :off},
      {:wait =>  2.0, :cage => 2, :slot => 1, :state => :off},
    ],
    :duft2 => [
      {:wait => 0.0, :cage => 2, :slot => 1, :state => :on},
      {:wait => 1.0, :cage => 1, :slot => 1, :state => :on},
      {:wait => 1.0, :cage => 1, :slot => 4, :state => :on},
      {:wait => 7.0, :cage => 1, :slot => 4, :state => :off},
      {:wait => 1.0, :cage => 1, :slot => 1, :state => :off},
      {:wait => 2.0, :cage => 2, :slot => 1, :state => :off},
    ],
    :duft3 => [
      {:wait =>  0.0, :cage => 2, :slot => 1, :state => :on},
      {:wait =>  1.0, :cage => 1, :slot => 1, :state => :on},
      {:wait =>  0.1, :cage => 1, :slot => 2, :state => :on},
      {:wait =>  1.0, :cage => 1, :slot => 4, :state => :on},
      {:wait => 10.0, :cage => 1, :slot => 4, :state => :off},
      {:wait =>  1.0, :cage => 1, :slot => 2, :state => :off},
      {:wait =>  0.1, :cage => 1, :slot => 1, :state => :off},
      {:wait =>  2.0, :cage => 2, :slot => 1, :state => :off},
    ],
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
      sock.flush rescue nil
      sock.close rescue nil
    end

    def write_single_channel_value cage, slot, state, sock = nil
      sock ||= TCPSocket.new(@service.kissbox_ip, @service.kissbox_port)
      msg = [0xA5, cage-1, slot-1, (state == :on ? 0x01 : 0x00)].pack "C*"
      sock.write msg
      #if(state == :off)
      #  10.times { sock.write msg }
      #end
    ensure 
      sock.flush
      sleep 0.1
      #puts "written: #{msg}"
    end
  end
end
