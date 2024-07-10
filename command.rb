require 'open3'

class Command
  def to_s
    "/sfs/ceph/standard/rc-students/ood/qlist/local_qlist"
  end

  AppProcess = Struct.new(:queue, :total_cores, :free_cores, :jobs_running, :jobs_pending, :time_limit, :su_charge)

  def parse(output)
    lines = output.strip.split("\n")
    # Skip header lines
    lines = lines.drop(2)
    lines.map do |line|
      fields = line.split(/\s{2,}/) # Split based on two or more spaces
      AppProcess.new(*fields)
    end
  end

  def exec
    processes, error = [], nil

    Open3.popen3(to_s) do |stdin, stdout, stderr, wait_thr|
      output = ""
      error_output = ""

      # Read stdout and stderr streams
      stdout_thread = Thread.new { output << stdout.read }
      stderr_thread = Thread.new { error_output << stderr.read }

      # Wait for threads to finish
      stdout_thread.join
      stderr_thread.join

      # Get the exit status
      exit_status = wait_thr.value

      if exit_status.success?
        processes = parse(output)
      else
        error = "Command '#{to_s}' exited with error: #{error_output}"
      end
    end

    [processes, error]
  end
end