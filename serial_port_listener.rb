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

  # Assuming one sample per second
  SAMPLES_PER_MINUTE = 60

  def go
    lines = 0
    history_size = SAMPLES_PER_MINUTE * 5
    x_values = (0...history_size).to_a
    temperatures = RingBuffer.new(history_size)
    history_size.times do
      temperatures.push(0)
    end

    humidities = RingBuffer.new(history_size)
    history_size.times do
      humidities.push(0)
    end

    token_buffer = ''
    while true do
      sp_char = @sp.getc
      if sp_char
        if sp_char == "\n"
          humidities.push(token_buffer.to_f);

          token_buffer = ''
          lines += 1
          if lines % 5 == 0
            Gnuplot.open do |gp|
              Gnuplot::Plot.new( gp ) do |plot|
                plot.terminal 'png size 1000, 600'
                plot.output File.expand_path("../graph.gif", __FILE__)

                plot.title  "Temperature and Humidity"
                plot.key 'on autotitle'
                plot.tics 'nomirror out'
                plot.y2tics ''
                plot.grid 'xtics ytics'
                plot.xlabel "Samples"
                # Library's treatment of quotes is a bit dopey.
                plot.ylabel "'Celsius' textcolor rgbcolor 'red'"
                plot.y2label "'RH%' textcolor rgbcolor 'blue'"

                plot.yrange "[16:24]"
                plot.y2range "[10:90]"

                y = temperatures

                plot.data << Gnuplot::DataSet.new( [x_values, y] ) do |ds|
                  ds.with = "lines"
                  ds.notitle
                  ds.linecolor = 'rgbcolor "red"'
                end

                plot.data << Gnuplot::DataSet.new([x_values, humidities]) do |ds|
                  ds.axes = 'x1y2'
                  ds.with = "lines"
                  ds.notitle
                  ds.linecolor = 'rgbcolor "blue"'
                  ds.smooth = 'bezier'
                end
              end
            end
          end
        elsif sp_char == ','
          temperatures.push(token_buffer.to_i / 100.0)

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