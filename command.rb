require 'open3'

class Command
  def to_s
    "/sfs/ceph/standard/rc-students/ood/qlist/local_qlist"
  end

  AppProcess = Struct.new(:queue, :total_cores, :free_cores, :jobs_running, :jobs_pending, :time_limit, :su_charge)

  def parse(output)
    lines = output.strip.split("\n")
    # Skip header lines
    lines = lines.drop(3)
    lines.map do |line|
      fields = line.split(/\s{2,}/)
      fields.map! { |field| field.strip.empty? ? '0' : field }
      AppProcess.new(*fields)
    end
  end

  def exec
    processes, error = [], nil

    stdout, stderr, status = Open3.capture3(to_s)
    output = stdout + stderr

    processes = parse(output) if status.success?

    [processes, error]
  end
end
