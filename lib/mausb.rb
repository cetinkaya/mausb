# Copyright 2018 Ahmet Cetinkaya

# This file is part of Mausb.

# Mausb is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Mausb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Mausb.  If not, see <http://www.gnu.org/licenses/>.

module Mausb
  class Mausb::USBDevice
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def link
      @link = `readlink -f #{@id}`.strip unless @link
      @link
    end

    def is_mounted?
      Mausb.df.find_all{|l|
        l[0] == link
      }.length > 0
    end

    def info_text
      keys = ["Id", "IdLabel"]
      ui = Mausb.udisksctl_info(@id)
      link + " (" + keys.map{|key| "#{key}: #{ui[key]}"}.join(", ") + ")"
    end

    def to_s
      "Id: #{@id}, Link: #{link}"
    end
  end

  def Mausb.usb_ids
    folder = "/dev/disk/by-id"
    ids = Dir.entries("/dev/disk/by-id").find_all{|entry|
      entry[0..3] == "usb-" or entry[0..3] == "ata-"
    }
    ids.find_all{|id|
      ids.find_all{|id2|
        id2.index(id)
      }.length == 1
    }.map do |id|
      File.join(folder, id)
    end
  end

  def Mausb.usb_devices
    Mausb.usb_ids.map do |id|
      Mausb::USBDevice.new(id)
    end
  end

  def Mausb.mounted_usb_devices
    Mausb.usb_devices.find_all do |usb_device|
      usb_device.is_mounted?
    end
  end

  def Mausb.unmounted_usb_devices
    Mausb.usb_devices.find_all do |usb_device|
      not usb_device.is_mounted?
    end
  end

  def Mausb.df
    `df`.split("\n").drop(1).map do |line|
      line.split(/\s+/)
    end
  end

  def Mausb.udisksctl_info(id)
    h = Hash.new
    `udisksctl info -b #{id}`.split("\n").find_all{|line|
      line =~ /\s+[A-Za-z]+:.+$/
    }.each do |line|
      mda = /\s+([A-Za-z]+):(.+)$/.match(line).to_a
      key = mda[1]
      value = mda[2].strip
      h[key] = value
    end
    h
  end

  def Mausb.udisksctl_mount(link)
    `udisksctl mount -b #{link}`
  end

  def Mausb.udisksctl_unmount(link)
    `udisksctl unmount -b #{link}`
  end

  def Mausb.udisksctl_poweroff(link)
    `udisksctl power-off -b #{link}`
  end
end
