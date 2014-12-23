require 'rubygems'
require 'serialport'
require 'gnuplot'

require File.expand_path(File.dirname(__FILE__) + '/ring_buffer')

class SerialPortListener
  def initialize(port_str = 'COM4', baud_rate = 9600, data_bits = 8, stop_bits = 1, parity = SerialPort::NONE)
    #@sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

    #for some reason, can't get serial port working unless I've already opened the monitor in the IDE at least once
    @sp = SerialPort.new(port_str)
    @sp.set_modem_params(baud_rate, data_bits, stop_bits, parity)
  end

  def go
    lines = 0
    history_size = 60 * 3
    temperatures = RingBuffer.new(history_size)
    history_size.times do
      temperatures.push(20)
    end
    #pressures = RingBuffer.new(history_size)
    token_buffer = ''
    while true do
      sp_char = @sp.getc
      if sp_char
        if sp_char == "\n"
          temperatures.push(token_buffer.to_i / 100.0)

          token_buffer = ''
          lines += 1
          if lines % 5 == 0
            Gnuplot.open do |gp|
              Gnuplot::Plot.new( gp ) do |plot|
                plot.terminal 'gif'
                plot.output File.expand_path("../chart.gif", __FILE__)
                plot.title  "Array Plot Example"
                plot.xlabel "Samples"
                plot.ylabel "Celsius"

                plot.yrange "[18:22]"

                x = (0...history_size).collect { |v| v.to_f }
                y = temperatures

                plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
                  ds.with = "lines"
                  ds.notitle
                end
              end
            end
          end
        elsif sp_char == ','
          token_buffer = ''
        else
          token_buffer += sp_char
        end
        #puts "Current buffer: ", token_buffer
      end
    end
  end
end

spl = SerialPortListener.new
spl.go()